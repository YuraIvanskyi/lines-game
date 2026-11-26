// One-tap play, Game mode (save), chips on home, persistence across reload.
export default async function (t) {
  await t.expectLabel('game mode');
  await t.shot('home-default');

  await t.tap('game mode');
  await t.expectLabel('same phone');
  console.log('game mode labels:', JSON.stringify(await t.labels()));
  await t.shot('game-mode');

  // Online is not available yet: tapping it keeps Same phone and its player picker.
  await t.tap('online');
  await t.expectLabel('3');

  await t.tap('3');
  await t.shot('game-mode-three-unsaved');
  // Save returns home on its own.
  await t.tap('save');
  await t.expectLabel('3 players');
  await t.shot('home-three');

  // Reload: the saved setup is still there.
  await t.boot();
  await t.expectLabel('3 players');

  // Play goes straight to the board, with three seats.
  await t.tap('play');
  await t.expectLabel('pass the phone');
  await t.shot('table');

  // Restore defaults so reruns start clean.
  await t.tap('back');
  await t.tap('leave');
  await t.tap('game mode');
  await t.tap('2');
  await t.tap('save');
  await t.expectLabel('2 players');
}
