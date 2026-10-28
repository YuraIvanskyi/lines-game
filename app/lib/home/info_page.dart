import 'package:flutter/material.dart';

import '../legal_links.dart';
import '../settings/copy.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.onBack, this.onOpenLink = openLink});

  final VoidCallback onBack;
  final LinkOpener onOpenLink;

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
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PopBackButton(onPressed: onBack, label: copy.back),
                    ),
                    PopTitle(copy.info, size: 40),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Credit(copy.creator, [copy.creatorName]),
                            const SizedBox(height: 12),
                            _Credit(copy.tech, copy.techLines),
                            const SizedBox(height: 12),
                            _Credit(copy.assets, copy.assetLines),
                            const SizedBox(height: 12),
                            _LegalBlock(title: copy.legal, copy: copy, open: onOpenLink),
                            const SizedBox(height: 12),
                            _Credit(copy.thanks, [copy.thanksBody]),
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

class _LegalBlock extends StatelessWidget {
  const _LegalBlock({required this.title, required this.copy, required this.open});

  final String title;
  final Copy copy;
  final LinkOpener open;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: title,
      children: [
        _link(copy.privacyPolicy, () => open(LegalLinks.privacyPolicy)),
        _link(copy.termsOfUse, () => open(LegalLinks.termsOfUse)),
        _link(copy.support, () => open(LegalLinks.support)),
        _link(
          copy.licenses,
          () => showLicensePage(
            context: context,
            applicationName: 'ENDS',
            applicationLegalese: copy.creatorName,
          ),
        ),
      ],
    );
  }

  Widget _link(String label, VoidCallback onPressed) {
    return PopButton(label: label, compact: true, below: 8, color: InkTheme.blueFace, onPressed: onPressed);
  }
}

class _Credit extends StatelessWidget {
  const _Credit(this.title, this.lines);

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: title,
      children: [
        for (var i = 0; i < lines.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
            child: Text(
              lines[i],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: InkTheme.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: InkTheme.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }
}
