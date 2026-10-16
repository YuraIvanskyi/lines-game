import 'package:flutter/material.dart';

import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class HowToPage extends StatelessWidget {
  const HowToPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
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
                      child: SizedBox(
                        width: 140,
                        child: PopButton(label: 'Back', onPressed: onDone, color: InkTheme.blueFace, compact: true),
                      ),
                    ),
                    const PopTitle('How to play', size: 40),
                    const SizedBox(height: 20),
                    const _Tip(
                      swatch: InkTheme.ink,
                      shape: BoxShape.circle,
                      text: 'Grow the line from either end. The ring is the head. The square is the tail.',
                    ),
                    const SizedBox(height: 12),
                    const _Tip(swatch: InkTheme.target, shape: BoxShape.circle, text: 'Tap a marked dot.'),
                    const SizedBox(height: 12),
                    const _Tip(swatch: InkTheme.sun, shape: BoxShape.rectangle, text: 'The player who cannot grow loses.'),
                    const Spacer(),
                    PopButton(label: "Let's go", onPressed: onDone),
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
  const _Tip({required this.swatch, required this.shape, required this.text});

  final Color swatch;
  final BoxShape shape;
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: swatch,
                shape: shape,
                borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: const TextStyle(color: InkTheme.ink, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
