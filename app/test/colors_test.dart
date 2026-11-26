import 'package:ends/main.dart';
import 'package:ends/settings/game_setup.dart';
import 'package:ends/table/board_view.dart';
import 'package:ends/table/table_page.dart';
import 'package:ends/theme/ink_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rules/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget wrapped in Semantics with this exact label (the swatches and palette colors).
Finder _labelled(String label) =>
    find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == label);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  final open = [classicMode.copyWith(wallChance: 0), starsMode.copyWith(wallChance: 0)];

  test('the palette has a slot for every color and the defaults are the old seat inks', () {
    expect(InkTheme.palette, hasLength(paletteSize));
    expect(InkTheme.palette.toSet(), hasLength(paletteSize));
    expect(InkTheme.inks, InkTheme.palette.sublist(0, 4));
    expect(GameSetup.defaults.colors, [0, 1, 2, 3]);
  });

  test('picking a color another seat has swaps the two', () {
    expect(pickColor([0, 1, 2, 3], 0, 5), [5, 1, 2, 3]);
    expect(pickColor([0, 1, 2, 3], 0, 2), [2, 1, 0, 3]);
    expect(pickColor([0, 1, 2, 3], 1, 1), [0, 1, 2, 3]);
  });

  test('stored colors are cleaned into one distinct valid slot per seat', () {
    expect(cleanColors(null), [0, 1, 2, 3]);
    expect(cleanColors([5, 5, 9, -1, 7]), [5, 7, 0, 1]);
    expect(cleanColors([3, 2, 1, 0, 4]), [3, 2, 1, 0]);
  });

  test('colors survive the store, and junk reads back as something usable', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPrefsGameSetupStore();
    await store.save(const GameSetup(colors: [6, 0, 4, 1]));
    expect((await store.load()).colors, [6, 0, 4, 1]);

    SharedPreferences.setMockInitialValues({SharedPrefsGameSetupStore.colorsKey: ['x', '3', '3']});
    expect((await SharedPrefsGameSetupStore().load()).colors, [3, 0, 1, 2]);
  });

  testWidgets('a seat picks a color, a clash swaps, and the table draws with them', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = MemoryGameSetupStore();
    await tester.pumpWidget(EndsApp(seed: 1, modes: open, setupStore: store));
    await tester.tap(find.text('GAME MODE'));
    await _settle(tester);

    // Seat 1 opens its palette and takes violet.
    await tester.ensureVisible(_labelled('Color: Pink'));
    await _settle(tester);
    await tester.tap(_labelled('Color: Pink'));
    await _settle(tester);
    expect(_labelled('Mint, taken by Player 2'), findsOneWidget);
    await tester.ensureVisible(_labelled('Violet'));
    await _settle(tester);
    await tester.tap(_labelled('Violet'));
    await _settle(tester);
    expect(_labelled('Violet'), findsNothing, reason: 'the palette closes after a pick');
    expect(_labelled('Color: Violet'), findsOneWidget);

    // Seat 2 asks for violet too: the two seats swap.
    await tester.ensureVisible(_labelled('Color: Mint'));
    await _settle(tester);
    await tester.tap(_labelled('Color: Mint'));
    await _settle(tester);
    await tester.ensureVisible(_labelled('Violet, taken by Player 1'));
    await _settle(tester);
    await tester.tap(_labelled('Violet, taken by Player 1'));
    await _settle(tester);
    expect(_labelled('Color: Mint'), findsOneWidget);
    expect(_labelled('Color: Violet'), findsOneWidget);

    await tester.tap(find.text('SAVE'));
    await _settle(tester);
    expect((await store.load()).colors, [1, 5, 2, 3]);

    await tester.tap(find.text('PLAY'));
    await _settle(tester);
    final table = tester.widget<TablePage>(find.byType(TablePage));
    expect(table.inks, [InkTheme.palette[1], InkTheme.palette[5]]);
    final painter = tester
        .widget<CustomPaint>(find.descendant(of: find.byType(BoardView), matching: find.byType(CustomPaint)))
        .painter! as BoardPainter;
    expect(painter.inks, table.inks);
  });

  testWidgets('the computer seat has a color too', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      EndsApp(seed: 1, modes: open, initialSetup: const GameSetup(opponent: Opponent.computer, colors: [2, 6, 0, 1])),
    );
    await tester.tap(find.text('GAME MODE'));
    await _settle(tester);
    await tester.ensureVisible(_labelled('Color: Lime'));
    await tester.tap(_labelled('Color: Lime'));
    await _settle(tester);
    expect(_labelled('Gold, taken by Player 1'), findsOneWidget);
    // Seats 3 and 4 are not at this table, so their colors read as free.
    expect(_labelled('Pink'), findsOneWidget);
  });
}
