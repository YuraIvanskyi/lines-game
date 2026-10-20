import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lines_game/table/board_view.dart';
import 'package:lines_game/table/table_page.dart';
import 'package:lines_game/theme/game_feel.dart';
import 'package:rules/rules.dart';

final open = classicMode.copyWith(wallChance: 0);

const four = [
  Player(id: 'p1', name: 'Player 1'),
  Player(id: 'p2', name: 'Player 2'),
  Player(id: 'p3', name: 'Player 3'),
  Player(id: 'p4', name: 'Player 4'),
];

void main() {
  testWidgets('a clear deal names player 1 and asks for the phone', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TablePage(seed: 1, mode: open)));
    expect(find.text("Player 1's turn"), findsOneWidget);
    expect(find.text('Pass the phone'), findsOneWidget);
    expect(find.text('REMATCH'), findsNothing);
  });

  testWidgets('tapping a neighboring cell passes the turn', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TablePage(seed: 1, mode: open)));
    await tapMove(tester, deal(open, seed: 1));
    expect(find.text("Player 2's turn"), findsOneWidget);
    expect(find.text('Pass the phone'), findsOneWidget);
  });

  testWidgets('four seats cycle back to player 1', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TablePage(seed: 1, mode: open, players: four)));
    var match = deal(open, seed: 1, players: four);
    for (var i = 0; i < 4; i++) {
      expect(find.text("${match.currentPlayer.name}'s turn"), findsOneWidget);
      final move = legalMoves(match).first;
      await tapCell(tester, match, move.cell);
      match = apply(match, move);
    }
    expect(find.text("Player 1's turn"), findsOneWidget);
  });

  testWidgets('home leaves a finished match', (tester) async {
    final stuck = dealClassic(seed: 1, width: 2, height: 2, wallChance: 1);
    var wentHome = false;
    await tester.pumpWidget(
      MaterialApp(
        home: TablePage(mode: open, initial: stuck, onHome: () => wentHome = true),
      ),
    );
    expect(find.text('Player 1 lost'), findsOneWidget);
    expect(find.text('REMATCH'), findsOneWidget);
    await tester.tap(find.text('HOME'));
    await tester.pump();
    expect(wentHome, isTrue);
  });

  testWidgets('back asks before leaving a live game', (tester) async {
    var wentHome = false;
    await tester.pumpWidget(MaterialApp(home: TablePage(seed: 1, mode: open, onHome: () => wentHome = true)));
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('STAY'), findsOneWidget);
    await tester.tap(find.text('STAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(wentHome, isFalse);
    expect(find.text("Player 1's turn"), findsOneWidget);
  });

  testWidgets('an illegal tap is not a growth', (tester) async {
    final feel = RecordingFeel();
    await tester.pumpWidget(MaterialApp(home: TablePage(seed: 1, mode: open, feel: feel)));
    final match = deal(open, seed: 1);
    await tapCell(tester, match, match.head);
    expect(feel.events, ['illegal']);
  });

  testWidgets('a finished game cues a loss, not an illegal tap', (tester) async {
    final feel = RecordingFeel();
    var match = dealClassic(seed: 1, width: 2, height: 2, wallChance: 0);
    late Move ending;
    while (true) {
      final moves = legalMoves(match);
      final terminal = moves.where((move) => apply(match, move).isTerminal);
      if (terminal.isNotEmpty) {
        ending = terminal.first;
        break;
      }
      match = apply(match, moves.first);
    }
    await tester.pumpWidget(MaterialApp(home: TablePage(mode: open, initial: match, feel: feel)));
    await tapCell(tester, match, ending.cell);
    expect(feel.events, ['growth', 'loss']);
  });

  test('cell hit stays inside its own dot', () {
    final match = deal(open, seed: 1);
    const size = Size(400, 400);
    expect(cellAt(match, size, const Offset(25, 25)), match.cellOf(0, 0));
    expect(cellAt(match, size, const Offset(50, 25)), isNull);
  });
}

Future<void> tapMove(WidgetTester tester, Match match) {
  return tapCell(tester, match, legalMoves(match).first.cell);
}

Future<void> tapCell(WidgetTester tester, Match match, int cell) async {
  final box = tester.renderObject<RenderBox>(find.byType(BoardView));
  final cellWidth = box.size.width / match.width;
  final cellHeight = box.size.height / match.height;
  final target = Offset((match.xOf(cell) + 0.5) * cellWidth, (match.yOf(cell) + 0.5) * cellHeight);
  await tester.tapAt(box.localToGlobal(target));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

class RecordingFeel extends GameFeel {
  final events = <String>[];

  @override
  void growth() => events.add('growth');

  @override
  void illegal() => events.add('illegal');

  @override
  void passTurn() => events.add('pass');

  @override
  void loss() => events.add('loss');
}
