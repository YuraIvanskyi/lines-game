// Drives the built Flutter web app in a real browser and reports what happened.
//
//   node verify.mjs <scenario> [--out DIR] [--port N] [--headed] [--size 390x844] [--url URL]
//
// <scenario> is a file in ./scenarios (name with or without .mjs) or a path.
// Serves ../../app/build/web unless --url is given (e.g. a `flutter run -d web-server` instance).
// Exit code 0 = scenario passed and no console/page errors; 1 = failure.
import { chromium } from 'playwright-core';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const flag = (n, d) => { const i = args.indexOf(`--${n}`); return i < 0 ? d : args[i + 1]; };
const has = (n) => args.includes(`--${n}`);

const scenarioArg = args[0]?.startsWith('--') ? undefined : args[0];
if (!scenarioArg) { console.error('usage: node verify.mjs <scenario> [--out DIR] [--headed] [--size WxH] [--url URL]'); process.exit(2); }
const scenarioPath = fs.existsSync(scenarioArg) ? path.resolve(scenarioArg)
  : path.join(here, 'scenarios', scenarioArg.endsWith('.mjs') ? scenarioArg : `${scenarioArg}.mjs`);

const out = path.resolve(flag('out', path.join(here, 'out')));
fs.mkdirSync(out, { recursive: true });
const [w, h] = flag('size', '390x844').split('x').map(Number);
const webRoot = path.resolve(here, '../../app/build/web');

// --- tiny static server (Flutter web needs correct MIME types, esp. .wasm/.js) ---
const mime = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.png': 'image/png', '.ico': 'image/x-icon', '.otf': 'font/otf', '.ttf': 'font/ttf',
  '.woff2': 'font/woff2', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.ogg': 'audio/ogg', '.css': 'text/css', '.svg': 'image/svg+xml' };
let server;
async function serve() {
  if (!fs.existsSync(path.join(webRoot, 'index.html'))) throw new Error(`No build at ${webRoot}. Run: flutter build web (in app/)`);
  server = http.createServer((req, res) => {
    let p = decodeURIComponent(new URL(req.url, 'http://x').pathname);
    if (p.endsWith('/')) p += 'index.html';
    const f = path.join(webRoot, p);
    if (!f.startsWith(webRoot) || !fs.existsSync(f) || fs.statSync(f).isDirectory()) { res.writeHead(404); return res.end(); }
    res.writeHead(200, { 'content-type': mime[path.extname(f)] ?? 'application/octet-stream', 'cache-control': 'no-store' });
    fs.createReadStream(f).pipe(res);
  });
  await new Promise((r) => server.listen(Number(flag('port', 0)), '127.0.0.1', r));
  return `http://127.0.0.1:${server.address().port}/`;
}

// --- launch whichever Chromium-family browser is installed ---
async function launch() {
  const headless = !has('headed');
  for (const channel of ['chrome', 'msedge']) {
    try { return await chromium.launch({ channel, headless, args: ['--autoplay-policy=no-user-gesture-required'] }); }
    catch (e) { lastErr = e; }
  }
  throw new Error(`No Chrome/Edge found for Playwright: ${lastErr?.message}`);
}
let lastErr;

const problems = [];
let step = 0;
const log = (m) => console.log(m);

const url = flag('url') ?? (await serve());
const browser = await launch();
const context = await browser.newContext({ viewport: { width: w, height: h }, deviceScaleFactor: 2, hasTouch: true, isMobile: true });
const page = await context.newPage();
page.on('console', (m) => { if (m.type() === 'error') problems.push(`console.error: ${m.text()}`); else if (has('verbose')) log(`[console.${m.type()}] ${m.text()}`); });
page.on('pageerror', (e) => problems.push(`pageerror: ${e.message}`));
page.on('requestfailed', (r) => problems.push(`requestfailed: ${r.url()} ${r.failure()?.errorText}`));

