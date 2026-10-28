import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lines_game/main.dart';
import 'package:lines_game/settings/app_settings.dart';
import 'package:lines_game/settings/copy.dart';
import 'package:lines_game/table/table_page.dart';
import 'package:lines_game/theme/arcade_shell.dart';
import 'package:lines_game/theme/game_feel.dart';
import 'package:lines_game/theme/ink_theme.dart';
import 'package:rules/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('english copy keeps the lines the table already shows', () {
    final copy = Copy.english;
    expect(copy.player(1), 'Player 1');
    expect(copy.turn('Player 1'), "Player 1's turn");
    expect(copy.lostPlayer('Player 1'), 'Player 1 lost');
    expect(copy.passPhone, 'Pass the phone');
    expect(copy.restartAsk('Player 2'), 'Player 2 wants to restart?');
    expect(
      Copy.ukrainian.restartAsk('Гравець 2'),
      'Гравець 2 хоче почати спочатку?',
    );
  });

  testWidgets('sound off does not start a cue', (tester) async {
    var on = true;
    final feel = DeviceFeel(soundOn: () => on);
    on = false;
    feel.growth();
    feel.illegal();
    feel.passTurn();
    feel.loss();
    expect(feel.cuesStarted, 0);
  });

  test('shared preferences keep sound and language', () async {
    final store = SharedPrefsSettingsStore();
    expect(await store.load(), AppSettings.defaults);
    const saved = AppSettings(sound: false, language: AppLanguage.ukrainian);
    await store.save(saved);
    expect(await store.load(), saved);
  });

  testWidgets('leaving settings forgets an unsaved change', (tester) async {
    final store = SharedPrefsSettingsStore();
    await tester.pumpWidget(LinesApp(seed: 1, settingsStore: store));

    await _openSettings(tester);
    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pump();
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
    await tester.tap(find.text('УКРАЇНСЬКА'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(await store.load(), AppSettings.defaults);

    await _openSettings(tester);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(_button(tester, 'ENGLISH').color, InkTheme.sun);
    expect(_button(tester, 'УКРАЇНСЬКА').color, InkTheme.blueFace);
  });

  testWidgets('save stores sound and language and applies them', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = SharedPrefsSettingsStore();
    await tester.pumpWidget(LinesApp(seed: 1, settingsStore: store));
    await _openSettings(tester);

    final english = tester.getRect(find.widgetWithText(PopButton, 'ENGLISH'));
    final ukrainian = tester.getRect(
      find.widgetWithText(PopButton, 'УКРАЇНСЬКА'),
    );
    expect(english.left, closeTo(ukrainian.left, 0.01));
    expect(english.width, closeTo(ukrainian.width, 0.01));
    expect(ukrainian.top, greaterThan(english.bottom));
    expect(find.byType(PopIconButton), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pump();
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
    expect(find.byType(PopIconButton), findsNWidgets(2));
    await tester.tap(find.text('УКРАЇНСЬКА'));
    await tester.pump();
    expect(_button(tester, 'УКРАЇНСЬКА').color, InkTheme.sun);
    expect(await store.load(), AppSettings.defaults);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(
      await store.load(),
      const AppSettings(sound: false, language: AppLanguage.ukrainian),
    );
    expect(find.text('ЗБЕРЕГТИ'), findsOneWidget);
    expect(find.text('Звук'), findsOneWidget);
    expect(find.text('Мови'), findsOneWidget);
    expect(tester.getSize(find.text('НАЛАШТУВАННЯ')).height, lessThan(56));
    expect(find.byIcon(Icons.volume_off), findsOneWidget);

    final saved = await store.load();
    await tester.pumpWidget(
      LinesApp(
        key: const ValueKey('relaunch'),
        seed: 1,
        settingsStore: store,
        initialSettings: saved,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ГРАТИ'), findsOneWidget);
    expect(find.text('КЛАСИКА'), findsOneWidget);

    await tester.tap(find.text('ГРАТИ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Хід: Гравець 1'), findsOneWidget);
    expect(find.text('Передайте телефон'), findsOneWidget);
  });

  testWidgets('save shows a chip that fades and clears on a new change', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      LinesApp(seed: 1, settingsStore: SharedPrefsSettingsStore()),
    );
    await _openSettings(tester);
    double opacity() => tester
        .widget<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .opacity;
    expect(opacity(), 0);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('SAVED'), findsOneWidget);
    expect(opacity(), 1);

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pump();
    expect(opacity(), 0);

    await tester.tap(find.text('SAVE'));
    await tester.pump();
    await tester.pump();
    expect(opacity(), 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(opacity(), 0);
  });

  testWidgets('ukrainian copy reaches a table opened on its own', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppCopy(
        copy: Copy.ukrainian,
        child: MaterialApp(
          home: TablePage(seed: 1, mode: classicMode.copyWith(wallChance: 0)),
        ),
      ),
    );
    expect(find.text('Хід: Player 1'), findsOneWidget);
    expect(find.text('Передайте телефон'), findsOneWidget);
  });
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
}

PopButton _button(WidgetTester tester, String text) {
  return tester.widget<PopButton>(find.widgetWithText(PopButton, text));
}
