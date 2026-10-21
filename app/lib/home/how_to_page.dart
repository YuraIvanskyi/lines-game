import 'package:flutter/material.dart';

import '../settings/copy.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';
import 'play_snippet.dart';

class HowToPage extends StatelessWidget {
  const HowToPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final tips = [
      (demo: endsDemo, text: copy.tipEnds),
      (demo: tapDemo, text: copy.tipTap),
      (demo: lossDemo, text: copy.tipLoss),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ArcadeBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PopBackButton(onPressed: onDone, label: copy.back),
                    ),
                    PopTitle(copy.howTo, size: 40),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var i = 0; i < tips.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _Tip(demo: tips[i].demo, text: tips[i].text),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PopButton(label: copy.letsGo, onPressed: onDone),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.demo, required this.text});

  final HowToDemo demo;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: InkTheme.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(width: 128, height: 128, child: PlaySnippet(demo: demo)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: InkTheme.ink,
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
