import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../theme/ink_theme.dart';
import 'board_view.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key, this.seed = 1, this.wallChance = classicWallChance, this.players = defaultPlayers});

  final int seed;
  final double wallChance;
  final List<Player> players;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late Match _match;
  int? _pendingCell;

  @override
  void initState() {
    super.initState();
    _match = _deal(widget.seed, 0);
  }

  Match _deal(int seed, int firstTurn) {
    return dealClassic(
      seed: seed,
      players: widget.players,
      wallChance: widget.wallChance,
      firstTurn: firstTurn,
    );
  }

  void _onCell(int cell) {
    if (_match.isTerminal) return;
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
    if (identical(next, _match)) return;
    setState(() {
      _match = next;
      _pendingCell = null;
    });
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
    final banner = _match.isTerminal
        ? '${_playerName(_match.loserId!)} lost. No growth left.'
        : _pendingCell != null
        ? 'Which end? Tap the ring or the square.'
        : "${_match.currentPlayer.name}'s turn";
    final ink = InkTheme.inks[_match.turn % InkTheme.inks.length];

    return Scaffold(
      backgroundColor: InkTheme.paper,
      body: SafeArea(
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
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
                        ),
                      if (!_match.isTerminal) const SizedBox(width: 8),
                      Expanded(
                        child: Text(banner, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a red dot. The ring is the head, the square is the tail.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5C574F)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: BoardView(match: _match, pendingCell: _pendingCell, onCell: _onCell),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _rematch, child: const Text('Rematch')),
                ],
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
