import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../settings/copy.dart';
import '../table/board_view.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';

const _side = 3;
const _fadeMs = 220;
const _lookMs = 820;
const _reachMs = 560;
const _lostHoldMs = 1100;

const _players = [
  Player(id: 'p1', name: 'Player 1'),
  Player(id: 'p2', name: 'Player 2'),
];

/// Ring on the right, square on the left. The ring steps up, then the square steps down.
final HowToDemo endsDemo = _demo(
  _grid(
    occupied: const [3, 4, 5],
    head: 5,
    tail: 3,
    segments: const [
      Segment(a: 4, b: 5, playerId: 'p1'),
      Segment(a: 4, b: 3, playerId: 'p2'),
    ],
  ),
  const [Move(end: End.head, cell: 2), Move(end: End.tail, cell: 6)],
);

/// Fresh anchor. The first tap steps right, the second steps up.
final HowToDemo tapDemo = _demo(
  _grid(occupied: const [4], head: 4, tail: 4),
  const [Move(end: End.head, cell: 5), Move(end: End.head, cell: 2)],
);

/// One open dot above the square. Taking it leaves the next player nothing to grow.
///
/// ```text
/// · ■ ■
/// □ ● ○
/// ■ ■ ■
/// ```
final HowToDemo lossDemo = _demo(
  _grid(
    walls: const [1, 2, 6, 7, 8],
    occupied: const [3, 4, 5],
    head: 5,
    tail: 3,
    segments: const [
      Segment(a: 4, b: 5, playerId: 'p1'),
      Segment(a: 4, b: 3, playerId: 'p2'),
    ],
  ),
  const [Move(end: End.tail, cell: 0)],
  terminal: true,
);

final howToDemos = [endsDemo, tapDemo, lossDemo];

class SnippetSample {
  const SnippetSample({
    required this.match,
    required this.draw,
    required this.showTargets,
    required this.endScale,
    required this.fingerCell,
    required this.fingerT,
    required this.fingerOpacity,
    required this.opacity,
    required this.showLost,
    required this.lostT,
  });

  final Match match;
  final double draw;
  final bool showTargets;
  final double endScale;
  final int? fingerCell;
  final double fingerT;
  final double fingerOpacity;
  final double opacity;
  final bool showLost;
  final double lostT;

  SnippetSample copyWith({
    int? fingerCell,
    double? fingerT,
    double? fingerOpacity,
  }) {
    return SnippetSample(
      match: match,
      draw: draw,
      showTargets: showTargets,
      endScale: endScale,
      fingerCell: fingerCell ?? this.fingerCell,
      fingerT: fingerT ?? this.fingerT,
      fingerOpacity: fingerOpacity ?? this.fingerOpacity,
      opacity: opacity,
      showLost: showLost,
      lostT: lostT,
    );
  }
}

/// A scripted match and the clock that plays it on a loop.
class HowToDemo {
  HowToDemo({required this.frames, required this.moves})
    : assert(frames.length == moves.length + 1) {
    _timeline = _timelineFor(frames, moves);
  }

  final List<Match> frames;
  final List<Move> moves;
  late final _Timeline _timeline;

  int get periodMs => _timeline.periodMs;

  SnippetSample sampleAt(int milliseconds) {
    final period = _timeline.periodMs;
    var ms = milliseconds % period;
    if (ms < 0) ms += period;
    for (final span in _timeline.spans) {
      if (ms < span.ms) return span.paint(ms / span.ms);
      ms -= span.ms;
    }
    return _timeline.spans.last.paint(1);
  }

  int restAt(int frame) => _mark(restFrame: frame, unit: 0.12);

  int reachAt(int step) => _mark(reachStep: step, unit: 0.72);

  int get lossAt => _mark(loss: true, unit: 0.2);

  int _mark({
    int? restFrame,
    int? reachStep,
    bool loss = false,
    required double unit,
  }) {
    var ms = 0;
    for (final span in _timeline.spans) {
      final hit =
          (restFrame != null && span.restFrame == restFrame) ||
          (reachStep != null && span.reachStep == reachStep) ||
          (loss && span.marksLoss);
      if (hit) return ms + (span.ms * unit).floor();
      ms += span.ms;
    }
    throw StateError('Missing how-to mark.');
  }
}

class _Span {
  const _Span(
    this.ms,
    this.paint, {
    this.restFrame,
    this.reachStep,
    this.marksLoss = false,
  });

  final int ms;
  final SnippetSample Function(double u) paint;
  final int? restFrame;
  final int? reachStep;
  final bool marksLoss;
}

