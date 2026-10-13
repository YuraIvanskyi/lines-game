import 'package:flutter/material.dart';

import 'ink_theme.dart';

class ArcadeBackdrop extends StatelessWidget {
  const ArcadeBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [InkTheme.skyTop, InkTheme.skyBottom],
        ),
      ),
      child: Stack(
        children: [
          const IgnorePointer(child: _Blobs()),
          child,
        ],
      ),
    );
  }
}

class _Blobs extends StatelessWidget {
  const _Blobs();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(top: -36, left: -28, child: _Blob(size: 140, color: InkTheme.foam)),
        Positioned(top: 120, right: -24, child: _Blob(size: 96, color: InkTheme.sunGlow)),
        Positioned(bottom: 24, left: -16, child: _Blob(size: 160, color: InkTheme.foam)),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class PopButton extends StatelessWidget {
  const PopButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = InkTheme.sun,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(color: InkTheme.ink, borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: InkTheme.ink,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: compact ? 12 : 18),
              textStyle: TextStyle(fontSize: compact ? 18 : 22, fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: const BorderSide(color: InkTheme.ink, width: 3),
              ),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class PopBadge extends StatelessWidget {
  const PopBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: InkTheme.sun,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: InkTheme.ink, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(text, style: const TextStyle(color: InkTheme.ink, fontSize: 16, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class PopNote extends StatelessWidget {
  const PopNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: InkTheme.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InkTheme.ink, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(color: InkTheme.ink, fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class PopTitle extends StatelessWidget {
  const PopTitle(this.text, {super.key, this.size = 64});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontWeight: FontWeight.w900, height: 1);
    return Stack(
      children: [
        Text(text, style: style.copyWith(fontSize: size, color: InkTheme.ink)),
        Transform.translate(
          offset: const Offset(-3, -3),
          child: Text(text, style: style.copyWith(fontSize: size, color: InkTheme.cloud)),
        ),
      ],
    );
  }
}
