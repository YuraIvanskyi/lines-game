import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rules/rules.dart';

import '../settings/copy.dart';
import '../theme/arcade_dialog.dart';
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
    this.bots = const {},
    this.botDelay = const Duration(milliseconds: 700),
    this.initial,
    this.onHome,
    this.feel = const SilentFeel(),
  });

  final int seed;
  final GameMode mode;
  final List<Player> players;

  /// Seats the app plays, by player id. Everyone else plays by tapping.
  final Map<String, Bot> bots;

  /// How long a bot holds before it grows the line, so the move can be followed.
  final Duration botDelay;
  final Match? initial;
  final VoidCallback? onHome;
  final GameFeel feel;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late Match _match;
  int? _pendingCell;
  Timer? _botTimer;

  @override
  void initState() {
    super.initState();
    _match = widget.initial ?? _deal(widget.seed, 0);
    _scheduleBot();
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    super.dispose();
  }

  bool get _botTurn => !_match.isTerminal && widget.bots.containsKey(_match.currentPlayer.id);

  void _scheduleBot() {
    _botTimer?.cancel();
    if (!_botTurn) return;
    final bot = widget.bots[_match.currentPlayer.id]!;
    _botTimer = Timer(widget.botDelay, () => _play(bot.choose(_match)));
  }

  Match _deal(int seed, int firstTurn) {
    return deal(
      widget.mode,
      seed: seed,
      players: widget.players,
      firstTurn: firstTurn,
    );
  }

  void _onCell(int? cell) {
    if (_match.isTerminal || _botTurn) return;
    if (cell == null) {
      _miss();
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
      _miss();
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
      _miss();
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
    _scheduleBot();
  }

  void _miss() {
    widget.feel.illegal();
    setState(() => _pendingCell = null);
  }

  Future<void> _back() async {
    if (widget.onHome == null) return;
    if (!_match.isTerminal) {
      final leave = await confirmLeave(context);
      if (!leave || !mounted) return;
    }
    widget.onHome!();
  }

  Future<void> _askRestart() async {
    // The computer never asks, so the question goes to the first person at the phone.
    final asker = _botTurn
        ? _match.players.firstWhere((player) => !widget.bots.containsKey(player.id), orElse: () => _match.currentPlayer)
        : _match.currentPlayer;
    final name = asker.name;
    final restart = await confirmRestart(context, name);
    if (!restart || !mounted) return;
    setState(() {
      _match = _deal(_match.seed, _match.firstTurn);
      _pendingCell = null;
    });
    _scheduleBot();
  }

  void _rematch() {
    final firstTurn = (_match.firstTurn + 1) % _match.players.length;
    final seed = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
    setState(() {
      _match = _deal(seed, firstTurn);
      _pendingCell = null;
    });
    _scheduleBot();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final copy = AppCopy.of(context);
    final headline = _match.isTerminal
        ? copy.lostPlayer(_playerName(_match.loserId!))
        : _pendingCell != null
        ? copy.whichEnd
        : copy.turn(_match.currentPlayer.name);
    final detail = _match.isTerminal
        ? copy.noGrowth
        : _pendingCell != null
        ? copy.tapEnd
        : _botTurn
        ? copy.thinking
        : widget.bots.isNotEmpty
        ? copy.yourMove
        : copy.passPhone;
    final ink = InkTheme.inks[_match.turn % InkTheme.inks.length];
    final chipColor = _match.isTerminal ? InkTheme.sun : InkTheme.cloud;

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
                        PopBackButton(onPressed: _back, label: copy.back),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PopIconButton(
                            icon: Icons.restart_alt,
                            label: copy.restart,
                            onPressed: _askRestart,
                            extent: 56,
                            color: InkTheme.pinkFace,
                          ),
                        ),
                      ],
                    ),
                    TweenAnimationBuilder<double>(
                      key: ValueKey(headline),
                      tween: Tween(
                        begin: _match.isTerminal
                            ? InkTheme.lossScaleStart
                            : InkTheme.passScaleStart,
                        end: 1,
                      ),
                      duration: _match.isTerminal
                          ? InkTheme.lossDuration
                          : InkTheme.passDuration,
                      curve: _match.isTerminal
                          ? InkTheme.lossCurve
                          : InkTheme.passCurve,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ink,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            headline,
                            textAlign: TextAlign.center,
                            style: text.titleLarge?.copyWith(
                              color: InkTheme.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.center,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black, width: 2.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          child: Text(
                            detail,
                            textAlign: TextAlign.center,
                            style: text.titleLarge?.copyWith(
                              color: InkTheme.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: InkTheme.field,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: BoardView(
                                match: _match,
                                pendingCell: _pendingCell,
                                onCell: _onCell,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_match.isTerminal) ...[
                      const SizedBox(height: 12),
                      PopButton(
                        label: copy.rematch,
                        onPressed: _rematch,
                        color: InkTheme.greenFace,
                      ),
                      if (widget.onHome != null)
                        PopButton(
                          label: copy.home,
                          onPressed: widget.onHome!,
                          color: InkTheme.blueFace,
                          compact: true,
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
