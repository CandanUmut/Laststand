import 'dart:math';

import 'package:flame/components.dart';

import 'pathfinding.dart';

class LevelLayout {
  LevelLayout({
    required this.walkableGrid,
    required this.pathTargets,
    required this.spawnPosition,
    required this.buildableCells,
    required this.walkableCells,
    required this.worldSize,
    required this.tileSize,
  });

  final List<List<bool>> walkableGrid;
  final List<Vector2> pathTargets;
  final Vector2 spawnPosition;
  final Set<Point<int>> buildableCells;
  final Set<Point<int>> walkableCells;
  final Vector2 worldSize;
  final double tileSize;

  int get columns => walkableGrid.isEmpty ? 0 : walkableGrid.first.length;
  int get rows => walkableGrid.length;

  PathNavigator createNavigator() {
    return PathNavigator(path: List<Vector2>.from(pathTargets));
  }

  bool isWalkable(Point<int> cell) => walkableCells.contains(cell);
}
