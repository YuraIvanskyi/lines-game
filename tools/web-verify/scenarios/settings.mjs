// Settings: sound toggle, language switch, Save feedback, and persistence across a page reload.
export default async function (t) {
  await t.tap('settings');
  await t.expectLabel('sound on');
  console.log('settings labels:', JSON.stringify(await t.labels()));
  await t.shot('settings-default');

  // Sound toggle flips its label; nothing is stored until Save.
  await t.tap('sound on');
  await t.expectLabel('sound off');
  await t.shot('sound-off-unsaved');

  // Pick Ukrainian, then Save: confirmation chip shows, UI switches language.
  await t.tap('Українська');
  await t.shot('ukrainian-selected');
  await t.tap('save');
  await t.expectLabel('Збережено');
  await t.shot('saved-ukrainian');

  // Reload (same browser context -> localStorage survives): settings must persist.
  await t.boot();
  await t.expectLabel('Грати');
  await t.shot('home-after-reload-uk');
  await t.tap('Налаштування');
  await t.expectLabel('Звук вимкнено');
  await t.shot('settings-after-reload');

  // Restore defaults so reruns start clean, and confirm English comes back.
  await t.tap('English');
  await t.tap('Звук вимкнено');
  await t.expectLabel('Звук увімкнено');
  await t.tap('Зберегти');
  await t.expectLabel('Saved');
  await t.shot('restored-english');
}
