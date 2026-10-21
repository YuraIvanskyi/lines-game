import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lines_game/home/play_snippet.dart';
import 'package:lines_game/home/setup_page.dart';
import 'package:lines_game/main.dart';
import 'package:lines_game/table/board_view.dart';
import 'package:lines_game/theme/arcade_shell.dart';
import 'package:lines_game/theme/ink_theme.dart';
import 'package:rules/rules.dart';

void main() {
  final open = classicMode.copyWith(wallChance: 0);

  testWidgets('play reaches the board on the second tap', (tester) async {
    await tester.pumpWidget(LinesApp(seed: 1, mode: open));
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('PLAYERS'), findsOneWidget);
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("Player 1's turn"), findsOneWidget);
    expect(find.text('Pass the phone'), findsOneWidget);
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
    expect(howToDemos, [endsDemo, tapDemo, lossDemo]);
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

    expect(legalMoves(lossDemo.frames.first), isNotEmpty);
    expect(lossDemo.moves.single.end, End.tail);
    expect(lossDemo.frames.last.isTerminal, isTrue);
    expect(lossDemo.frames.last.loserId, 'p2');
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
    expect(_board(tester, 1).match.segments, isEmpty);

    final reach = tapDemo.reachAt(0);
    await _elapse(tester, reach);
    expect(_board(tester, 1).pendingCell, tapDemo.moves.first.cell);

    final loss = lossDemo.lossAt;
    await _elapse(tester, loss - reach);
    expect(find.text('LOST'), findsOneWidget);
    expect(
      _board(tester, 1).match.segments.length,
      tapDemo.sampleAt(loss).match.segments.length,
    );
    expect(
      _board(tester, 0).match.segments.length,
      endsDemo.sampleAt(loss).match.segments.length,
    );

    await tester.tap(find.text("LET'S GO"));
    await tester.pumpAndSettle();
  });

  testWidgets('settings and info open empty menus', (tester) async {
    await tester.pumpWidget(const LinesApp(seed: 1));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.priority_high));
    await tester.pumpAndSettle();
    expect(find.text('INFO'), findsOneWidget);
    expect(find.text('Yurii Ivanskyi'), findsOneWidget);
    expect(find.text('Flutter and Dart.'), findsOneWidget);
    expect(find.textContaining('pure Dart package'), findsOneWidget);
    expect(find.textContaining('audioplayers'), findsOneWidget);
    expect(find.textContaining('Bohdan'), findsOneWidget);
    expect(find.textContaining('paper version'), findsOneWidget);
    expect(find.textContaining('SIL Open Font License'), findsOneWidget);
    expect(find.textContaining('variable font'), findsOneWidget);
    expect(find.textContaining('illegal tap'), findsOneWidget);
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

  testWidgets('icon row matches the main buttons and keeps square gaps', (
    tester,
  ) async {
    await tester.pumpWidget(const LinesApp(seed: 1));
    final play = tester.getRect(find.widgetWithText(PopButton, 'PLAY'));
    final howTo = tester.getRect(find.widgetWithText(PopButton, 'HOW TO PLAY'));
    final players = tester.getRect(find.widgetWithText(PopButton, 'PLAYERS'));
    expect(howTo.height, closeTo(play.height, 0.01));
    expect(players.height, closeTo(play.height, 0.01));

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

  testWidgets('four players and a blank name still start', (tester) async {
    List<Player>? started;
    await tester.pumpWidget(
      MaterialApp(
        home: SetupPage(
          mode: classicMode,
          onBack: () {},
          onStart: (players) => started = players,
        ),
      ),
    );
    expect(find.text('CLASSIC'), findsOneWidget);
    expect(find.text('Seat 1'), findsNothing);
    expect(find.byIcon(Icons.edit), findsNWidgets(2));
    final first = tester.widget<TextField>(find.byType(TextField).at(0));
    final second = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(first.textAlign, TextAlign.center);
    expect(first.decoration?.labelText, isNull);
    expect(first.decoration?.fillColor, isNot(second.decoration?.fillColor));
    expect(first.decoration?.fillColor, isNot(InkTheme.paper));
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(4));
    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.tap(find.text('START'));
    await tester.pump();
    expect(started, hasLength(4));
    expect(started!.first.name, 'Player 1');
    expect(started!.map((player) => player.id).toList(), [
      'p1',
      'p2',
      'p3',
      'p4',
    ]);
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
