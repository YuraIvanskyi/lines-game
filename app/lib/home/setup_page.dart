import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../settings/copy.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key, required this.mode, required this.onStart, required this.onBack});

  final GameMode mode;
  final ValueChanged<List<Player>> onStart;
  final VoidCallback onBack;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int _count = 2;
  final List<TextEditingController> _names = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_names.isNotEmpty) return;
    final copy = AppCopy.of(context);
    for (var i = 1; i <= 4; i++) {
      _names.add(TextEditingController(text: copy.player(i)));
    }
  }

  @override
  void dispose() {
    for (final name in _names) {
      name.dispose();
    }
    super.dispose();
  }

  void _start() {
    widget.onStart([
      for (var i = 0; i < _count; i++)
        Player(id: 'p${i + 1}', name: _seatName(i)),
    ]);
  }

  String _seatName(int index) {
    final typed = _names[index].text.trim();
    return typed.isEmpty ? AppCopy.of(context).player(index + 1) : typed;
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
                    PopTitle(copy.players, size: 40),
                    const SizedBox(height: 4),
                    PopBadge(widget.mode.id == classicModeId ? copy.classic : widget.mode.name),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        for (final count in [2, 3, 4]) ...[
                          if (count != 2) const SizedBox(width: 8),
                          Expanded(
                            child: PopButton(
                              label: '$count',
                              compact: true,
                              color: _count == count ? InkTheme.sun : InkTheme.blueFace,
                              onPressed: () => setState(() => _count = count),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          for (var i = 0; i < _count; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                controller: _names[i],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: InkTheme.ink),
                                cursorColor: InkTheme.inks[i],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color.lerp(InkTheme.inks[i], Colors.white, 0.68),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  prefixIcon: ExcludeSemantics(
                                    child: Icon(Icons.edit, color: InkTheme.inks[i], size: 22),
                                  ),
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
                      ),
                    ),
                    PopButton(label: copy.start, onPressed: _start, color: InkTheme.greenFace),
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

OutlineInputBorder _seatBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: 3),
  );
}
