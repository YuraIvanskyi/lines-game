import 'dart:async';

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
  final Future<void> Function(AppSettings settings) onSave;
  final VoidCallback onBack;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _sound = widget.settings.sound;
  late AppLanguage _language = widget.settings.language;
  bool _saved = false;
  Timer? _savedTimer;

  @override
  void dispose() {
    _savedTimer?.cancel();
    super.dispose();
  }

  void _change(VoidCallback change) {
    _savedTimer?.cancel();
    setState(() {
      change();
      _saved = false;
    });
  }

  Future<void> _save() async {
    await widget.onSave(AppSettings(sound: _sound, language: _language));
    if (!mounted) return;
    _savedTimer?.cancel();
    setState(() => _saved = true);
    _savedTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _saved = false);
    });
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
                    PopBlock(
                      title: copy.sound,
                      child: Align(
                        alignment: Alignment.center,
                        child: PopIconButton(
                          icon: _sound ? Icons.volume_up : Icons.volume_off,
                          label: _sound ? copy.soundOn : copy.soundOff,
                          onPressed: () => _change(() => _sound = !_sound),
                          extent: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PopBlock(
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
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PopSavedChip(label: copy.saved, visible: _saved),
                        ),
                      ),
                    ),
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
      onPressed: () => _change(() => _language = language),
    );
  }
}
