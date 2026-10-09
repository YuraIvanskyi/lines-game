import 'package:rules/rules.dart';
import 'package:test/test.dart';

const players = [
  Player(id: 'p1', name: 'Player 1'),
  Player(id: 'p2', name: 'Player 2'),
];

const four = [
  Player(id: 'p1', name: 'Player 1'),
  Player(id: 'p2', name: 'Player 2'),
  Player(id: 'p3', name: 'Player 3'),
  Player(id: 'p4', name: 'Player 4'),
];

Match assembled({
  int width = 4,
  int height = 4,
  int head = 0,
  int tail = 0,
  Set<int> walls = const {},
  List<Segment> segments = const [],
  List<Player> roster = players,
  int turn = 0,
}) {
  final occupied = <int>{head, tail, for (final segment in segments) ...[segment.a, segment.b]};
  return Match(
    width: width,
    height: height,
    seed: 0,
    modeId: classicModeId,
    wallChance: classicWallChance,
    walls: BitGrid.of(width * height, walls),
    occupied: BitGrid.of(width * height, occupied),
    head: head,
    tail: tail,
    segments: segments,
    players: roster,
    turn: turn,
    firstTurn: 0,
  );
}

void main() {
  test('same seed deals the same classic board', () {
    final a = dealClassic(seed: 11, players: players);
    final b = dealClassic(seed: 11, players: players);
    expect(a, b);
    expect(a.width, 8);
    expect(a.height, 8);
    expect(a.walls.test(a.head), isFalse);
    expect(a.head, a.tail);
    expect(a.occupied.test(a.head), isTrue);
  });

  test('different seeds are different deals', () {
    expect(dealClassic(seed: 1), isNot(dealClassic(seed: 2)));
  });

  test('two and four seats keep turn order', () {
    expect(dealClassic(seed: 3, players: players).players, players);
    final match = dealClassic(seed: 3, players: four);
    expect(match.players, four);
    expect(match.currentPlayer.id, 'p1');
  });

  test('an open center has eight growths and an edge does not wrap', () {
    final center = assembled(width: 8, height: 8, head: 3 * 8 + 3, tail: 3 * 8 + 3);
    final moves = legalMoves(center);
    expect(moves, hasLength(8));
    expect(moves.every((move) => move.end == End.head), isTrue);

    final corner = assembled(head: 0, tail: 0);
    final cornerCells = legalMoves(corner).map((move) => move.cell).toSet();
    expect(cornerCells, {1, 4, 5});
  });

  test('the opposite diagonal is blocked and orthogonal steps stay open', () {
    // (0,0)=0 — (1,1)=4 already inked. Head sits on (1,0)=1, tail on (0,0).
    final match = assembled(
      width: 3,
      height: 3,
      head: 1,
      tail: 0,
      segments: const [Segment(a: 0, b: 4, playerId: 'p1')],
    );
    final headCells = [for (final move in legalMoves(match)) if (move.end == End.head) move.cell];
    expect(headCells, containsAll([2, 5]));
    expect(headCells, isNot(contains(3)));
  });

  test('occupied side dots without the opposite segment do not block the diagonal', () {
    final match = assembled(
      width: 3,
      height: 3,
      head: 1,
      tail: 8,
      segments: const [
        Segment(a: 8, b: 0, playerId: 'p1'),
        Segment(a: 8, b: 4, playerId: 'p2'),
      ],
    );
    final headCells = [for (final move in legalMoves(match)) if (move.end == End.head) move.cell];
    expect(headCells, contains(3));
  });

  test('walls and occupied dots are not targets', () {
    final match = assembled(head: 5, tail: 5, walls: {6});
    final cells = legalMoves(match).map((move) => move.cell);
    expect(cells, isNot(contains(6)));
    expect(cells, isNot(contains(5)));
  });

  test('the opening growth leaves the anchor as the tail', () {
    final match = assembled(head: 5, tail: 5);
    final next = apply(match, const Move(end: End.head, cell: 6));
    expect(next.head, 6);
    expect(next.tail, 5);
    expect(next.currentPlayer.id, 'p2');
    expect(next.segments.single.playerId, 'p1');
    expect(identical(match.segments, next.segments), isFalse);
  });

  test('an illegal growth does not change the match', () {
    final match = assembled(head: 0, tail: 0);
    final rejected = apply(match, const Move(end: End.head, cell: 15));
    expect(identical(rejected, match), isTrue);
  });

  test('a dot beside both ends is two moves', () {
    // Head (1,2)=9, tail (1,1)=5. (0,2)=8 touches both.
    final match = assembled(head: 9, tail: 5, segments: const [Segment(a: 5, b: 9, playerId: 'p1')]);
    final choices = movesAt(match, 8);
    expect(choices.map((move) => move.end).toSet(), {End.head, End.tail});
    final byHead = apply(match, const Move(end: End.head, cell: 8));
    final byTail = apply(match, const Move(end: End.tail, cell: 8));
    expect(byHead.head, 8);
    expect(byHead.tail, 5);
    expect(byTail.tail, 8);
    expect(byTail.head, 9);
  });

  test('the player who cannot grow loses', () {
    final blocked = settle(assembled(width: 2, height: 2, head: 0, tail: 0, walls: {1, 2, 3}));
    expect(blocked.loserId, 'p1');
    expect(legalMoves(blocked), isEmpty);
    expect(identical(apply(blocked, const Move(end: End.head, cell: 3)), blocked), isTrue);

    final open = assembled(width: 2, height: 2, head: 0, tail: 0, walls: {1, 2});
    final done = apply(open, const Move(end: End.head, cell: 3));
    expect(done.loserId, 'p2');
    expect(done.isTerminal, isTrue);
  });

  test('replay rebuilds the match and a tampered log fails', () {
    var live = dealClassic(seed: 4, players: four);
    final played = <Move>[];
    while (!live.isTerminal && played.length < 6) {
      final move = legalMoves(live).first;
      final next = apply(live, move);
      expect(identical(next, live), isFalse);
      played.add(move);
      live = next;
    }
    final log = MatchLog.capture(dealClassic(seed: 4, players: four), played);
    expect(log.replay(), live);

    final json = log.toJson();
    final restored = MatchLog.fromJson(json);
    expect(restored.replay(), live);

    final tampered = MatchLog(
      modeId: log.modeId,
      seed: log.seed,
      width: log.width,
      height: log.height,
      wallChance: log.wallChance,
      players: log.players,
      firstTurn: log.firstTurn,
      moves: const [Move(end: End.head, cell: 63)],
    );
    expect(tampered.replay, throwsA(isA<ReplayException>()));
  });
}
