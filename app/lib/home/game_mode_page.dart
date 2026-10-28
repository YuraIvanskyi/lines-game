import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../settings/copy.dart';
import '../settings/game_setup.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class GameModePage extends StatefulWidget {
  const GameModePage({
    super.key,
    required this.mode,
    required this.setup,
    required this.onSave,
    required this.onBack,
  });

  final GameMode mode;
  final GameSetup setup;
  final Future<void> Function(GameSetup setup) onSave;
  final VoidCallback onBack;

  @override
  State<GameModePage> createState() => _GameModePageState();
}

class _GameModePageState extends State<GameModePage> {
  late Opponent _opponent = widget.setup.opponent;
  late int _count = widget.setup.playerCount;
  final List<TextEditingController> _names = [];
  bool _saved = false;
  Timer? _savedTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_names.isNotEmpty) return;
    final copy = AppCopy.of(context);
    for (var i = 0; i < maxPlayers; i++) {
      final stored = widget.setup.names[i];
      _names.add(TextEditingController(text: stored.isEmpty ? copy.player(i + 1) : stored));
    }
  }

  @override
  void dispose() {
    _savedTimer?.cancel();
    for (final name in _names) {
      name.dispose();
    }
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
    final copy = AppCopy.of(context);
    // A name left at its default keeps following the app language.
    final names = [
      for (var i = 0; i < maxPlayers; i++)
        _names[i].text.trim() == copy.player(i + 1) ? '' : _names[i].text.trim(),
    ];
    await widget.onSave(GameSetup(opponent: _opponent, playerCount: _count, names: names));
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
                    Align(alignment: Alignment.centerLeft, child: PopBackButton(onPressed: widget.onBack, label: copy.back)),
                    PopTitle(copy.gameMode, size: 40),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PopBlock(
                              title: copy.mode,
                              child: PopButton(
                                label: widget.mode.id == classicModeId ? copy.classic : widget.mode.name,
                                compact: true,
                                below: 0,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 12),
                            PopBlock(
                              title: copy.opponent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _opponentButton(Opponent.samePhone, copy.sameScreen, available: true),
                                  const SizedBox(height: 8),
                                  _opponentButton(Opponent.computer, copy.computer, available: false),
                                  const SizedBox(height: 8),
                                  _opponentButton(Opponent.online, copy.online, available: false),
                                  const SizedBox(height: 12),
                                  Text(
                                    copy.comingSoon,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: InkTheme.ink, fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            if (_opponent == Opponent.samePhone) ...[
                              const SizedBox(height: 12),
                              PopBlock(title: copy.players, child: _players()),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Align(alignment: Alignment.bottomCenter, child: PopSavedChip(label: copy.saved, visible: _saved)),
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

  Widget _opponentButton(Opponent opponent, String label, {required bool available}) {
    return PopButton(
      label: label,
      compact: true,
      below: 0,
      enabled: available,
      color: _opponent == opponent ? InkTheme.sun : InkTheme.blueFace,
      onPressed: () => _change(() => _opponent = opponent),
    );
  }

  Widget _players() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var count = minPlayers; count <= maxPlayers; count++) ...[
              if (count != minPlayers) const SizedBox(width: 8),
              Expanded(
                child: PopButton(
                  label: '$count',
                  compact: true,
                  below: 0,
                  color: _count == count ? InkTheme.sun : InkTheme.blueFace,
                  onPressed: () => _change(() => _count = count),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _count; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == _count - 1 ? 0 : 8),
            child: TextField(
              controller: _names[i],
              textAlign: TextAlign.center,
              onChanged: (_) => _change(() {}),
              style: const TextStyle(fontWeight: FontWeight.w700, color: InkTheme.ink),
              cursorColor: InkTheme.inks[i],
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.lerp(InkTheme.inks[i], Colors.white, 0.68),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: ExcludeSemantics(child: Icon(Icons.edit, color: InkTheme.inks[i], size: 22)),
                prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                suffixIcon: const SizedBox.shrink(),
                suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                enabledBorder: _seatBorder(InkTheme.ink),
                focusedBorder: _seatBorder(InkTheme.inks[i]),
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
      ],
    );
  }
}

OutlineInputBorder _seatBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: 3),
  );
}
