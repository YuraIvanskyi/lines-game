import 'bit_grid.dart';

enum End { head, tail }

class Player {
  const Player({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'name': name};

  static Player fromJson(Map<String, Object?> json) {
    return Player(id: json['id']! as String, name: json['name']! as String);
  }

  @override
  bool operator ==(Object other) => other is Player && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

class Move {
  const Move({required this.end, required this.cell});

  final End end;
  final int cell;

  Map<String, Object?> toJson() => {'end': end.name, 'cell': cell};

  static Move fromJson(Map<String, Object?> json) {
    return Move(end: End.values.byName(json['end']! as String), cell: json['cell']! as int);
  }

  @override
  bool operator ==(Object other) => other is Move && other.end == end && other.cell == cell;

  @override
  int get hashCode => Object.hash(end, cell);

  @override
  String toString() => '${end.name}@$cell';
}

class Segment {
  const Segment({required this.a, required this.b, required this.playerId});

  final int a;
  final int b;
  final String playerId;

  int get key => segmentKey(a, b);
}

int segmentKey(int a, int b) {
  final lo = a < b ? a : b;
  final hi = a < b ? b : a;
  return (lo << 16) | hi;
}

class Match {
  Match({
    required this.width,
    required this.height,
    required this.seed,
    required this.modeId,
    required this.wallChance,
    required this.walls,
    required this.occupied,
    required this.head,
    required this.tail,
    required List<Segment> segments,
    required List<Player> players,
    required this.turn,
    required this.firstTurn,
    this.loserId,
  }) : segments = List.unmodifiable(segments),
       players = List.unmodifiable(players),
       segmentKeys = Set.unmodifiable({for (final segment in segments) segment.key});

  final int width;
  final int height;
  final int seed;
  final String modeId;
  final double wallChance;
  final BitGrid walls;
  final BitGrid occupied;
  final int head;
  final int tail;
  final List<Segment> segments;
  final Set<int> segmentKeys;
  final List<Player> players;
  final int turn;
  final int firstTurn;
  final String? loserId;

  int get cellCount => width * height;

  bool get isTerminal => loserId != null;

  Player get currentPlayer => players[turn];

  int xOf(int cell) => cell % width;

  int yOf(int cell) => cell ~/ width;

  int cellOf(int x, int y) => y * width + x;

  bool inBounds(int x, int y) => x >= 0 && y >= 0 && x < width && y < height;

  Match copyWith({
    BitGrid? occupied,
    int? head,
    int? tail,
    List<Segment>? segments,
    int? turn,
    String? loserId,
    bool clearLoser = false,
  }) {
    return Match(
      width: width,
      height: height,
      seed: seed,
      modeId: modeId,
      wallChance: wallChance,
      walls: walls,
      occupied: occupied ?? this.occupied,
      head: head ?? this.head,
      tail: tail ?? this.tail,
      segments: segments ?? this.segments,
      players: players,
      turn: turn ?? this.turn,
      firstTurn: firstTurn,
      loserId: clearLoser ? null : (loserId ?? this.loserId),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Match) return false;
    if (width != other.width ||
        height != other.height ||
        seed != other.seed ||
        modeId != other.modeId ||
        wallChance != other.wallChance ||
        head != other.head ||
        tail != other.tail ||
        turn != other.turn ||
        firstTurn != other.firstTurn ||
        loserId != other.loserId ||
        walls != other.walls ||
        occupied != other.occupied ||
        players.length != other.players.length ||
        segments.length != other.segments.length) {
      return false;
    }
    for (var i = 0; i < players.length; i++) {
      if (players[i] != other.players[i]) return false;
    }
    for (var i = 0; i < segments.length; i++) {
      final a = segments[i];
      final b = other.segments[i];
      if (a.a != b.a || a.b != b.b || a.playerId != b.playerId) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(seed, head, tail, turn, loserId, segments.length);
}

class ReplayException implements Exception {
  ReplayException(this.move);
  final Move move;

  @override
  String toString() => 'Illegal move in log: $move';
}
