import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../theme/arcade_shell.dart';
import '../theme/game_feel.dart';
import '../theme/ink_theme.dart';
import 'board_view.dart';

class TablePage extends StatefulWidget {
  const TablePage({
    super.key,
    this.seed = 1,
    this.mode = classicMode,
    this.players = defaultPlayers,
    this.initial,
    this.onHome,
    this.feel = const SilentFeel(),
  });

  final int seed;
  final GameMode mode;
  final List<Player> players;
  final Match? initial;
  final VoidCallback? onHome;
  final GameFeel feel;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late Match _match;
  int? _pendingCell;

  @override
  void initState() {
    super.initState();
    _match = widget.initial ?? _deal(widget.seed, 0);
  }

  Match _deal(int seed, int firstTurn) {
    return deal(widget.mode, seed: seed, players: widget.players, firstTurn: firstTurn);
  }

  void _onCell(int? cell) {
    if (_match.isTerminal) return;
    if (cell == null) {
      widget.feel.illegal();
      setState(() => _pendingCell = null);
      return;
    }
    if (_pendingCell != null) {
      if (cell == _match.head || cell == _match.tail) {
        final end = cell == _match.head ? End.head : End.tail;
        _play(Move(end: end, cell: _pendingCell!));
        return;
      }
      if (cell == _pendingCell) {
        setState(() => _pendingCell = null);
        return;
      }
    }
    final choices = movesAt(_match, cell);
    if (choices.isEmpty) {
      widget.feel.illegal();
      setState(() => _pendingCell = null);
      return;
    }
    if (choices.length == 1) {
      _play(choices.single);
      return;
    }
    setState(() => _pendingCell = cell);
  }

  void _play(Move move) {
    final next = apply(_match, move);
    if (identical(next, _match)) {
      widget.feel.illegal();
      return;
    }
    final lost = next.isTerminal;
    setState(() {
      _match = next;
      _pendingCell = null;
    });
    widget.feel.growth();
    if (lost) {
      widget.feel.loss();
    } else {
      widget.feel.passTurn();
    }
  }

  void _rematch() {
    final firstTurn = (_match.firstTurn + 1) % _match.players.length;
    final seed = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
    setState(() {
      _match = _deal(seed, firstTurn);
      _pendingCell = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final headline = _match.isTerminal
        ? '${_playerName(_match.loserId!)} lost'
        : _pendingCell != null
        ? 'Which end?'
        : "${_match.currentPlayer.name}'s turn";
    final detail = _match.isTerminal
        ? 'No growth left.'
        : _pendingCell != null
        ? 'Tap the ring or the square.'
        : 'Pass the phone';
    final ink = InkTheme.inks[_match.turn % InkTheme.inks.length];

    final onSky = text.titleLarge?.copyWith(color: InkTheme.cloud, fontWeight: FontWeight.w800);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ArcadeBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (!_match.isTerminal)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: ink,
                              shape: BoxShape.circle,
                              border: Border.all(color: InkTheme.ink, width: 3),
                            ),
                          ),
                        if (!_match.isTerminal) const SizedBox(width: 10),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(headline),
                            tween: Tween(
                              begin: _match.isTerminal ? InkTheme.lossScaleStart : InkTheme.passScaleStart,
                              end: 1,
                            ),
                            duration: _match.isTerminal ? InkTheme.lossDuration : InkTheme.passDuration,
                            curve: _match.isTerminal ? InkTheme.lossCurve : InkTheme.passCurve,
                            builder: (context, scale, child) =>
                                Transform.scale(scale: scale, alignment: Alignment.centerLeft, child: child),
                            child: Text(headline, style: text.headlineMedium?.copyWith(color: InkTheme.cloud, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                    Text(detail, style: onSky),
                    const SizedBox(height: 4),
                    Text(
                      'Tap a pink dot. The ring is the head, the square is the tail.',
                      style: text.bodyMedium?.copyWith(color: InkTheme.muted, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: InkTheme.paper,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: InkTheme.ink, width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: BoardView(match: _match, pendingCell: _pendingCell, onCell: _onCell),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_match.isTerminal) ...[
                      const SizedBox(height: 12),
                      PopButton(label: 'Rematch', onPressed: _rematch),
                      if (widget.onHome != null)
                        TextButton(
                          onPressed: widget.onHome,
                          child: const Text('Home', style: TextStyle(color: InkTheme.cloud, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _playerName(String id) {
    return _match.players.firstWhere((player) => player.id == id).name;
  }
}
