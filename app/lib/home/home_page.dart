import 'package:flutter/material.dart';

import '../settings/copy.dart';
import '../settings/game_setup.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.modeLabel,
    required this.setup,
    required this.onPlay,
    required this.onHowTo,
    required this.onGameMode,
    required this.onSettings,
    required this.onInfo,
    required this.onStore,
    this.onExit,
  });

  final String modeLabel;
  final GameSetup setup;
  final VoidCallback onPlay;
  final VoidCallback onHowTo;
  final VoidCallback onGameMode;
  final VoidCallback onSettings;
  final VoidCallback onInfo;
  final VoidCallback onStore;

  /// Null hides the Exit button (iOS: apps must not quit themselves).
  final VoidCallback? onExit;

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
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PopBadge(modeLabel),
                        PopBadge(
                          setup.vsComputer ? copy.difficultyName(setup.difficulty) : copy.playerCount(setup.seatCount),
                          icon: _opponentIcon(setup.opponent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final exit = onExit;
                        final icons = <({IconData icon, String label, Color color, VoidCallback onPressed})>[
                          (icon: Icons.settings, label: copy.settings, color: InkTheme.blueFace, onPressed: onSettings),
                          (icon: Icons.priority_high, label: copy.info, color: InkTheme.blueFace, onPressed: onInfo),
                          (icon: Icons.favorite, label: copy.store, color: InkTheme.pinkFace, onPressed: onStore),
                          if (exit != null) (icon: Icons.logout, label: copy.exit, color: InkTheme.blueFace, onPressed: exit),
                        ];
                        // Sizes come from four slots so the menu keeps its proportions; when Exit is
                        // hidden the remaining icons spread to the same edges with wider gaps.
                        const slots = 4;
                        const gapFactor = 0.36;
                        final side = (constraints.maxWidth / (slots + (slots - 1) * gapFactor) * 100).floorToDouble() / 100;
                        final gap = (constraints.maxWidth - side * slots) / (slots - 1);
                        final iconGap = (constraints.maxWidth - side * icons.length) / (icons.length - 1);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PopButton(label: copy.play, onPressed: onPlay, extent: side, below: gap),
                            PopButton(label: copy.howTo, onPressed: onHowTo, color: InkTheme.blueFace, compact: true, extent: side, below: gap),
                            PopButton(label: copy.gameMode, onPressed: onGameMode, color: InkTheme.greenFace, compact: true, extent: side, below: gap),
                            Row(
                              children: [
                                for (var i = 0; i < icons.length; i++) ...[
                                  if (i > 0) SizedBox(width: iconGap),
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

IconData _opponentIcon(Opponent opponent) {
  return switch (opponent) {
    Opponent.samePhone => Icons.people,
    Opponent.computer => Icons.computer,
    Opponent.online => Icons.public,
  };
}
