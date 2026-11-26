const classicModeId = 'classic';
const classicSize = 6;
const classicWallChance = 0.05;

const starsModeId = 'stars';

/// Stars on a [classicSize] field. Few enough that each one is a decision.
const starsCount = 4;

class GameMode {
  const GameMode({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.wallChance,
    this.stars = 0,
  });

  final String id;
  final String name;
  final int width;
  final int height;
  final double wallChance;

  /// Cells dealt with a star. Growing onto one gives the same player another growth.
  final int stars;

  GameMode copyWith({String? id, String? name, int? width, int? height, double? wallChance, int? stars}) {
    return GameMode(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      wallChance: wallChance ?? this.wallChance,
      stars: stars ?? this.stars,
    );
  }
}

const classicMode = GameMode(
  id: classicModeId,
  name: 'Classic',
  width: classicSize,
  height: classicSize,
  wallChance: classicWallChance,
);

/// Classic rules plus [starsCount] stars: land on one and you grow again.
const starsMode = GameMode(
  id: starsModeId,
  name: 'Stars',
  width: classicSize,
  height: classicSize,
  wallChance: classicWallChance,
  stars: starsCount,
);

/// Every mode the app offers, in menu order.
const gameModes = [classicMode, starsMode];
