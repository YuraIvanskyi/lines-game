import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Scrolling for the whole app: rubber-band ends on every platform, drag with any pointer
/// (a mouse on the web too), and no desktop scrollbar over the arcade panels.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

/// A vertical list of menu cards that scrolls like a deck: a fling or a release settles with
/// a card's top edge in view, the ends bounce, and content fades out at an edge only while
/// there is more of it past that edge.
class CardScroll extends StatefulWidget {
  const CardScroll({super.key, required this.children, this.gap = 12, this.controller});

  final List<Widget> children;

  /// Space between cards.
  final double gap;
  final ScrollController? controller;

  @override
  State<CardScroll> createState() => _CardScrollState();
}

class _CardScrollState extends State<CardScroll> {
  /// Height of the fade at an edge. A snapped card's top sits just below it.
  static const _fade = 20.0;

  /// Room above the first card and below the last for lips and badges that poke out.
  static const _pad = 10.0;

  late final ScrollController _controller = widget.controller ?? ScrollController();
  final _column = GlobalKey();

  /// True from a finger (or mouse) drag until the scroll comes to rest. Only then do cards
  /// snap, so a programmatic scroll (ensureVisible, the keyboard) or a wheel step stays put.
  bool _dragging = false;

  /// Where a run of wheel steps is heading, so quick steps add up instead of restarting.
  double? _wheelTarget;

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  /// Scroll offsets that put each card's top just below the top fade. Read straight from the
  /// column's layout, so cards can come and go without keys.
  List<double> _snaps() {
    final column = _column.currentContext?.findRenderObject();
    if (column is! RenderFlex || !column.attached) return const [];
    final tops = <double>[];
    column.visitChildren((child) {
      final data = child.parentData;
      if (data is! FlexParentData) return;
      // Every card but the first sits under its gap.
      final top = _pad + data.offset.dy + (tops.isEmpty ? 0 : widget.gap);
      tops.add(top - _fade);
    });
    return tops;
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) {
      _dragging = notification.dragDetails != null;
    } else if (notification is ScrollEndNotification) {
      _dragging = false;
    }
    return false;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final position = _controller.position;
    final delta = event.scrollDelta.dy;
    // Trackpads send many small deltas: follow them directly. A mouse wheel notch is a big
    // jump, so glide there instead.
    if (delta.abs() < 40) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final from = _wheelTarget ?? position.pixels;
      final target = (from + delta).clamp(position.minScrollExtent, position.maxScrollExtent);
      _wheelTarget = target;
      _controller.animateTo(target, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic).whenComplete(() {
        if (_wheelTarget == target) _wheelTarget = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final physics = SnapToCardsPhysics(
      snaps: _snaps,
      active: () => _dragging,
      parent: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    );
    return NotificationListener<ScrollMetricsNotification>(
      // Content that grows or shrinks (an opened palette) changes whether an edge fades.
      onNotification: (_) {
        setState(() {});
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => edgeGradient(bounds).createShader(bounds),
            child: child,
          ),
          child: SingleChildScrollView(
            controller: _controller,
            physics: physics,
            clipBehavior: Clip.hardEdge,
            child: Listener(
              onPointerSignal: _onPointerSignal,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: _pad),
                child: Column(
                  key: _column,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < widget.children.length; i++)
                      Padding(
                        // A keyed card keeps its state when a card before it comes or goes.
                        key: widget.children[i].key == null ? null : ValueKey(widget.children[i].key),
                        padding: EdgeInsets.only(top: i == 0 ? 0 : widget.gap),
                        child: widget.children[i],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Opaque in the middle; each edge fades in proportion to how much is hidden past it.
  @visibleForTesting
  LinearGradient edgeGradient(Rect bounds) {
    var top = 0.0;
    var bottom = 0.0;
    if (_controller.hasClients && _controller.position.hasContentDimensions) {
      final position = _controller.position;
      top = ((position.pixels - position.minScrollExtent) / _fade).clamp(0.0, 1.0);
      bottom = ((position.maxScrollExtent - position.pixels) / _fade).clamp(0.0, 1.0);
    }
    final edge = bounds.height <= 0 ? 0.0 : math.min(0.45, _fade / bounds.height);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0, edge, 1 - edge, 1],
      colors: [
        Colors.black.withValues(alpha: 1 - top),
        Colors.black,
        Colors.black,
        Colors.black.withValues(alpha: 1 - bottom),
      ],
    );
  }
}

/// Lets a fling run its natural course, then eases it onto the nearest card edge instead of
/// stopping wherever the friction ran out. A spot farther than half a screen from any card edge
/// (inside a very tall card) is left alone, so nothing becomes unreachable.
class SnapToCardsPhysics extends ScrollPhysics {
  const SnapToCardsPhysics({required this.snaps, required this.active, super.parent});

  /// Card edges in scroll offsets, top card first.
  final List<double> Function() snaps;

  /// Whether to snap at all right now (only after the person drags).
  final bool Function() active;

  @override
  SnapToCardsPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapToCardsPhysics(snaps: snaps, active: active, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final natural = super.createBallisticSimulation(position, velocity);
    if (!active() || position.outOfRange || position.maxScrollExtent <= position.minScrollExtent) return natural;

    // Where the free fling would come to rest.
    final landing = natural == null ? position.pixels : natural.x(10);
    final targets = {
      position.minScrollExtent,
      position.maxScrollExtent,
      for (final edge in snaps()) edge.clamp(position.minScrollExtent, position.maxScrollExtent),
    };
    var target = landing;
    var best = double.infinity;
    for (final edge in targets) {
      final distance = (edge - landing).abs();
      if (distance < best) {
        best = distance;
        target = edge;
      }
    }
    if (best > position.viewportDimension / 2) return natural;

    final tolerance = toleranceFor(position);
    if ((target - position.pixels).abs() < tolerance.distance && velocity.abs() < tolerance.velocity) return null;
    return ScrollSpringSimulation(_settle, position.pixels, target, velocity, tolerance: tolerance);
  }

  /// Critically damped: glides in without bouncing past the card.
  static final _settle = SpringDescription.withDampingRatio(mass: 0.5, stiffness: 120, ratio: 1.0);
}