class _Timeline {
  const _Timeline(this.spans, this.periodMs);

  final List<_Span> spans;
  final int periodMs;
}

class PlaySnippet extends StatefulWidget {
  const PlaySnippet({super.key, required this.demo});

  final HowToDemo demo;

  @override
  State<PlaySnippet> createState() => _PlaySnippetState();
}

class _PlaySnippetState extends State<PlaySnippet>
    with TickerProviderStateMixin {
  late final AnimationController _clock;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.demo.periodMs),
    )..repeat();
    _pulse = AnimationController(vsync: this, duration: InkTheme.pulseDuration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _clock.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: InkTheme.field,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedBuilder(
              animation: Listenable.merge([_clock, _pulse]),
              builder: (context, _) {
                final sample = widget.demo.sampleAt(
                  (_clock.value * widget.demo.periodMs).round(),
                );
                return Opacity(
                  opacity: sample.opacity.clamp(0.0, 1.0),
                  child: ExcludeSemantics(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: BoardPainter(
                            match: sample.match,
                            pendingCell: sample.showTargets
                                ? sample.fingerCell
                                : null,
                            draw: sample.draw,
                            showTargets: sample.showTargets,
                            pulse: InkTheme.pulseCurve.transform(_pulse.value),
                            endScale: sample.endScale,
                          ),
                          child: const SizedBox.expand(),
                        ),
                        if (sample.fingerCell != null &&
                            sample.fingerOpacity > 0)
                          CustomPaint(
                            painter: _FingerPainter(
                              match: sample.match,
                              cell: sample.fingerCell!,
                              t: sample.fingerT,
                              opacity: sample.fingerOpacity,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        if (sample.showLost)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 6, 3),
                              child: Opacity(
                                opacity: Curves.easeOut.transform(
                                  sample.lostT.clamp(0.0, 1.0),
                                ),
                                child: Transform.scale(
                                  scale: _lostScale(sample.lostT),
                                  child: _LostStamp(AppCopy.of(context).lost),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LostStamp extends StatelessWidget {
  const _LostStamp(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: InkTheme.sun,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: OutlineLabel(label, size: 12, stroke: 2),
      ),
    );
  }
}

class _FingerPainter extends CustomPainter {
  const _FingerPainter({
    required this.match,
    required this.cell,
    required this.t,
    required this.opacity,
  });

  final Match match;
  final int cell;
  final double t;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || opacity <= 0) return;
    final cellWidth = size.width / match.width;
    final cellHeight = size.height / match.height;
    final unit = math.min(cellWidth, cellHeight);
    final center = Offset(
      (match.xOf(cell) + 0.5) * cellWidth,
      (match.yOf(cell) + 0.5) * cellHeight,
    );
    final travel = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0)) * 0.9;
    final from = _rest(center, size, unit);
    final radius =
        unit * 0.26 * (1 - 0.1 * Curves.easeIn.transform(t.clamp(0.0, 1.0)));
    final raw = Offset.lerp(from, center, travel)!;
    final pad = radius + unit * 0.12;
    final at = Offset(
      raw.dx.clamp(pad, size.width - pad).toDouble(),
      raw.dy.clamp(pad, size.height - pad).toDouble(),
    );
    final behind = from - center;
    final angle = behind.distance < 0.001
        ? math.pi / 4
        : math.atan2(behind.dy, behind.dx) - math.pi / 2;
    final fade = opacity.clamp(0.0, 1.0);

    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, radius * 1.35),
        width: radius * 1.05,
        height: radius * 2.15,
      ),
      Radius.circular(radius),
    );
    final shadow = Paint()..color = Color.fromRGBO(0, 0, 0, fade);
    final fill = Paint()..color = Color.fromRGBO(255, 255, 255, fade);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, unit * 0.07)
      ..color = Color.fromRGBO(0, 0, 0, fade);
    canvas.drawRRect(body.shift(const Offset(1.4, 1.8)), shadow);
    canvas.drawCircle(const Offset(1.4, 1.8), radius, shadow);
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, ink);
    canvas.drawCircle(Offset.zero, radius, fill);
    canvas.drawCircle(Offset.zero, radius, ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FingerPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.opacity != opacity ||
        oldDelegate.cell != cell ||
        oldDelegate.match.head != match.head ||
        oldDelegate.match.tail != match.tail;
  }
}

