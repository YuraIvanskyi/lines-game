import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lines_game/home/setup_page.dart';
import 'package:lines_game/main.dart';
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
    await tester.pumpAndSettle();
    expect(find.text('Tap a marked dot.'), findsOneWidget);
    expect(find.text('The player who cannot grow loses.'), findsOneWidget);
    await tester.tap(find.text("LET'S GO"));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });

  testWidgets('settings and info open empty menus', (tester) async {
    await tester.pumpWidget(const LinesApp(seed: 1));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.priority_high));
    await tester.pumpAndSettle();
    expect(find.text('INFO'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('icon row matches the main buttons and keeps square gaps', (tester) async {
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
    expect(buttons.map((button) => button.icon), [Icons.settings, Icons.priority_high, Icons.favorite, Icons.logout]);
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
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(4));
    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.tap(find.text('START'));
    await tester.pump();
    expect(started, hasLength(4));
    expect(started!.first.name, 'Player 1');
    expect(started!.map((player) => player.id).toList(), ['p1', 'p2', 'p3', 'p4']);
  });
}
