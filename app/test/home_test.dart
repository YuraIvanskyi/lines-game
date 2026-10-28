import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lines_game/home/info_page.dart';
import 'package:lines_game/home/play_snippet.dart';
import 'package:lines_game/settings/game_setup.dart';
import 'package:lines_game/legal_links.dart';
import 'package:lines_game/main.dart';
import 'package:lines_game/settings/copy.dart';
import 'package:lines_game/table/board_view.dart';
import 'package:lines_game/theme/arcade_shell.dart';
import 'package:lines_game/theme/ink_theme.dart';
import 'package:rules/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final open = classicMode.copyWith(wallChance: 0);

  testWidgets('play reaches the board in one tap', (tester) async {
    await tester.pumpWidget(LinesApp(seed: 1, mode: open));
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('GAME MODE'), findsOneWidget);
    expect(find.text('PLAYERS'), findsNothing);
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("Player 1's turn"), findsOneWidget);
    expect(find.text('Pass the phone'), findsOneWidget);
  });

  testWidgets('home chips show the saved setup', (tester) async {
    await tester.pumpWidget(LinesApp(seed: 1, mode: open));
    expect(find.text('CLASSIC'), findsOneWidget);
    expect(find.text('2 PLAYERS'), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);

    await tester.pumpWidget(
      LinesApp(
        key: const ValueKey('computer'),
        seed: 1,
        initialSetup: const GameSetup(opponent: Opponent.computer),
      ),
    );
    expect(find.byIcon(Icons.computer), findsOneWidget);
    expect(find.byIcon(Icons.people), findsNothing);
  });

  testWidgets('game mode are saved, shown on home, and used by play', (tester) async {
    await _phone(tester);
    final store = MemoryGameSetupStore();
    await tester.pumpWidget(LinesApp(seed: 1, mode: open, setupStore: store));
    await tester.tap(find.text('GAME MODE'));
    await tester.pumpAndSettle();
    expect(find.text('CLASSIC'), findsOneWidget);
    expect(find.text('SAME PHONE'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(3));
    await tester.enterText(find.byType(TextField).first, 'Ada');
    expect(await store.load(), GameSetup.defaults);
    await tester.tap(find.text('SAVE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('SAVED'), findsOneWidget);
    await tester.pumpAndSettle();
    final saved = await store.load();
    expect(saved.playerCount, 3);
    expect(saved.names, ['Ada', '', '', '']);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('3 PLAYERS'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("Ada's turn"), findsOneWidget);
  });

  testWidgets('leaving game mode forgets an unsaved change', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(LinesApp(seed: 1, mode: open));
    await tester.tap(find.text('GAME MODE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('2 PLAYERS'), findsOneWidget);
    await tester.tap(find.text('GAME MODE'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('online is listed but not available yet', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(LinesApp(seed: 1, mode: open));
    await tester.tap(find.text('GAME MODE'));
    await tester.pumpAndSettle();
    expect(tester.widget<PopButton>(find.widgetWithText(PopButton, 'ONLINE')).enabled, isFalse);
    await tester.tap(find.text('ONLINE'));
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Online play is coming soon.'), findsOneWidget);
  });

  testWidgets('computer play is chosen, saved and started from game mode', (tester) async {
    await _phone(tester);
    final store = MemoryGameSetupStore();
    await tester.pumpWidget(LinesApp(seed: 1, mode: open, setupStore: store));
    await tester.tap(find.text('GAME MODE'));
    await tester.pumpAndSettle();
    expect(find.text('Difficulty'), findsNothing);

    await tester.tap(find.text('COMPUTER'));
    await tester.pump();
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('EASY'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    // Only the person's own name is editable, and the player count is fixed at two.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('3'), findsNothing);

    await tester.tap(find.text('HARD'));
    await tester.pump();
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    final saved = await store.load();
    expect(saved.opponent, Opponent.computer);
    expect(saved.difficulty, Difficulty.hard);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    // The computer badge names the difficulty in place of a player count.
    expect(find.text('2 PLAYERS'), findsNothing);
    expect(find.text('HARD'), findsOneWidget);
    expect(find.byIcon(Icons.computer), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("Player 1's turn"), findsOneWidget);
    expect(find.text('Your move'), findsOneWidget);
    // Tear the table down before the computer's pending move fires.
    await tester.pumpWidget(const SizedBox());
  });

  test('a computer setup seats the person first and the bot second', () {
    const setup = GameSetup(
      opponent: Opponent.computer,
      playerCount: 4,
      names: ['Ada', 'Bo', '', ''],
      difficulty: Difficulty.hard,
    );
    expect(setup.seatCount, 2);
    expect(setup.players(Copy.english).map((player) => player.name), ['Ada', 'Computer']);
    expect(setup.players(Copy.ukrainian).last.name, 'Комп’ютер');
    expect(setup.bots().keys, ['p2']);
    expect(setup.bots()['p2'], isA<SearchBot>());
    expect(const GameSetup(opponent: Opponent.computer).bots()['p2'], isA<RandomBot>());
    expect(GameSetup.defaults.bots(), isEmpty);
    expect(GameSetup.defaults.seatCount, 2);
    expect(const GameSetup(playerCount: 3).seatCount, 3);
  });

  test('saved setup survives the store and keeps default names blank', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsGameSetupStore();
    expect(await store.load(), GameSetup.defaults);
    const saved = GameSetup(
      opponent: Opponent.computer,
      playerCount: 4,
      names: ['Ada', '', 'Bo', ''],
      difficulty: Difficulty.hard,
    );
    await store.save(saved);
    expect(await store.load(), saved);
    final shared = GameSetup(playerCount: 4, names: saved.names).players(Copy.ukrainian);
    expect(shared.map((player) => player.name), ['Ada', 'Гравець 2', 'Bo', 'Гравець 4']);
    expect(shared.map((player) => player.id), ['p1', 'p2', 'p3', 'p4']);
  });

  testWidgets('how to play can be opened from home', (tester) async {
    await tester.pumpWidget(const LinesApp(seed: 1));
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('The line grows from either end.'), findsNothing);
    await tester.tap(find.text('HOW TO PLAY'));
    await tester.pump();
    expect(find.text('Tap a marked dot.'), findsOneWidget);
    expect(find.text('The player who cannot grow loses.'), findsOneWidget);
    expect(find.byType(PlaySnippet), findsNWidgets(3));
    await tester.tap(find.text("LET'S GO"));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });

  test('how-to demos play the lessons', () {
    expect(howToDemos, [tapDemo, endsDemo, lossDemo]);
    for (final demo in howToDemos) {
      var match = demo.frames.first;
      for (final move in demo.moves) {
        final next = apply(match, move);
        expect(identical(next, match), isFalse, reason: '$move');
        match = next;
      }
      expect(match, demo.frames.last);
    }

    expect(endsDemo.moves.map((move) => move.end), [End.head, End.tail]);
    expect(endsDemo.frames[1].head, 2);
    expect(endsDemo.frames[1].tail, 3);
    expect(endsDemo.frames[2].head, 2);
    expect(endsDemo.frames[2].tail, 6);
    expect(endsDemo.sampleAt(endsDemo.restAt(1)).match, endsDemo.frames[1]);
    expect(endsDemo.sampleAt(endsDemo.restAt(2)).match, endsDemo.frames[2]);
    expect(endsDemo.sampleAt(endsDemo.restAt(0)).opacity, 1);
    expect(
      endsDemo.sampleAt(endsDemo.reachAt(0)).fingerCell,
      endsDemo.moves.first.cell,
    );
    expect(
      endsDemo.sampleAt(endsDemo.reachAt(1)).fingerCell,
      endsDemo.moves.last.cell,
    );

    expect(tapDemo.frames.first.segments, isEmpty);
    expect(tapDemo.frames.first.head, tapDemo.frames.first.tail);
    expect(tapDemo.sampleAt(0).opacity, 0);
    expect(tapDemo.sampleAt(tapDemo.restAt(1)).match.segments, hasLength(1));
    expect(tapDemo.sampleAt(tapDemo.restAt(2)).match.segments, hasLength(2));
    expect(tapDemo.sampleAt(tapDemo.reachAt(0)).fingerT, greaterThan(0.5));
    final fading = tapDemo.sampleAt(tapDemo.periodMs - 1);
    expect(fading.opacity, lessThan(0.05));
    expect(fading.match, tapDemo.frames.last);

    expect(lossDemo.moves, isEmpty);
    expect(legalMoves(lossDemo.frames.first), isEmpty);
    expect(lossDemo.frames.last.isTerminal, isTrue);
    expect(lossDemo.frames.last.loserId, 'p1');
    final lost = lossDemo.sampleAt(lossDemo.lossAt);
    expect(lost.showLost, isTrue);
    expect(lost.lostT, 1);
    expect(lost.opacity, 1);
    expect(lost.showTargets, isFalse);
    expect(lost.match, lossDemo.frames.last);
  });

  testWidgets('how-to boards play the tap and the loss', (tester) async {
    await tester.pumpWidget(const LinesApp(seed: 1));
    await tester.tap(find.text('HOW TO PLAY'));
    await tester.pump();
    expect(find.text('LOST'), findsNothing);
    expect(_board(tester, 0).match.segments, isEmpty);

    final reach = tapDemo.reachAt(0);
    await _elapse(tester, reach);
    expect(_board(tester, 0).pendingCell, tapDemo.moves.first.cell);

    final loss = lossDemo.lossAt;
    await _elapse(tester, loss - reach);
    expect(find.text('LOST'), findsOneWidget);
    expect(
      _board(tester, 0).match.segments.length,
      tapDemo.sampleAt(loss).match.segments.length,
    );
    expect(
      _board(tester, 1).match.segments.length,
      endsDemo.sampleAt(loss).match.segments.length,
    );

    await tester.tap(find.text("LET'S GO"));
    await tester.pumpAndSettle();
  });

  testWidgets('settings and info open their pages', (tester) async {
    await tester.pumpWidget(const LinesApp(seed: 1));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Languages'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.text('ENGLISH'), findsOneWidget);
    expect(find.text('УКРАЇНСЬКА'), findsOneWidget);
    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.priority_high));
    await tester.pumpAndSettle();
    expect(find.text('INFO'), findsOneWidget);
    expect(find.text('Yurii Ivanskyi'), findsOneWidget);
    expect(find.text('Flutter and Dart.'), findsOneWidget);
    expect(find.textContaining('pure Dart package'), findsNothing);
    expect(find.textContaining('audioplayers'), findsOneWidget);
    expect(find.textContaining('Bohdan'), findsOneWidget);
    expect(find.textContaining('paper version'), findsOneWidget);
    expect(find.textContaining('SIL Open Font License'), findsOneWidget);
    expect(find.textContaining('variable font'), findsOneWidget);
    expect(find.textContaining('illegal tap'), findsNothing);
    for (final sample in ['Yurii Ivanskyi', 'Flutter and Dart.', 'Thanks']) {
      expect(
        tester.widget<Text>(find.text(sample)).textAlign,
        TextAlign.center,
      );
    }
    expect(
      tester.widget<Text>(find.textContaining('Bohdan')).textAlign,
      TextAlign.center,
    );
    expect(find.text('PLAY'), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('info lists legal links and keeps thanks last', (tester) async {
    final opened = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: InfoPage(
          onBack: () {},
          onOpenLink: (url) async => opened.add(url),
        ),
      ),
    );

    for (final label in ['PRIVACY POLICY', 'TERMS OF USE', 'SUPPORT']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(opened, [
      LegalLinks.privacyPolicy,
      LegalLinks.termsOfUse,
      LegalLinks.support,
    ]);
    expect(find.text('LICENSES'), findsOneWidget);

    final legal = tester.getTopLeft(find.text('Legal')).dy;
    final thanks = tester.getTopLeft(find.text('Thanks')).dy;
    final tech = tester.getTopLeft(find.text('Tech')).dy;
    expect(tech, lessThan(legal));
    expect(legal, lessThan(thanks));
  });

  testWidgets('icon row matches the main buttons and keeps square gaps', (
    tester,
  ) async {
    await tester.pumpWidget(const LinesApp(seed: 1));
    final play = tester.getRect(find.widgetWithText(PopButton, 'PLAY'));
    final howTo = tester.getRect(find.widgetWithText(PopButton, 'HOW TO PLAY'));
    final gameMode = tester.getRect(find.widgetWithText(PopButton, 'GAME MODE'));
    expect(howTo.height, closeTo(play.height, 0.01));
    expect(gameMode.height, closeTo(play.height, 0.01));

    final icons = find.byType(PopIconButton);
    expect(icons, findsNWidgets(4));
    final boxes = [for (var i = 0; i < 4; i++) tester.getRect(icons.at(i))];
    final buttons = tester.widgetList<PopIconButton>(icons).toList();
    expect(buttons.map((button) => button.icon), [
      Icons.settings,
      Icons.priority_high,
      Icons.favorite,
      Icons.logout,
    ]);
    expect(buttons[2].color, InkTheme.pinkFace);
    for (final box in boxes) {
      expect(box.width, closeTo(boxes.first.width, 0.01));
      expect(box.height, closeTo(boxes.first.height, 0.01));
      expect(box.height - box.width, closeTo(4, 0.01));
    }
    final gaps = [
      boxes[1].left - boxes[0].right,
      boxes[2].left - boxes[1].right,
      boxes[3].left - boxes[2].right,
    ];
    expect(play.height - boxes.first.height, closeTo(gaps[0], 0.5));
    expect(gaps[1], closeTo(gaps[0], 0.01));
    expect(gaps[2], closeTo(gaps[0], 0.01));
    expect(boxes.first.left, closeTo(play.left, 0.01));
    expect(boxes.last.right, closeTo(play.right, 0.01));

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('exit leaves through the app hook', (tester) async {
    var left = false;
    await tester.pumpWidget(LinesApp(seed: 1, onExit: () => left = true));
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();
    expect(left, isTrue);
    expect(find.text('PLAY'), findsOneWidget);
  });
}

BoardPainter _board(WidgetTester tester, int index) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((paint) => paint.painter)
      .whereType<BoardPainter>()
      .elementAt(index);
}

Future<void> _elapse(WidgetTester tester, int milliseconds) async {
  const slice = 40;
  var left = milliseconds;
  while (left > 0) {
    final step = left < slice ? left : slice;
    await tester.pump(Duration(milliseconds: step));
    left -= step;
  }
}

Future<void> _phone(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(402, 874));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
