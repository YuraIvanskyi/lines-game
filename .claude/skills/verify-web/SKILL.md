---
name: verify-web
description: Build the Flutter app for web, drive it in a real headless Chrome/Edge (taps, screenshots, console errors) and report whether a UI change works. Use after changing anything in app/lib to verify it visually and functionally without asking the user to run the app.
---

# verify-web

Closed loop for checking app changes yourself: **analyze/test -> build web -> drive in browser -> read screenshots -> fix -> repeat.**
Tooling lives in `tools/web-verify/` (Playwright driving the installed Chrome, falling back to Edge; nothing to download).

## Loop

1. Fast gate (seconds): `cd app && flutter analyze && flutter test`
2. Build (about 45 s; **required after every code edit**, the browser serves `app/build/web`, not your source):
   `cd app && flutter build web --release`
3. Run a scenario:
   `cd tools/web-verify && node verify.mjs <scenario>`
   (first time on a fresh clone: `npm install` there)
4. **Look at the screenshots** with the Read tool (paths are printed, in `tools/web-verify/out/`). Passing assertions don't prove it *looks* right; check layout, text, colours, overflow.
5. If it fails: the output includes the visible labels and a `*-failure.png`. Fix the code, go to step 2.

Exit code 0 means the scenario passed **and** there were no `console.error`, uncaught page errors or failed requests. Anything else exits 1 and prints `PROBLEMS:`.

## Writing a scenario

Add `tools/web-verify/scenarios/<name>.mjs` exporting a default async function. Start from `scenarios/smoke.mjs`. Helpers on `t`:

| helper | use |
|---|---|
| `t.tap('label')` | tap a button by its Semantics label (exact match preferred, then substring, case-insensitive) |
| `t.tapAt(x, y)` | tap viewport coordinates; values <= 1 are fractions of the viewport |
| `t.tapCell(row, col)` | tap a 6x6 board cell (calibrated for the default 390x844 only) |
| `t.labels()` | every text/label currently in the semantics tree; use it to discover what you can tap or assert |
| `t.expectLabel('text')` | wait for text to appear, or fail and list what is visible |
| `t.shot('name')` | screenshot to `out/NN-name.png` |
| `t.wait(ms)` | pause for animations |

Options: `--size 390x844` (default, portrait phone), `--headed` (watch it), `--out DIR`, `--verbose` (echo browser console), `--url http://...` (use an already-running server instead of `app/build/web`).

## How it works / gotchas

- Flutter web paints to a canvas, so there are no DOM buttons. The driver turns on Flutter's accessibility tree, which exposes `Semantics` widgets as DOM nodes. Anything **without** a `Semantics(label: ...)` (e.g. board cells, plain `Text` inside gestures) is not findable by label: use `tapAt`/`tapCell` plus a screenshot.
- Screens that appear conditionally add steps: e.g. Back during a game raises a Stay/Leave dialog (`t.tap('leave')`).
- The table seed comes from the clock, so the board layout differs on every launch. Don't assert on specific cell contents or hard-code "legal" cells.
- Persistent state (settings) is per-run: each run uses a fresh browser context, so first-run behaviour is always exercised.
- Use `t.tap('play')`, not `'^play'`; labels are plain strings, not regexes.
- Don't run `flutter run -d chrome` for verification: it opens an interactive window and has no scripted control. Use this tool.

## Making it better (suggest to the user, don't do unasked)

- Read a `?seed=` query parameter on web (`LinesApp(seed: ...)` already exists) so scenarios can play deterministic games.
- Wrap board cells in `Semantics(label: 'cell r,c', button: true)` so scenarios can tap and assert by name instead of coordinates.
