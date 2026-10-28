// Game mode -> Computer + Hard -> Save -> Play -> the bot answers a tap on its own.
export default async function (t) {
  await t.tap('game mode');
  await t.wait(500);
  await t.shot('mode-before');
  await t.tap('computer');
  await t.wait(300);
  await t.tap('hard');
  await t.wait(300);
  await t.shot('mode-computer-hard');
  await t.tap('save');
  await t.wait(500);
  await t.tap('back');
  await t.wait(500);
  await t.expectLabel('hard');            // home badge
  await t.shot('home-computer');
  await t.tap('play');
  await t.wait(800);
  await t.shot('table-your-move');
  await t.expectLabel('your move');
  // The anchor and walls change every run, so sweep the board until a tap is a legal growth.
  // Board spans about x 20..374, y 326..682 in a 390x844 viewport, six cells each way.
  sweep: for (let row = 0; row < 6; row++) {
    for (let col = 0; col < 6; col++) {
      await t.tapAt(54 + col * 56.5, 364 + row * 56.5);
      await t.wait(100);
      if ((await t.labels()).join('|').toLowerCase().includes('thinking')) break sweep;
    }
  }
  await t.shot('table-thinking');
  await t.expectLabel('thinking');
  await t.wait(1500);
  await t.expectLabel('your move');
  await t.shot('table-after-bot');
}
