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
          colors: [InkTheme.skyTop, Color(0xFF1565D8), InkTheme.skyBottom],
        ),
      ),
      child: Stack(
        children: [
          const IgnorePointer(child: CustomPaint(painter: _ArenaPainter(), child: SizedBox.expand())),
          child,
        ],
      ),
    );
  }
}

class _ArenaPainter extends CustomPainter {
  const _ArenaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final wash = Paint()..color = const Color(0x14000000);
    final gloss = Paint()..color = const Color(0x22FFFFFF);
    final path = Path()
      ..moveTo(0, size.height * 0.15)
      ..lineTo(size.width * 0.45, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, wash);
    final shard = Path()
      ..moveTo(size.width, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.62)
      ..lineTo(size.width * 0.62, size.height * 0.4)
      ..close();
    canvas.drawPath(shard, gloss);
    final hex = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33FFFFFF);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.18), 54, hex);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.72), 72, hex);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PopButton extends StatefulWidget {
  const PopButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = InkTheme.sun,
    this.deep,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color? deep;
  final bool compact;

  @override
  State<PopButton> createState() => _PopButtonState();
}

class _PopButtonState extends State<PopButton> {
  bool _down = false;

  Color get _deep => widget.deep ?? _pair(widget.color).$1;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.compact ? 18 : 22);
    final face = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(vertical: widget.compact ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(widget.color, Colors.white, 0.28)!, widget.color, _deep],
        ),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Center(child: OutlineLabel(widget.label.toUpperCase(), size: widget.compact ? 18 : 24)),
    );

    return Semantics(
      button: true,
      label: widget.label,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) {
            setState(() => _down = false);
            widget.onPressed();
          },
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black, borderRadius: radius),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Transform.translate(offset: Offset(0, _down ? 5 : 0), child: face),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineLabel extends StatelessWidget {
  const OutlineLabel(this.text, {super.key, required this.size, this.stroke = 3});

  final String text;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final ring = <Shadow>[
      for (final offset in const [
        Offset(-1.4, -1.4),
        Offset(0, -1.6),
        Offset(1.4, -1.4),
        Offset(-1.6, 0),
        Offset(1.6, 0),
        Offset(-1.4, 1.4),
        Offset(0, 1.6),
        Offset(1.4, 1.4),
      ])
        Shadow(color: Colors.black, offset: offset * (stroke / 3), blurRadius: 0),
    ];
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
        height: 1,
        color: InkTheme.cloud,
        shadows: ring,
      ),
    );
  }
}

(Color, Color) _pair(Color color) {
  if (color == InkTheme.blueFace) return (InkTheme.blueDeep, InkTheme.blueLip);
  if (color == InkTheme.greenFace) return (InkTheme.greenDeep, InkTheme.greenLip);
  if (color == InkTheme.sun) return (InkTheme.sunDeep, InkTheme.sunLip);
  final deep = Color.lerp(color, Colors.black, 0.18)!;
  final lip = Color.lerp(color, Colors.black, 0.38)!;
  return (deep, lip);
}

class PopBadge extends StatelessWidget {
  const PopBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: InkTheme.sun,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: OutlineLabel(text.toUpperCase(), size: 14),
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
        border: Border.all(color: Colors.black, width: 3),
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
    return Align(alignment: Alignment.center, child: OutlineLabel(text.toUpperCase(), size: size, stroke: 6));
  }
}
