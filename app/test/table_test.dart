import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lines_game/table/board_view.dart';
import 'package:lines_game/table/table_page.dart';
import 'package:rules/rules.dart';

void main() {
  testWidgets('a clear deal opens on player 1', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TablePage(seed: 1, wallChance: 0)));
    expect(find.text("Player 1's turn"), findsOneWidget);
    expect(find.text('Rematch'), findsOneWidget);
  });

  testWidgets('tapping a neighboring cell grows the line', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TablePage(seed: 1, wallChance: 0)));
    final match = dealClassic(seed: 1, wallChance: 0);
    final move = legalMoves(match).first;
    final box = tester.renderObject<RenderBox>(find.byType(BoardView));
    final cellWidth = box.size.width / match.width;
    final cellHeight = box.size.height / match.height;
    final target = Offset((match.xOf(move.cell) + 0.5) * cellWidth, (match.yOf(move.cell) + 0.5) * cellHeight);
    await tester.tapAt(box.localToGlobal(target));
    await tester.pumpAndSettle();
    expect(find.text("Player 2's turn"), findsOneWidget);
  });

  test('cell hit stays inside its own dot', () {
    final match = dealClassic(seed: 1, wallChance: 0);
    const size = Size(400, 400);
    final cell = match.cellOf(0, 0);
    final center = const Offset(25, 25);
    expect(cellAt(match, size, center), cell);
    expect(cellAt(match, size, const Offset(50, 25)), isNull);
  });
}
