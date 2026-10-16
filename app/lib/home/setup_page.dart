import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

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
  late final List<TextEditingController> _names = [
    for (var i = 1; i <= 4; i++) TextEditingController(text: 'Player $i'),
  ];

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
    return typed.isEmpty ? 'Player ${index + 1}' : typed;
  }

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
                        child: PopButton(label: 'Back', onPressed: widget.onBack, color: InkTheme.blueFace, compact: true),
                      ),
                    ),
                    const PopTitle('Players', size: 40),
                    const SizedBox(height: 4),
                    PopBadge(widget.mode.name),
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
                                style: const TextStyle(fontWeight: FontWeight.w700, color: InkTheme.ink),
                                decoration: InputDecoration(
                                  labelText: 'Seat ${i + 1}',
                                  filled: true,
                                  fillColor: InkTheme.paper,
                                  labelStyle: TextStyle(color: InkTheme.inks[i], fontWeight: FontWeight.w800),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(color: InkTheme.ink, width: 3),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: InkTheme.inks[i], width: 3),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopButton(label: 'Start', onPressed: _start, color: InkTheme.greenFace),
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
