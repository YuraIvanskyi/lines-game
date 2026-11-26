import 'dart:math';

import 'package:rules/rules.dart';
import 'package:test/test.dart';

const players = [
  Player(id: 'p1', name: 'Player 1'),
  Player(id: 'p2', name: 'Player 2'),
];

/// King distance between two cells of [match].
int reach(Match match, int a, int b) =>
    max((match.xOf(a) - match.xOf(b)).abs(), (match.yOf(a) - match.yOf(b)).abs());

/// A 4×1 strip `0 1 2 3` with the anchor on 0 and the given stars.
Match strip(Set<int> stars, {int head = 0}) {
  return Match(
    width: 4,
    height: 1,
    seed: 0,
    modeId: starsModeId,
    wallChance: 0,
    walls: BitGrid.empty(4),
    stars: BitGrid.of(4, stars),
    occupied: BitGrid.of(4, [head]),
    head: head,
    tail: head,
    segments: const [],
    players: players,
    turn: 0,
    firstTurn: 0,
  );
}

void main() {
  test('the stars mode is classic plus four stars', () {
    expect(starsMode.width, classicMode.width);
    expect(starsMode.height, classicMode.height);
    expect(starsMode.wallChance, classicMode.wallChance);
    expect(starsMode.stars, 4);
    expect(classicMode.stars, 0);
    expect(gameModes.map((mode) => mode.id), [classicModeId, starsModeId]);
  });

  test('a classic deal draws no stars and keeps its exact board', () {
    for (var seed = 0; seed < 50; seed++) {
      final classic = deal(classicMode, seed: seed);
      expect(classic.openStars, isEmpty);
      final starred = deal(starsMode, seed: seed);
      // Stars come after the wall rolls, so anchor and walls match the classic deal.
      expect(starred.head, classic.head);
      expect(starred.walls, classic.walls);
    }
  });

  test('stars land on open cells away from the anchor, the same way per seed', () {
    for (var seed = 0; seed < 200; seed++) {
      final match = deal(starsMode, seed: seed);
      final stars = match.openStars.toList();
      expect(stars, hasLength(starsCount), reason: 'seed $seed');
      for (final cell in stars) {
        expect(match.walls.test(cell), isFalse);
        expect(reach(match, cell, match.head), greaterThan(1), reason: 'seed $seed star $cell');
      }
      expect(deal(starsMode, seed: seed).openStars.toList(), stars);
    }
    expect(deal(starsMode, seed: 1).stars, isNot(deal(starsMode, seed: 2).stars));
  });

  test('a cramped field deals as many stars as fit', () {
    final match = dealClassic(seed: 3, width: 3, height: 1, wallChance: 0, stars: 4);
    expect(match.openStars.length, lessThanOrEqualTo(1));
  });

  test('growing onto a star keeps the turn, anywhere else passes it', () {
    final match = strip({1});
    final starred = apply(match, const Move(end: End.head, cell: 1));
    expect(starred.currentPlayer.id, 'p1');
    expect(starred.onStar, isTrue);
    expect(starred.openStars, isEmpty);
    expect(starred.segments.single.playerId, 'p1');

    final plain = apply(starred, const Move(end: End.head, cell: 2));
    expect(plain.currentPlayer.id, 'p2');
    expect(plain.onStar, isFalse);
  });

  test('a star that leaves no growth loses on the spot', () {
    // p1 grows to 1, p2 to 2, then p1 takes the star on 3 at the end of the strip: no growth left.
    final match = apply(strip({3}, head: 0), const Move(end: End.head, cell: 1));
    final greedy = apply(apply(match, const Move(end: End.head, cell: 2)), const Move(end: End.head, cell: 3));
    expect(greedy.isTerminal, isTrue);
    expect(greedy.loserId, 'p1');
    expect(greedy.onStar, isFalse);
  });

  test('logs keep the stars and replay the same game', () {
    var match = deal(starsMode, seed: 42, players: players);
    final moves = <Move>[];
    final rng = Random(7);
    while (!match.isTerminal) {
      final legal = legalMoves(match);
      final move = legal[rng.nextInt(legal.length)];
      moves.add(move);
      match = apply(match, move);
    }
    final log = MatchLog.capture(match, moves);
    expect(log.stars, starsCount);
    final json = log.toJson();
    expect(json['stars'], starsCount);
    expect(MatchLog.fromJson(json).replay(), match);

    // A log written before stars existed still loads, as a starless deal.
    final old = Map<String, Object?>.of(MatchLog.capture(deal(classicMode, seed: 5), const []).toJson())..remove('stars');
    expect(MatchLog.fromJson(old).stars, 0);
  });

  test('both bots finish star games', () {
    for (final bot in [RandomBot(random: Random(1)), SearchBot(depth: 3, random: Random(1))]) {
      for (var seed = 0; seed < 10; seed++) {
        var match = deal(starsMode, seed: seed);
        var guard = 0;
        while (!match.isTerminal) {
          match = apply(match, bot.choose(match));
          expect(++guard, lessThan(40));
        }
      }
    }
  });
}
