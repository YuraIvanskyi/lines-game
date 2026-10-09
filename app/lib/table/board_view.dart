import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../theme/ink_theme.dart';

class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.match,
    required this.pendingCell,
    required this.onCell,
  });

  final Match match;
  final int? pendingCell;
  final ValueChanged<int> onCell;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> with SingleTickerProviderStateMixin {
  late final AnimationController _draw;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(vsync: this, duration: InkTheme.drawDuration);
    if (widget.match.segments.isNotEmpty) _draw.value = 1;
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.match.segments.length != oldWidget.match.segments.length) {
      _draw.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _draw,
      builder: (context, _) {
        return GestureDetector(
          onTapUp: (details) {
            final box = context.findRenderObject()! as RenderBox;
            final cell = cellAt(widget.match, box.size, details.localPosition);
            if (cell != null) widget.onCell(cell);
          },
          child: CustomPaint(
            painter: BoardPainter(
              match: widget.match,
              pendingCell: widget.pendingCell,
              progress: _draw.value,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

int? cellAt(Match match, Size size, Offset point) {
  final cellWidth = size.width / match.width;
  final cellHeight = size.height / match.height;
  final x = (point.dx / cellWidth).floor();
  final y = (point.dy / cellHeight).floor();
  if (!match.inBounds(x, y)) return null;
  final center = Offset((x + 0.5) * cellWidth, (y + 0.5) * cellHeight);
  final reach = math.min(cellWidth, cellHeight) * 0.48;
  if ((point - center).distance > reach) return null;
  return match.cellOf(x, y);
}

class BoardPainter extends CustomPainter {
  BoardPainter({required this.match, required this.pendingCell, required this.progress});

  final Match match;
  final int? pendingCell;
  final double progress;

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

    final legal = {for (final move in legalMoves(match)) move.cell};
    final quiet = Paint()..color = InkTheme.quiet;
    final wall = Paint()..color = InkTheme.wall;
    final dot = Paint()..style = PaintingStyle.fill;

    for (var cell = 0; cell < match.cellCount; cell++) {
      final center = centerOf(cell);
      if (match.walls.test(cell)) {
        final rect = Rect.fromCenter(center: center, width: unit * 0.62, height: unit * 0.62);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.12)), wall);
        continue;
      }
      if (!match.occupied.test(cell)) {
        canvas.drawCircle(center, unit * 0.08, quiet);
      }
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.12
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < match.segments.length; i++) {
      final segment = match.segments[i];
      final start = centerOf(segment.a);
      final end = centerOf(segment.b);
      final shown = i == match.segments.length - 1 ? Offset.lerp(start, end, progress)! : end;
      stroke.color = inkOf(segment.playerId);
      canvas.drawLine(start, shown, stroke);
    }

    for (var cell = 0; cell < match.cellCount; cell++) {
      if (!match.occupied.test(cell) || match.walls.test(cell)) continue;
      dot.color = dotColor(cell);
      canvas.drawCircle(centerOf(cell), unit * 0.16, dot);
    }

    final target = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.06
      ..color = InkTheme.target;
    for (final cell in legal) {
      final radius = unit * (cell == pendingCell ? 0.30 : 0.22);
      canvas.drawCircle(centerOf(cell), radius, target);
    }

    void endMark(int cell, {required bool head}) {
      final center = centerOf(cell);
      final mark = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * 0.07
        ..color = InkTheme.ink;
      if (head) {
        canvas.drawCircle(center, unit * 0.28, mark);
      } else {
        final rect = Rect.fromCenter(center: center, width: unit * 0.5, height: unit * 0.5);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.08)), mark);
      }
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
    return oldDelegate.progress != progress ||
        oldDelegate.pendingCell != pendingCell ||
        oldDelegate.match.head != match.head ||
        oldDelegate.match.tail != match.tail ||
        oldDelegate.match.turn != match.turn ||
        oldDelegate.match.loserId != match.loserId ||
        oldDelegate.match.segments.length != match.segments.length ||
        oldDelegate.match.walls != match.walls;
  }
}
