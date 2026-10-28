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

const _lip = 4.0;

const _iconHalo = <Shadow>[
  Shadow(color: Colors.black, offset: Offset(-1.1, -1.1)),
  Shadow(color: Colors.black, offset: Offset(0, -1.3)),
  Shadow(color: Colors.black, offset: Offset(1.1, -1.1)),
  Shadow(color: Colors.black, offset: Offset(-1.3, 0)),
  Shadow(color: Colors.black, offset: Offset(1.3, 0)),
  Shadow(color: Colors.black, offset: Offset(-1.1, 1.1)),
  Shadow(color: Colors.black, offset: Offset(0, 1.3)),
  Shadow(color: Colors.black, offset: Offset(1.1, 1.1)),
];

class PopButton extends StatefulWidget {
  const PopButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = InkTheme.sun,
    this.deep,
    this.compact = false,
    this.extent,
    this.below = 8,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color? deep;
  final bool compact;
  final double? extent;
  final double below;
  final bool enabled;

  @override
  State<PopButton> createState() => _PopButtonState();
}

class _PopButtonState extends State<PopButton> {
  bool _down = false;

  Color get _color => widget.enabled ? widget.color : InkTheme.mute;

  Color get _deep => widget.enabled ? (widget.deep ?? _pair(widget.color).$1) : _pair(InkTheme.mute).$1;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.extent != null ? widget.extent! * 0.26 : (widget.compact ? 18 : 22));
    final face = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
      height: widget.extent,
      padding: EdgeInsets.symmetric(vertical: widget.extent == null ? (widget.compact ? 12 : 16) : 0),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(_color, Colors.white, 0.28)!, _color, _deep],
        ),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Center(child: OutlineLabel(widget.label.toUpperCase(), size: widget.compact ? 22 : 28)),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.below),
        child: GestureDetector(
          onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
          onTapCancel: () => setState(() => _down = false),
          onTapUp: widget.enabled
              ? (_) {
                  setState(() => _down = false);
                  widget.onPressed();
                }
              : null,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black, borderRadius: radius),
            child: Padding(
              padding: const EdgeInsets.only(bottom: _lip),
              child: Transform.translate(offset: Offset(0, _down ? _lip - 1 : 0), child: face),
            ),
          ),
        ),
      ),
    );
  }
}

class PopIconButton extends StatefulWidget {
  const PopIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.extent,
    this.color = InkTheme.blueFace,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double extent;
  final Color color;

  @override
  State<PopIconButton> createState() => _PopIconButtonState();
}

class _PopIconButtonState extends State<PopIconButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.extent * 0.26);
    final deep = _pair(widget.color).$1;
    final face = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
      width: widget.extent,
      height: widget.extent,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(widget.color, Colors.white, 0.28)!, widget.color, deep],
        ),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Center(child: Icon(widget.icon, size: widget.extent * 0.46, color: InkTheme.cloud, shadows: _iconHalo)),
    );

    return Semantics(
      button: true,
      label: widget.label,
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
            padding: const EdgeInsets.only(bottom: _lip),
            child: Transform.translate(offset: Offset(0, _down ? _lip - 1 : 0), child: face),
          ),
        ),
      ),
    );
  }
}

class PopBackButton extends StatelessWidget {
  const PopBackButton({super.key, required this.onPressed, this.label = 'Back'});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PopIconButton(icon: Icons.arrow_back, label: label, onPressed: onPressed, extent: 56),
    );
  }
}

class OutlineLabel extends StatelessWidget {
  const OutlineLabel(this.text, {super.key, required this.size, this.stroke = 2.5});

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
  if (color == InkTheme.pinkFace) return (InkTheme.pinkDeep, InkTheme.pinkLip);
  if (color == InkTheme.sun) return (InkTheme.sunDeep, InkTheme.sunLip);
  final deep = Color.lerp(color, Colors.black, 0.18)!;
  final lip = Color.lerp(color, Colors.black, 0.38)!;
  return (deep, lip);
}

class PopBadge extends StatelessWidget {
  const PopBadge(this.text, {super.key, this.icon});

  final String text;
  final IconData? icon;

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                ExcludeSemantics(child: Icon(icon, size: 18, color: InkTheme.cloud, shadows: _iconHalo)),
                const SizedBox(width: 6),
              ],
              OutlineLabel(text.toUpperCase(), size: 14),
            ],
          ),
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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: OutlineLabel(text.toUpperCase(), size: size, stroke: 5),
    );
  }
}

class PopBlock extends StatelessWidget {
  const PopBlock({super.key, required this.title, required this.child});

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

class PopSavedChip extends StatelessWidget {
  const PopSavedChip({super.key, required this.label, required this.visible});

  final String label;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: visible ? label : null,
      child: ExcludeSemantics(
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          offset: visible ? Offset.zero : const Offset(0, 0.6),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: visible ? 1 : 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: InkTheme.greenFace,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, size: 22, color: InkTheme.cloud),
                    const SizedBox(width: 6),
                    OutlineLabel(label.toUpperCase(), size: 18),
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
