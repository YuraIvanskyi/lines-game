import 'dart:math';

import 'match.dart';
import 'play.dart';

enum Difficulty { easy, hard }

/// Picks a growth for whoever is to move. Works for any seat and any player count.
abstract class Bot {
  const Bot();

  factory Bot.forDifficulty(Difficulty difficulty, {Random? random}) {
    return switch (difficulty) {
      Difficulty.easy => RandomBot(random: random),
      Difficulty.hard => SearchBot(random: random),
    };
  }

  /// Throws [ArgumentError] when the game is over, since no growth exists.
  Move choose(Match match);
}

/// Any legal growth, all equally likely.
class RandomBot extends Bot {
  RandomBot({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  Move choose(Match match) {
    final moves = _legal(match);
    return moves[_random.nextInt(moves.length)];
  }
}

/// Looks [depth] growths ahead and assumes every other seat plays to make it
/// get stuck. Scores a finished game by who lost, and an unfinished one by how
/// many dots the seat to move can still reach. Ties are broken at random.
///
/// Keep [depth] odd with two seats. The score reads best when the leaf is the
/// opponent's turn, and measured against [RandomBot] depths 3 and 5 win more
/// than 4 and 6, with 6 costing eight times the time of 5.
class SearchBot extends Bot {
  SearchBot({this.depth = 5, Random? random}) : _random = random ?? Random() {
    if (depth < 1) throw ArgumentError.value(depth, 'depth', 'must be at least 1');
  }

  final int depth;
  final Random _random;

  // A decided game outranks any mobility score, and a sooner win outranks a later one.
  static const _decided = 1000;
  static const _unbounded = 1 << 30;

  @override
  Move choose(Match match) {
    final moves = _legal(match);
    final me = match.currentPlayer.id;
    var best = -_unbounded;
    var bestMoves = <Move>[];
    for (final move in moves) {
      // Window starts just under the best so far: a tie comes back exact, a worse move bails early.
      final score = _value(apply(match, move), me, depth - 1, best - 1, _unbounded);
      if (score > best) {
        best = score;
        bestMoves = [move];
      } else if (score == best) {
        bestMoves.add(move);
      }
    }
    return bestMoves[_random.nextInt(bestMoves.length)];
  }

  /// Score of [match] for [me], after a growth that left [left] more to look ahead.
  int _value(Match match, String me, int left, int alpha, int beta) {
    if (match.isTerminal) {
      return match.loserId == me ? -_decided - left : _decided + left;
    }
    if (left == 0) return _mobility(match, me);
    final maximizing = match.currentPlayer.id == me;
    var best = maximizing ? -_unbounded : _unbounded;
    for (final move in legalMoves(match)) {
      final score = _value(apply(match, move), me, left - 1, alpha, beta);
      if (maximizing) {
        if (score > best) best = score;
        if (best > alpha) alpha = best;
      } else {
        if (score < best) best = score;
        if (best < beta) beta = best;
      }
      if (alpha >= beta) break;
    }
    return best;
  }

  /// Room to move is good on your own turn and bad on someone else's.
  int _mobility(Match match, String me) {
    final reach = {for (final move in legalMoves(match)) move.cell}.length;
    return match.currentPlayer.id == me ? reach : -reach;
  }
}

List<Move> _legal(Match match) {
  final moves = legalMoves(match);
  if (moves.isEmpty) throw ArgumentError('No legal growth: the game is over.');
  return moves;
}
