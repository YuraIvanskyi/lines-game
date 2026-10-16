import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lines_game/home/setup_page.dart';
import 'package:lines_game/main.dart';
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
    await tester.tap(find.text('HOW TO PLAY'));
    await tester.pumpAndSettle();
    expect(find.text('Tap a marked dot.'), findsOneWidget);
    expect(find.text('The player who cannot grow loses.'), findsOneWidget);
    await tester.tap(find.text("LET'S GO"));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('The line grows from either end.'), findsNothing);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });

  testWidgets('skip hides the first-game note', (tester) async {
    await tester.pumpWidget(const LinesApp(seed: 1));
    await tester.tap(find.text('SKIP'));
    await tester.pump();
    expect(find.text('The line grows from either end.'), findsNothing);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
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
