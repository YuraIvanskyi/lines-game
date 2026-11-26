import 'package:ends/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// People who set a large system font still get every page without overflow.
void main() {
  for (final scale in [1.3, 2.0]) {
    for (final page in ['GAME MODE', 'HOW TO PLAY', 'PLAY', 'settings', 'info']) {
      testWidgets('$page at text scale $scale', (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.platformDispatcher.clearTextScaleFactorTestValue();
          tester.binding.setSurfaceSize(null);
        });
        await tester.pumpWidget(const EndsApp(seed: 1));
        await tester.pump();
        final target = switch (page) {
          'settings' => find.byIcon(Icons.settings),
          'info' => find.byIcon(Icons.priority_high),
          _ => find.text(page),
        };
        await tester.tap(target, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
