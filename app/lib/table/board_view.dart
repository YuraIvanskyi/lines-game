import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../theme/ink_theme.dart';

class BoardView extends StatefulWidget {
  const BoardView({super.key, required this.match, required this.pendingCell, required this.onCell});

  final Match match;
  final int? pendingCell;
  final ValueChanged<int?> onCell;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> with TickerProviderStateMixin {
  late final AnimationController _draw;
  late final AnimationController _pulse;
  late final AnimationController _end;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(vsync: this, duration: InkTheme.drawDuration);
    _pulse = AnimationController(vsync: this, duration: InkTheme.pulseDuration)..repeat(reverse: true);
    _end = AnimationController(vsync: this, duration: InkTheme.endDuration)..value = 1;
    if (widget.match.segments.isNotEmpty) _draw.value = 1;
    if (widget.match.isTerminal) _pulse.stop();
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.match.segments.length != oldWidget.match.segments.length) {
      _draw.forward(from: 0);
    }
    if (widget.match.head != oldWidget.match.head || widget.match.tail != oldWidget.match.tail) {
      _end.forward(from: 0);
    }
    if (widget.match.isTerminal) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    _pulse.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_draw, _pulse, _end]),
      builder: (context, _) {
        return GestureDetector(
          onTapUp: (details) {
            final box = context.findRenderObject()! as RenderBox;
            widget.onCell(cellAt(widget.match, box.size, details.localPosition));
          },
          child: RepaintBoundary(
            child: CustomPaint(
              painter: BoardPainter(
                match: widget.match,
                pendingCell: widget.pendingCell,
                draw: InkTheme.drawCurve.transform(_draw.value),
                showTargets: _draw.status != AnimationStatus.forward,
                pulse: InkTheme.pulseCurve.transform(_pulse.value),
                endScale: _endScale,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }

  double get _endScale {
    final t = InkTheme.endCurve.transform(_end.value);
    return InkTheme.endScaleStart + (1 - InkTheme.endScaleStart) * t;
  }
}

int? cellAt(Match match, Size size, Offset point) {
  final cellWidth = size.width / match.width;
  final cellHeight = size.height / match.height;
  final x = (point.dx / cellWidth).floor();
  final y = (point.dy / cellHeight).floor();
  if (!match.inBounds(x, y)) return null;
  final center = Offset((x + 0.5) * cellWidth, (y + 0.5) * cellHeight);
  final reach = math.min(cellWidth, cellHeight) * InkTheme.hitReach;
  if ((point - center).distance > reach) return null;
  return match.cellOf(x, y);
}

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.match,
    required this.pendingCell,
    required this.draw,
    required this.showTargets,
    required this.pulse,
    required this.endScale,
  });

  final Match match;
  final int? pendingCell;
  final double draw;
  final bool showTargets;
  final double pulse;
  final double endScale;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / match.width;
    final cellHeight = size.height / match.height;
    final unit = math.min(cellWidth, cellHeight);

    Offset centerOf(int cell) {
      return Offset((match.xOf(cell) + 0.5) * cellWidth, (match.yOf(cell) + 0.5) * cellHeight);
    }

    Color inkOf(String playerId) {
      final index = match.players.indexWhere((player) => player.id == playerId);
      return InkTheme.inks[(index < 0 ? 0 : index) % InkTheme.inks.length];
    }

    Color dotColor(int cell) {
      for (final segment in match.segments.reversed) {
        if (segment.b == cell) return inkOf(segment.playerId);
      }
      return InkTheme.anchor;
    }

    final quiet = Paint()..color = InkTheme.quiet;
    final wall = Paint()..color = InkTheme.wall;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * InkTheme.markWidth
      ..color = InkTheme.ink;
    final dot = Paint()..style = PaintingStyle.fill;

    for (var cell = 0; cell < match.cellCount; cell++) {
      final center = centerOf(cell);
      if (match.walls.test(cell)) {
        final rect = Rect.fromCenter(
          center: center,
          width: unit * InkTheme.wallExtent,
          height: unit * InkTheme.wallExtent,
        );
        final radius = Radius.circular(unit * InkTheme.wallRadius);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), wall);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), outline);
        continue;
      }
      if (!match.occupied.test(cell)) {
        canvas.drawCircle(center, unit * InkTheme.quietRadius, quiet);
        canvas.drawCircle(center, unit * InkTheme.quietRadius, outline);
      }
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * InkTheme.strokeWidth
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < match.segments.length; i++) {
      final segment = match.segments[i];
      final start = centerOf(segment.a);
      final end = centerOf(segment.b);
      final shown = i == match.segments.length - 1 ? Offset.lerp(start, end, draw)! : end;
      stroke.color = inkOf(segment.playerId);
      canvas.drawLine(start, shown, stroke);
    }

    for (var cell = 0; cell < match.cellCount; cell++) {
      if (!match.occupied.test(cell) || match.walls.test(cell)) continue;
      dot.color = dotColor(cell);
      canvas.drawCircle(centerOf(cell), unit * InkTheme.dotRadius, dot);
    }

    if (showTargets) {
      final target = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * InkTheme.targetWidth
        ..color = InkTheme.target;
      final radius = unit * (InkTheme.targetRadiusMin + (InkTheme.targetRadiusMax - InkTheme.targetRadiusMin) * pulse);
      for (final move in legalMoves(match)) {
        final pending = move.cell == pendingCell;
        canvas.drawCircle(centerOf(move.cell), pending ? unit * InkTheme.pendingRadius : radius, target);
      }
    }

    void endMark(int cell, {required bool head}) {
      final center = centerOf(cell);
      final mark = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * InkTheme.markWidth
        ..color = InkTheme.ink;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(endScale);
      if (head) {
        canvas.drawCircle(Offset.zero, unit * InkTheme.headRadius, mark);
      } else {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: unit * InkTheme.tailExtent,
          height: unit * InkTheme.tailExtent,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(unit * InkTheme.tailRadius)), mark);
      }
      canvas.restore();
    }

    if (match.head == match.tail) {
      endMark(match.head, head: false);
      endMark(match.head, head: true);
    } else {
      endMark(match.tail, head: false);
      endMark(match.head, head: true);
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return oldDelegate.draw != draw ||
        oldDelegate.pulse != pulse ||
        oldDelegate.endScale != endScale ||
        oldDelegate.showTargets != showTargets ||
        oldDelegate.pendingCell != pendingCell ||
        oldDelegate.match.head != match.head ||
        oldDelegate.match.tail != match.tail ||
        oldDelegate.match.turn != match.turn ||
        oldDelegate.match.loserId != match.loserId ||
        oldDelegate.match.segments.length != match.segments.length ||
        oldDelegate.match.walls != match.walls;
  }
}