// Helpers handed to scenarios. Flutter web is canvas-based, so we turn on its semantics tree to get
// real DOM nodes (role=button + aria-label) for anything wrapped in Semantics.
const ctx = {
  page, out, w, h,
  async boot() {
    await page.goto(url);
    await page.waitForSelector('flutter-view, flt-glass-pane', { timeout: 60000 });
    await page.waitForSelector('flt-semantics-placeholder', { state: 'attached', timeout: 30000 });
    // The placeholder is offscreen on purpose; a DOM click enables the accessibility tree.
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    await page.waitForSelector('flt-semantics', { timeout: 15000 });
    await page.waitForTimeout(500);
  },
  /** Screenshot -> <out>/NN-name.png. Read it with the Read tool to inspect visuals. */
  async shot(name) {
    const f = path.join(out, `${String(++step).padStart(2, '0')}-${name}.png`);
    await page.screenshot({ path: f });
    log(`screenshot: ${f}`);
    return f;
  },
  /** All text currently exposed by the semantics tree (labels of buttons, headings, etc.). */
  async labels() {
    return page.evaluate(() => [...new Set([...document.querySelectorAll('flt-semantics')]
      .filter((n) => !n.querySelector('flt-semantics'))   // leaves only; parents repeat their children's text
      .map((n) => (n.getAttribute('aria-label') || n.textContent || '').trim().replace(/\n.*/s, '')).filter(Boolean))]);
  },
  /** Tap a Semantics node by label. Exact (case-insensitive) match wins over substring match. */
  async tap(label, { timeout = 5000 } = {}) {
    const find = () => page.evaluate((l) => {
      const want = l.toLowerCase();
      const items = [...document.querySelectorAll('flt-semantics')].filter((n) => !n.querySelector('flt-semantics'))
        .map((n) => ({ n, t: (n.getAttribute('aria-label') || n.textContent || '').trim().replace(/\n.*/s, '').toLowerCase() }))
        .filter((x) => x.t);
      const hit = items.find((x) => x.t === want) ?? items.find((x) => x.t.includes(want));
      if (!hit) return null;
      const r = hit.n.getBoundingClientRect();
      return { x: r.x + r.width / 2, y: r.y + r.height / 2, w: r.width, h: r.height };
    }, label);
    const deadline = Date.now() + timeout;
    let box;
    while (!(box = await find()) || !box.w) {
      if (Date.now() > deadline) throw new Error(`tap: no node labelled "${label}". Visible: ${JSON.stringify(await ctx.labels())}`);
      await page.waitForTimeout(100);
    }
    await page.mouse.click(box.x, box.y);
    await page.waitForTimeout(400);
    log(`tap: ${label}`);
  },
  /** Tap viewport coordinates (for the board, which has no semantics). Accepts fractions (0..1) or pixels. */
  async tapAt(x, y) {
    const px = x <= 1 ? x * w : x, py = y <= 1 ? y * h : y;
    await page.mouse.click(px, py);
    await page.waitForTimeout(400);
    log(`tapAt: ${Math.round(px)},${Math.round(py)}`);
  },
  /** Tap a board cell (0-based row/col of the 6x6 grid). Calibrated for the default 390x844 viewport only. */
  async tapCell(row, col) {
    if (w !== 390 || h !== 844) throw new Error('tapCell is calibrated for --size 390x844');
    await ctx.tapAt(54 + 56.35 * col, 364 + 56.35 * row);
  },
  async expectLabel(text, { timeout = 5000 } = {}) {
    try { await page.waitForFunction((t) => [...document.querySelectorAll('flt-semantics')]
      .some((n) => ((n.getAttribute('aria-label') || n.textContent || '')).toLowerCase().includes(t.toLowerCase())), text, { timeout }); }
    catch { throw new Error(`expected label "${text}" not found. Visible: ${JSON.stringify(await ctx.labels())}`); }
    log(`ok: label "${text}"`);
  },
  wait: (ms) => page.waitForTimeout(ms),
};

let failed = false;
try {
  const mod = await import(pathToFileURL(scenarioPath).href);
  await ctx.boot();
  await mod.default(ctx);
} catch (e) {
  failed = true;
  console.error(`SCENARIO FAILED: ${e.message}`);
  try { await ctx.shot('failure'); console.error(`labels: ${JSON.stringify(await ctx.labels())}`); } catch {}
}
await browser.close();
server?.close();
if (problems.length) { console.error('PROBLEMS:\n' + [...new Set(problems)].map((p) => '  ' + p).join('\n')); }
const ok = !failed && problems.length === 0;
console.log(ok ? 'RESULT: PASS' : 'RESULT: FAIL');
process.exit(ok ? 0 : 1);
