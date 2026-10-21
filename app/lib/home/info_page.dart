import 'package:flutter/material.dart';

import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.onBack});

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
                    Align(alignment: Alignment.centerLeft, child: PopBackButton(onPressed: onBack)),
                    const PopTitle('Info', size: 40),
                    const SizedBox(height: 16),
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Credit('Creator', ['Yurii Ivanskyi']),
                            SizedBox(height: 12),
                            _Credit('Tech', ['Flutter and Dart']),
                            SizedBox(height: 12),
                            _Credit('Assets', [
                              'Nunito by The Nunito Project Authors. SIL Open Font License 1.1.',
                              'Material Icons by Google. Apache License 2.0.',
                              'Sounds made for this game.',
                            ]),
                          ],
                        ),
                      ),
                    ),
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

class _Credit extends StatelessWidget {
  const _Credit(this.title, this.lines);

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: InkTheme.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: InkTheme.ink, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  line,
                  style: const TextStyle(color: InkTheme.ink, fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
