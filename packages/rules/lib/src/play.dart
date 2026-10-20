import 'dart:math';

import 'bit_grid.dart';
import 'match.dart';
import 'mode.dart';

export 'mode.dart';

const defaultPlayers = [
  Player(id: 'p1', name: 'Player 1'),
  Player(id: 'p2', name: 'Player 2'),
];

/// Deals [mode]. Classic is [classicMode]: 6×6, wall chance 0.05.
Match deal(
  GameMode mode, {
  required int seed,
  List<Player> players = defaultPlayers,
  int firstTurn = 0,
}) {
  return dealClassic(
    seed: seed,
    players: players,
    width: mode.width,
    height: mode.height,
    wallChance: mode.wallChance,
    firstTurn: firstTurn,
    modeId: mode.id,
  );
}

/// Anchor first, then one wall roll per other cell, in index order.
Match dealClassic({
  required int seed,
  List<Player> players = defaultPlayers,
  int width = classicSize,
  int height = classicSize,
  double wallChance = classicWallChance,
  int firstTurn = 0,
  String modeId = classicModeId,
}) {
  if (players.length < 2) {
    throw ArgumentError('A match needs two or more players.');
  }
  if (width < 1 || height < 1) {
    throw ArgumentError('The field must have at least one cell.');
  }
  final rng = Random(seed);
  final count = width * height;
  final anchor = rng.nextInt(count);
  final wallIndexes = <int>[];
  for (var i = 0; i < count; i++) {
    if (i == anchor) continue;
    if (rng.nextDouble() < wallChance) wallIndexes.add(i);
  }
  return settle(
    Match(
      width: width,
      height: height,
      seed: seed,
      modeId: modeId,
      wallChance: wallChance,
      walls: BitGrid.of(count, wallIndexes),
      occupied: BitGrid.of(count, [anchor]),
      head: anchor,
      tail: anchor,
      segments: const [],
      players: players,
      turn: firstTurn % players.length,
      firstTurn: firstTurn % players.length,
    ),
  );
}

Match settle(Match match) {
  if (match.isTerminal || legalMoves(match).isNotEmpty) return match;
  return match.copyWith(loserId: match.currentPlayer.id);
}

List<Move> legalMoves(Match match) {
  if (match.isTerminal) return const [];
  final moves = <Move>[];
  _collect(match, End.head, match.head, moves);
  if (match.tail != match.head) {
    _collect(match, End.tail, match.tail, moves);
  }
  return moves;
}

List<Move> movesAt(Match match, int cell) {
  return [for (final move in legalMoves(match)) if (move.cell == cell) move];
}

void _collect(Match match, End end, int from, List<Move> into) {
  final x = match.xOf(from);
  final y = match.yOf(from);
  for (var dy = -1; dy <= 1; dy++) {
    for (var dx = -1; dx <= 1; dx++) {
      if (dx == 0 && dy == 0) continue;
      final nx = x + dx;
      final ny = y + dy;
      if (!match.inBounds(nx, ny)) continue;
      final cell = match.cellOf(nx, ny);
      if (match.walls.test(cell) || match.occupied.test(cell)) continue;
      if (dx != 0 && dy != 0 && _diagonalBlocked(match, from, cell)) continue;
      into.add(Move(end: end, cell: cell));
    }
  }
}

bool _diagonalBlocked(Match match, int from, int to) {
  final sideA = match.cellOf(match.xOf(to), match.yOf(from));
  final sideB = match.cellOf(match.xOf(from), match.yOf(to));
  return match.segmentKeys.contains(segmentKey(sideA, sideB));
}

/// Returns [match] unchanged when the growth is illegal or the game is over.
Match apply(Match match, Move move) {
  if (match.isTerminal) return match;
  if (!legalMoves(match).contains(move)) return match;

  final from = move.end == End.tail && match.head != match.tail ? match.tail : match.head;
  final playerId = match.currentPlayer.id;
  final next = match.copyWith(
    occupied: match.occupied.set(move.cell),
    head: move.end == End.tail && match.head != match.tail ? match.head : move.cell,
    tail: move.end == End.tail && match.head != match.tail ? move.cell : match.tail,
    segments: [
      ...match.segments,
      Segment(a: from, b: move.cell, playerId: playerId),
    ],
    turn: (match.turn + 1) % match.players.length,
    clearLoser: true,
  );
  return settle(next);
}

class MatchLog {
  MatchLog({
    this.logVersion = 1,
    required this.modeId,
    required this.seed,
    required this.width,
    required this.height,
    required this.wallChance,
    required this.players,
    required this.firstTurn,
    required this.moves,
  });

  final int logVersion;
  final String modeId;
  final int seed;
  final int width;
  final int height;
  final double wallChance;
  final List<Player> players;
  final int firstTurn;
  final List<Move> moves;

  factory MatchLog.capture(Match match, List<Move> moves) {
    return MatchLog(
      modeId: match.modeId,
      seed: match.seed,
      width: match.width,
      height: match.height,
      wallChance: match.wallChance,
      players: match.players,
      firstTurn: match.firstTurn,
      moves: moves,
    );
  }

  Match replay() {
    var match = dealClassic(
      seed: seed,
      players: players,
      width: width,
      height: height,
      wallChance: wallChance,
      firstTurn: firstTurn,
      modeId: modeId,
    );
    for (final move in moves) {
      final next = apply(match, move);
      if (identical(next, match)) throw ReplayException(move);
      match = next;
    }
    return match;
  }

  Map<String, Object?> toJson() => {
    'logVersion': logVersion,
    'modeId': modeId,
    'seed': seed,
    'width': width,
    'height': height,
    'wallChance': wallChance,
    'players': [for (final player in players) player.toJson()],
    'firstTurn': firstTurn,
    'moves': [for (final move in moves) move.toJson()],
  };

  factory MatchLog.fromJson(Map<String, Object?> json) {
    return MatchLog(
      logVersion: json['logVersion']! as int,
      modeId: json['modeId']! as String,
      seed: json['seed']! as int,
      width: json['width']! as int,
      height: json['height']! as int,
      wallChance: (json['wallChance']! as num).toDouble(),
      players: [
        for (final player in json['players']! as List<Object?>)
          Player.fromJson(player! as Map<String, Object?>),
      ],
      firstTurn: json['firstTurn']! as int,
      moves: [
        for (final move in json['moves']! as List<Object?>) Move.fromJson(move! as Map<String, Object?>),
      ],
    );
  }
}
