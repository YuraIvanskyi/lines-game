const classicModeId = 'classic';
const classicSize = 6;
const classicWallChance = 0.05;

class GameMode {
  const GameMode({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.wallChance,
  });

  final String id;
  final String name;
  final int width;
  final int height;
  final double wallChance;

  GameMode copyWith({String? id, String? name, int? width, int? height, double? wallChance}) {
    return GameMode(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      wallChance: wallChance ?? this.wallChance,
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
