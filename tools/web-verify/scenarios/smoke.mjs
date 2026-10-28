// Home -> Play -> board. Copy and extend this for feature-specific checks.
export default async function (t) {
  await t.expectLabel('play');
  await t.shot('home');
  await t.tap('play');                    // exact match, so it does not hit "How to play"
  await t.wait(800);
  console.log('table labels:', JSON.stringify(await t.labels()));
  await t.shot('table');
  await t.tapAt(0.5, 0.5);                // board has no semantics: tap by viewport fraction
  await t.shot('after-first-tap');
  await t.tap('back');
  await t.tap('leave');                   // confirm dialog appears mid-game
  await t.expectLabel('settings');        // back on home
}
