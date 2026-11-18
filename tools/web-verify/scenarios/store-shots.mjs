// Store screenshots: home, opening table, mid-game, which-end (if it comes up), game over, vs computer.
// STORE_LANG=uk switches the app to Ukrainian first. Sizes, e.g.:
//   iPhone 6.9":  --size 440x956 --scale 3 --platform ios   (1320x2868, no Exit button)
//   Play phone:   --size 360x720 --scale 3   (1080x2160, Play caps the aspect at 2:1)
const uk = process.env.STORE_LANG === 'uk';
const L = uk
  ? { lang: 'українська', save: 'зберегти', back: 'назад', play: 'грати',
      gameMode: 'режим гри', computer: 'комп’ютер', hard: 'важко', home: 'на головну', which: 'який кінець', rematch: 'ще раз' }
  : { play: 'play', save: 'save', back: 'back', gameMode: 'game mode', computer: 'computer', hard: 'hard', home: 'home',
      which: 'which end', rematch: 'rematch' };

const cells = [];
for (let r = 0; r < 6; r++) for (let c = 0; c < 6; c++) cells.push([r, c]);
const shuffled = () => cells.map((x) => [Math.random(), x]).sort((a, b) => a[0] - b[0]).map((x) => x[1]);
const snapshot = async (t) => (await t.labels()).join('|').toLowerCase();

// Tap cells in random order until the headline changes. Returns 'moved', 'which', 'over' or 'stuck'.
async function grow(t) {
  const before = await snapshot(t);
  for (const [r, c] of shuffled()) {
    await t.tapCell(r, c);
    const now = await snapshot(t);
    if (now === before) continue;
    if (now.includes(L.rematch)) return 'over';
    if (now.includes(L.which)) return 'which';
    return 'moved';
  }
  return 'stuck';
}

export default async function (t) {
  if (uk) {
    // The app boots in English; the switch applies on save.
    await t.tap('settings');
    await t.tap(L.lang);
    await t.tap('save');
    await t.tap(L.back);
  }
  await t.wait(600);
  await t.shot('home');

  await t.tap(L.play);
  await t.wait(900);
  await t.shot('table-start');

  let shotWhich = false;
  let moves = 0;
  for (let i = 0; i < 80; i++) {
    const r = await grow(t);
    if (r === 'stuck') throw new Error('no legal cell found');
    if (r === 'which' && !shotWhich) { await t.wait(400); await t.shot('which-end'); shotWhich = true; }
    if (r === 'over') break;
    if (r === 'moved' && ++moves === 9) { await t.wait(600); await t.shot('mid-game'); }
  }
  await t.wait(900);
  await t.shot('game-over');

  await t.tap(L.home);
  await t.tap(L.gameMode);
  await t.tap(L.computer);
  await t.tap(L.hard);
  await t.wait(300);
  await t.shot('game-mode');
  await t.tap(L.save);
  await t.tap(L.back);
  await t.tap(L.play);
  await t.wait(900);
  for (let i = 0; i < 4; i++) {
    await grow(t);
    await t.wait(1800); // let the bot answer
  }
  await t.shot('vs-computer');
}
