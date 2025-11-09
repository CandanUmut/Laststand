import 'dart:math' as math;

import 'package:flame/components.dart';

class LevelLayout {
  LevelLayout({
    required this.walkableGrid,
    required this.spawnCells,
    required this.buildableCells,
    required this.walkableCells,
    required this.worldSize,
    required this.tileSize,
  });

  final List<List<bool>> walkableGrid;
  final List<math.Point<int>> spawnCells;
  final Set<math.Point<int>> buildableCells;
  final Set<math.Point<int>> walkableCells;
  final Vector2 worldSize;
  final double tileSize;

  int get columns => walkableGrid.isEmpty ? 0 : walkableGrid.first.length;
  int get rows => walkableGrid.length;

  bool isWalkable(math.Point<int> cell) => walkableCells.contains(cell);

  Vector2 cellCenterWorld(math.Point<int> cell) {
    return Vector2(cell.x * tileSize, cell.y * tileSize);
  }
}
