import 'package:flutter/material.dart';

import '../settings/copy.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onPlay,
    required this.onSetup,
    required this.onHowTo,
    required this.onSettings,
    required this.onInfo,
    required this.onStore,
    required this.onExit,
  });

  final VoidCallback onPlay;
  final VoidCallback onSetup;
  final VoidCallback onHowTo;
  final VoidCallback onSettings;
  final VoidCallback onInfo;
  final VoidCallback onStore;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
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
                    const PopTitle('ENDS'),
                    const SizedBox(height: 12),
                    PopBadge(copy.classic),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const count = 4;
                        const gapFactor = 0.36;
                        final side = (constraints.maxWidth / (count + (count - 1) * gapFactor) * 100).floorToDouble() / 100;
                        final gap = (constraints.maxWidth - side * count) / (count - 1);
                        final icons = <({IconData icon, String label, Color color, VoidCallback onPressed})>[
                          (icon: Icons.settings, label: copy.settings, color: InkTheme.blueFace, onPressed: onSettings),
                          (icon: Icons.priority_high, label: copy.info, color: InkTheme.blueFace, onPressed: onInfo),
                          (icon: Icons.favorite, label: copy.store, color: InkTheme.pinkFace, onPressed: onStore),
                          (icon: Icons.logout, label: copy.exit, color: InkTheme.blueFace, onPressed: onExit),
                        ];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PopButton(label: copy.play, onPressed: onPlay, extent: side, below: gap),
                            PopButton(label: copy.howTo, onPressed: onHowTo, color: InkTheme.blueFace, compact: true, extent: side, below: gap),
                            PopButton(label: copy.players, onPressed: onSetup, color: InkTheme.greenFace, compact: true, extent: side, below: gap),
                            Row(
                              children: [
                                for (var i = 0; i < icons.length; i++) ...[
                                  if (i > 0) SizedBox(width: gap),
                                  PopIconButton(
                                    icon: icons[i].icon,
                                    label: icons[i].label,
                                    color: icons[i].color,
                                    onPressed: icons[i].onPressed,
                                    extent: side,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        );
                      },
                    ),
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
