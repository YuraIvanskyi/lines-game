import 'package:flutter/material.dart';

import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.showFirstGameNote,
    required this.onPlay,
    required this.onSetup,
    required this.onHowTo,
    required this.onSkipHowTo,
  });

  final bool showFirstGameNote;
  final VoidCallback onPlay;
  final VoidCallback onSetup;
  final VoidCallback onHowTo;
  final VoidCallback onSkipHowTo;

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const PopTitle('Lines'),
                    const SizedBox(height: 12),
                    const PopBadge('Classic'),
                    const SizedBox(height: 28),
                    PopButton(label: 'Play', onPressed: onPlay),
                    if (showFirstGameNote) ...[
                      const SizedBox(height: 10),
                      const PopNote('The line grows from either end.'),
                      const SizedBox(height: 10),
                      PopButton(label: 'Skip', onPressed: onSkipHowTo, color: InkTheme.blueFace, compact: true),
                    ],
                    PopButton(label: 'How to play', onPressed: onHowTo, color: InkTheme.blueFace, compact: true),
                    PopButton(label: 'Players', onPressed: onSetup, color: InkTheme.greenFace, compact: true),
                    const Spacer(),
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
