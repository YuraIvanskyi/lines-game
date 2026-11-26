import 'package:ends/theme/card_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Six 200-tall cards with 12 between them, in a 400-tall viewport. Card i's top sits at
/// 10 + 212 * i in the content, so it rests just under the 20 px fade at offset 212 * i - 10.
const _cards = 6;
const _snapGap = 212.0;

Future<ScrollController> _mount(WidgetTester tester) async {
  final controller = ScrollController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            height: 400,
            child: CardScroll(
              controller: controller,
              children: [
                for (var i = 0; i < _cards; i++)
                  Container(key: ValueKey(i), height: 200, color: Colors.primaries[i]),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return controller;
}

/// Whether [offset] is a card rest point or one of the two ends.
bool _onCardEdge(ScrollController controller, double offset) {
  final max = controller.position.maxScrollExtent;
  if ((offset - max).abs() < 0.5 || offset.abs() < 0.5) return true;
  final card = (offset + 10) / _snapGap;
  return (card - card.round()).abs() * _snapGap < 0.5;
}

void main() {
  testWidgets('a fling comes to rest on a card edge', (tester) async {
    final controller = await _mount(tester);
    for (final speed in [600.0, 1500.0, 3000.0]) {
      controller.jumpTo(0);
      await tester.pump();
      await tester.fling(find.byType(CardScroll), const Offset(0, -180), speed);
      await tester.pumpAndSettle();
      expect(_onCardEdge(controller, controller.offset), isTrue, reason: 'speed $speed stopped at ${controller.offset}');
      expect(controller.offset, greaterThan(0));
    }
  });

  testWidgets('a slow drag let go between cards settles on the nearer one', (tester) async {
    final controller = await _mount(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.byType(CardScroll)));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -27));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    // About 270 dragged: card 1 rests at 202, card 2 at 414, so 202 is nearer.
    expect(controller.offset, closeTo(_snapGap - 10, 0.5));
  });

  testWidgets('scrolling from code is not pulled onto a card', (tester) async {
    final controller = await _mount(tester);
    controller.animateTo(300, duration: const Duration(milliseconds: 200), curve: Curves.linear);
    await tester.pumpAndSettle();
    expect(controller.offset, 300);
    controller.jumpTo(123);
    await tester.pumpAndSettle();
    expect(controller.offset, 123);
  });

  testWidgets('pulling past the top bounces back instead of stopping dead', (tester) async {
    final controller = await _mount(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.byType(CardScroll)));
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump(const Duration(milliseconds: 50));
    expect(controller.offset, lessThan(0), reason: 'the list stretches past its top');
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });

  testWidgets('edges fade only where there is more to see', (tester) async {
    final controller = await _mount(tester);
    final mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
    LinearGradient gradient() => _gradientOf(tester);
    expect(mask.blendMode, BlendMode.dstIn);
    // At the top: nothing hidden above, plenty below.
    expect(gradient().colors.first.a, 1);
    expect(gradient().colors.last.a, 0);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(gradient().colors.first.a, 0);
    expect(gradient().colors.last.a, 1);
  });
}

/// Rebuilds the mask's gradient the same way CardScroll does, through its shader callback.
LinearGradient _gradientOf(WidgetTester tester) {
  final state = tester.state(find.byType(CardScroll));
  return (state as dynamic).edgeGradient(const Rect.fromLTWH(0, 0, 300, 400)) as LinearGradient;
}
