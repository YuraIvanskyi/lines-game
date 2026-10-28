import 'dart:math';

import 'package:rules/rules.dart';
import 'package:test/test.dart';

import 'classic_test.dart' show four;

/// Plays one game to the end and returns the loser's id.
String playOut(Match start, Bot Function(String playerId) botFor) {
  var match = start;
  while (!match.isTerminal) {
    match = apply(match, botFor(match.currentPlayer.id).choose(match));
  }
  return match.loserId!;
}

/// Exhaustive: can the seat to move force the other of two seats to get stuck?
bool moverWins(Match match) {
  for (final move in legalMoves(match)) {
    final next = apply(match, move);
    if (next.isTerminal || !moverWins(next)) return true;
  }
  return false;
}

void main() {
  group('RandomBot', () {
    test('only plays legal growths and finishes a game', () {
      final bot = RandomBot(random: Random(3));
      var match = deal(classicMode, seed: 5);
      while (!match.isTerminal) {
        final move = bot.choose(match);
        expect(legalMoves(match), contains(move));
        match = apply(match, move);
      }
      expect(match.loserId, isNotNull);
    });

    test('is not stuck on one answer', () {
      final bot = RandomBot(random: Random(1));
      final match = deal(classicMode, seed: 5);
      final picks = {for (var i = 0; i < 60; i++) bot.choose(match)};
      expect(picks.length, greaterThan(1));
    });

    test('refuses a finished game', () {
      final lost = deal(classicMode, seed: 5).copyWith(loserId: 'p1');
      expect(() => RandomBot().choose(lost), throwsArgumentError);
    });
  });

  group('SearchBot', () {
    test('never gives away a forced win on small boards', () {
      // Deep enough to see to the end of a 3×4 field, so its answer must match the solver.
      final small = classicMode.copyWith(width: 3, height: 4, wallChance: 0.1);
      final walker = RandomBot(random: Random(7));
      var mixed = 0;
      for (var seed = 0; seed < 40; seed++) {
        var match = deal(small, seed: seed);
        while (!match.isTerminal) {
          final winning = {
            for (final move in legalMoves(match))
              if (apply(match, move).isTerminal || !moverWins(apply(match, move))) move,
          };
          if (winning.isNotEmpty) {
            if (winning.length < legalMoves(match).length) mixed++;
            final move = SearchBot(depth: 12, random: Random(seed)).choose(match);
            expect(winning, contains(move), reason: 'seed $seed, $move loses by force');
          }
          match = apply(match, walker.choose(match));
        }
      }
      // Guards against the check passing only because every move won.
      expect(mixed, greaterThan(10));
    });

    test('works for four seats', () {
      final bot = SearchBot(depth: 3, random: Random(2));
      var match = deal(classicMode, seed: 8, players: four);
      while (!match.isTerminal) {
        final move = bot.choose(match);
        expect(legalMoves(match), contains(move));
        match = apply(match, move);
      }
      expect(four.map((player) => player.id), contains(match.loserId));
    });

    test('rejects a depth below one', () {
      expect(() => SearchBot(depth: 0), throwsArgumentError);
    });

    test('refuses a finished game', () {
      final lost = deal(classicMode, seed: 5).copyWith(loserId: 'p1');
      expect(() => SearchBot().choose(lost), throwsArgumentError);
    });

    test('answers the widest position, a fresh board, quickly', () {
      final stopwatch = Stopwatch()..start();
      SearchBot(random: Random(1)).choose(deal(classicMode, seed: 4));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('beats the random bot most of the time', () {
      const games = 60;
      var wins = 0;
      for (var i = 0; i < games; i++) {
        final seat = i.isEven ? 'p1' : 'p2';
        final start = deal(classicMode, seed: 100 + i, firstTurn: (i ~/ 2).isEven ? 0 : 1);
        final loser = playOut(
          start,
          (id) => id == seat ? SearchBot(random: Random(i)) : RandomBot(random: Random(i)),
        );
        if (loser != seat) wins++;
      }
      // Measured around 90% over 200 games; random against random is a coin flip.
      expect(wins, greaterThanOrEqualTo(48), reason: 'won $wins of $games');
    });
  });

  group('Bot.forDifficulty', () {
    test('easy is random and hard is a search', () {
      expect(Bot.forDifficulty(Difficulty.easy), isA<RandomBot>());
      expect(Bot.forDifficulty(Difficulty.hard), isA<SearchBot>());
    });
  });
}
