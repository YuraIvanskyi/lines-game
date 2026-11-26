import 'package:ends/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rules/rules.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  final open = classicMode.copyWith(wallChance: 0);

  testWidgets('the system back gesture asks before leaving a live game', (tester) async {
    await tester.pumpWidget(EndsApp(seed: 1, mode: open));
    await tester.tap(find.text('PLAY'));
    await _settle(tester);
    expect(find.text("Player 1's turn"), findsOneWidget);

    // Android back button / predictive back gesture.
    await tester.binding.handlePopRoute();
    await _settle(tester);
    expect(find.text('Leaving so soon?'), findsOneWidget);
    expect(find.text("Player 1's turn"), findsOneWidget);

    await tester.tap(find.text('KEEP PLAYING'));
    await _settle(tester);
    expect(find.text("Player 1's turn"), findsOneWidget);

    await tester.binding.handlePopRoute();
    await _settle(tester);
    await tester.tap(find.text('LEAVE'));
    await _settle(tester);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('the system back gesture leaves menus straight away', (tester) async {
    await tester.pumpWidget(EndsApp(seed: 1, mode: open));
    await tester.tap(find.text('GAME MODE'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
  });
}
