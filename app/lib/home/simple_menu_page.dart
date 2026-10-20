import 'package:flutter/material.dart';

import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class SimpleMenuPage extends StatelessWidget {
  const SimpleMenuPage({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

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
                        child: PopButton(label: 'Back', onPressed: onBack, color: InkTheme.blueFace, compact: true),
                      ),
                    ),
                    PopTitle(title, size: 40),
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
