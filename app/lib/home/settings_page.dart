import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../settings/copy.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.settings,
    required this.onSave,
    required this.onBack,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onSave;
  final VoidCallback onBack;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _sound = widget.settings.sound;
  late AppLanguage _language = widget.settings.language;

  void _save() {
    widget.onSave(AppSettings(sound: _sound, language: _language));
  }

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
                      child: PopBackButton(onPressed: widget.onBack, label: copy.back),
                    ),
                    PopTitle(copy.settings, size: 40),
                    const SizedBox(height: 16),
                    _Block(
                      title: copy.sound,
                      child: Align(
                        alignment: Alignment.center,
                        child: PopIconButton(
                          icon: _sound ? Icons.volume_up : Icons.volume_off,
                          label: _sound ? copy.soundOn : copy.soundOff,
                          onPressed: () => setState(() => _sound = !_sound),
                          extent: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Block(
                      title: copy.languages,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final language in AppLanguage.values) ...[
                            if (language != AppLanguage.values.first) const SizedBox(height: 8),
                            _languageButton(language),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    PopButton(label: copy.save, color: InkTheme.greenFace, onPressed: _save),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageButton(AppLanguage language) {
    final selected = _language == language;
    return PopButton(
      label: language.endonym,
      compact: true,
      below: 0,
      color: selected ? InkTheme.sun : InkTheme.blueFace,
      onPressed: () => setState(() => _language = language),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});

  final String title;
  final Widget child;

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
              style: const TextStyle(color: InkTheme.ink, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
