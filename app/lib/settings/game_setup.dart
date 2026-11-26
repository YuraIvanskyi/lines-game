import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:rules/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'copy.dart';

enum Opponent { samePhone, computer, online }

const minPlayers = 2;
const maxPlayers = 4;

/// Long enough for a nickname, short enough for `<name>'s turn` on one line.
const maxNameLength = 12;

/// How many seat colors there are to pick from (`InkTheme.palette`).
const paletteSize = 8;

/// Seat colors when nobody has picked: palette slots 0..3.
const defaultColors = [0, 1, 2, 3];

/// [colors] with [seat] set to palette slot [color]. A seat that already had that color
/// takes the picker's old one, so no two seats ever share a color.
List<int> pickColor(List<int> colors, int seat, int color) {
  final next = List<int>.of(colors);
  final holder = next.indexOf(color);
  if (holder >= 0 && holder != seat) next[holder] = next[seat];
  next[seat] = color;
  return next;
}

/// A stored color list made safe: one valid, distinct slot per seat, gaps filled in order.
List<int> cleanColors(Iterable<int>? stored) {
  final kept = <int>[];
  for (final color in stored ?? const <int>[]) {
    if (kept.length == maxPlayers) break;
    if (color >= 0 && color < paletteSize && !kept.contains(color)) kept.add(color);
  }
  for (var color = 0; kept.length < maxPlayers; color++) {
    if (!kept.contains(color)) kept.add(color);
  }
  return kept;
}

/// [name] trimmed and cut to [maxNameLength] characters (whole emoji and accents kept).
String clipName(String name) {
  final trimmed = name.trim().characters;
  return trimmed.length <= maxNameLength ? trimmed.toString() : trimmed.take(maxNameLength).toString().trim();
}

/// What PLAY starts. Blank names follow the app language.
class GameSetup {
  const GameSetup({
    this.modeId = classicModeId,
    this.opponent = Opponent.samePhone,
    this.playerCount = minPlayers,
    this.names = const ['', '', '', ''],
    this.difficulty = Difficulty.easy,
    this.colors = defaultColors,
  });

  /// A [GameMode.id]; see [gameModes].
  final String modeId;
  final Opponent opponent;
  final int playerCount;
  final List<String> names;
  final Difficulty difficulty;

  /// Palette slot per seat, seat 1 first. The computer's seat uses slot [1].
  final List<int> colors;

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
              : clipName(names[i]).isEmpty
              ? copy.player(i + 1)
              : clipName(names[i]),
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
        other.modeId != modeId ||
        other.opponent != opponent ||
        other.playerCount != playerCount ||
        other.difficulty != difficulty ||
        other.names.length != names.length ||
        other.colors.length != colors.length) {
      return false;
    }
    for (var i = 0; i < names.length; i++) {
      if (names[i] != other.names[i]) return false;
    }
    for (var i = 0; i < colors.length; i++) {
      if (colors[i] != other.colors[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(modeId, opponent, playerCount, difficulty, Object.hashAll(names), Object.hashAll(colors));

  /// The setup with [modeId] swapped for another mode.
  GameSetup withMode(String modeId) {
    return GameSetup(
      modeId: modeId,
      opponent: opponent,
      playerCount: playerCount,
      names: names,
      difficulty: difficulty,
      colors: colors,
    );
  }
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
  static const modeKey = 'mode';
  static const opponentKey = 'opponent';
  static const playerCountKey = 'playerCount';
  static const namesKey = 'playerNames';
  static const difficultyKey = 'difficulty';
  static const colorsKey = 'playerColors';

  @override
  Future<GameSetup> load() async {
    final prefs = await SharedPreferences.getInstance();
    final opponent = Opponent.values.asNameMap()[prefs.getString(opponentKey)] ?? Opponent.samePhone;
    final count = (prefs.getInt(playerCountKey) ?? minPlayers).clamp(minPlayers, maxPlayers);
    final stored = prefs.getStringList(namesKey) ?? const [];
    final difficulty = Difficulty.values.asNameMap()[prefs.getString(difficultyKey)] ?? Difficulty.easy;
    return GameSetup(
      modeId: prefs.getString(modeKey) ?? classicModeId,
      opponent: opponent,
      difficulty: difficulty,
      playerCount: count,
      names: [for (var i = 0; i < maxPlayers; i++) i < stored.length ? stored[i] : ''],
      colors: cleanColors(prefs.getStringList(colorsKey)?.map((color) => int.tryParse(color) ?? -1)),
    );
  }

  @override
  Future<void> save(GameSetup setup) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(modeKey, setup.modeId);
    await prefs.setString(opponentKey, setup.opponent.name);
    await prefs.setInt(playerCountKey, setup.playerCount);
    await prefs.setStringList(namesKey, setup.names);
    await prefs.setString(difficultyKey, setup.difficulty.name);
    await prefs.setStringList(colorsKey, [for (final color in setup.colors) '$color']);
  }
}
