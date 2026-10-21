import 'package:flutter/material.dart';

import '../settings/copy.dart';
import 'arcade_shell.dart';
import 'ink_theme.dart';

class ArcadeDialog extends StatelessWidget {
  const ArcadeDialog({super.key, required this.title, required this.body, required this.actions});

  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: InkTheme.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: InkTheme.sun, width: 4),
      ),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: InkTheme.cloud, fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: InkTheme.muted, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              ...actions,
            ],
          ),
      ),
    );
  }
}

Future<bool> confirmLeave(BuildContext context) async {
  final copy = AppCopy.of(context);
  final leave = await showDialog<bool>(
    context: context,
    builder: (context) => ArcadeDialog(
      title: copy.leaveTitle,
      body: copy.leaveBody,
      actions: [
        PopButton(label: copy.stay, color: InkTheme.blueFace, onPressed: () => Navigator.pop(context, false)),
        PopButton(label: copy.leave, onPressed: () => Navigator.pop(context, true)),
      ],
    ),
  );
  return leave ?? false;
}
