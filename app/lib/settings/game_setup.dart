import 'package:rules/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'copy.dart';

enum Opponent { samePhone, computer, online }

const minPlayers = 2;
const maxPlayers = 4;

/// What PLAY starts. Blank names follow the app language.
class GameSetup {
  const GameSetup({
    this.opponent = Opponent.samePhone,
    this.playerCount = minPlayers,
    this.names = const ['', '', '', ''],
    this.difficulty = Difficulty.easy,
  });

  final Opponent opponent;
  final int playerCount;
  final List<String> names;
  final Difficulty difficulty;

  static const defaults = GameSetup();

  /// The human takes seat 1 and the computer seat 2, whatever player count was saved.
  static const computerSeat = 'p2';

  bool get vsComputer => opponent == Opponent.computer;

  int get seatCount => vsComputer ? 2 : playerCount;

  List<Player> players(Copy copy) {
    return [
      for (var i = 0; i < seatCount; i++)
        Player(
          id: 'p${i + 1}',
          name: vsComputer && i == 1
              ? copy.computer
              : names[i].trim().isEmpty
              ? copy.player(i + 1)
              : names[i].trim(),
        ),
    ];
  }

  /// Seats the app plays for. Empty when everyone shares the phone.
  Map<String, Bot> bots() {
    if (!vsComputer) return const {};
    return {computerSeat: Bot.forDifficulty(difficulty)};
  }

  @override
  bool operator ==(Object other) {
    if (other is! GameSetup ||
        other.opponent != opponent ||
        other.playerCount != playerCount ||
        other.difficulty != difficulty) {
      return false;
    }
    for (var i = 0; i < names.length; i++) {
      if (names[i] != other.names[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(opponent, playerCount, difficulty, Object.hashAll(names));
}

abstract class GameSetupStore {
  Future<GameSetup> load();
  Future<void> save(GameSetup setup);
}

class MemoryGameSetupStore implements GameSetupStore {
  MemoryGameSetupStore([this._setup = GameSetup.defaults]);

  GameSetup _setup;

  @override
  Future<GameSetup> load() async => _setup;

  @override
  Future<void> save(GameSetup setup) async {
    _setup = setup;
  }
}

/// The saved setup kept on the device.
class SharedPrefsGameSetupStore implements GameSetupStore {
  static const opponentKey = 'opponent';
  static const playerCountKey = 'playerCount';
  static const namesKey = 'playerNames';
  static const difficultyKey = 'difficulty';

  @override
  Future<GameSetup> load() async {
    final prefs = await SharedPreferences.getInstance();
    final opponent = Opponent.values.asNameMap()[prefs.getString(opponentKey)] ?? Opponent.samePhone;
    final count = (prefs.getInt(playerCountKey) ?? minPlayers).clamp(minPlayers, maxPlayers);
    final stored = prefs.getStringList(namesKey) ?? const [];
    final difficulty = Difficulty.values.asNameMap()[prefs.getString(difficultyKey)] ?? Difficulty.easy;
    return GameSetup(
      opponent: opponent,
      difficulty: difficulty,
      playerCount: count,
      names: [for (var i = 0; i < maxPlayers; i++) i < stored.length ? stored[i] : ''],
    );
  }

  @override
  Future<void> save(GameSetup setup) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(opponentKey, setup.opponent.name);
    await prefs.setInt(playerCountKey, setup.playerCount);
    await prefs.setStringList(namesKey, setup.names);
    await prefs.setString(difficultyKey, setup.difficulty.name);
  }
}