Offset _rest(Offset center, Size size, double unit) {
  final margin = unit * 0.22;
  var dx = unit * 0.56;
  var dy = unit * 0.7;
  if (center.dx + dx > size.width - margin) dx = -dx;
  if (center.dx + dx < margin) dx = dx.abs();
  if (center.dy + dy > size.height - margin) dy = -dy;
  if (center.dy + dy < margin) dy = dy.abs();
  return center + Offset(dx, dy);
}

double _lostScale(double t) {
  final curved = InkTheme.lossCurve.transform(t.clamp(0.0, 1.0));
  return InkTheme.lossScaleStart + (1 - InkTheme.lossScaleStart) * curved;
}

double _endScale(double linearDraw) {
  final ms = linearDraw * InkTheme.drawDuration.inMilliseconds;
  final t = (ms / InkTheme.endDuration.inMilliseconds).clamp(0.0, 1.0);
  final curved = InkTheme.endCurve.transform(t);
  return InkTheme.endScaleStart + (1 - InkTheme.endScaleStart) * curved;
}

double _fade(double u) => Curves.easeInOut.transform(u.clamp(0.0, 1.0));

Match _grid({
  List<int> walls = const [],
  required List<int> occupied,
  required int head,
  required int tail,
  List<Segment> segments = const [],
}) {
  final cells = _side * _side;
  return Match(
    width: _side,
    height: _side,
    seed: 1,
    modeId: 'how-to',
    wallChance: 0,
    walls: BitGrid.of(cells, walls),
    occupied: BitGrid.of(cells, occupied),
    head: head,
    tail: tail,
    segments: segments,
    players: _players,
    turn: 0,
    firstTurn: 0,
  );
}

HowToDemo _demo(Match start, List<Move> moves, {bool terminal = false}) {
  final frames = <Match>[start];
  var match = start;
  for (final move in moves) {
    final next = apply(match, move);
    if (identical(next, match)) throw StateError('Illegal how-to move $move');
    frames.add(next);
    match = next;
  }
  if (match.isTerminal != terminal) {
    throw StateError(
      terminal
          ? 'How-to should end on a loss.'
          : 'How-to ended before the last move.',
    );
  }
  return HowToDemo(frames: frames, moves: moves);
}

_Timeline _timelineFor(List<Match> frames, List<Move> moves) {
  final spans = <_Span>[];
  final drawMs = InkTheme.drawDuration.inMilliseconds;

  SnippetSample rest(
    Match match, {
    double opacity = 1,
    bool showLost = false,
    double lostT = 0,
  }) {
    return SnippetSample(
      match: match,
      draw: 1,
      showTargets: !match.isTerminal,
      endScale: 1,
      fingerCell: null,
      fingerT: 0,
      fingerOpacity: 0,
      opacity: opacity,
      showLost: showLost,
      lostT: lostT,
    );
  }

  spans.add(_Span(_fadeMs, (u) => rest(frames.first, opacity: _fade(u))));
  for (var i = 0; i < frames.length; i++) {
    final frame = frames[i];
    final step = i;
    spans.add(_Span(_lookMs, (_) => rest(frame), restFrame: step));
    if (step == frames.length - 1) break;
    final move = moves[step];
    final next = frames[step + 1];
    spans.add(
      _Span(
        _reachMs,
        (u) => rest(frame).copyWith(
          fingerCell: move.cell,
          fingerT: u,
          fingerOpacity: _fade((u / 0.18).clamp(0.0, 1.0)),
        ),
        reachStep: step,
      ),
    );
    spans.add(
      _Span(drawMs, (u) {
        final lifting = u < 0.28;
        return SnippetSample(
          match: next,
          draw: InkTheme.drawCurve.transform(u),
          showTargets: false,
          endScale: _endScale(u),
          fingerCell: lifting ? move.cell : null,
          fingerT: 1,
          fingerOpacity: lifting ? 1 - u / 0.28 : 0,
          opacity: 1,
          showLost: false,
          lostT: 0,
        );
      }),
    );
  }

  final last = frames.last;
  if (last.isTerminal) {
    spans.add(
      _Span(
        InkTheme.lossDuration.inMilliseconds,
        (u) => rest(last, showLost: true, lostT: u),
      ),
    );
    spans.add(
      _Span(
        _lostHoldMs,
        (_) => rest(last, showLost: true, lostT: 1),
        marksLoss: true,
      ),
    );
  }
  spans.add(
    _Span(
      _fadeMs,
      (u) => rest(
        last,
        opacity: 1 - _fade(u),
        showLost: last.isTerminal,
        lostT: 1,
      ),
    ),
  );

  final periodMs = spans.fold<int>(0, (sum, span) => sum + span.ms);
  return _Timeline(spans, periodMs);
}
