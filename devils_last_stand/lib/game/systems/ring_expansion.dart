import 'dart:math';

import 'package:flame/components.dart';

import '../../core/constants.dart';

class RingExpansionSystem extends Component {
  RingExpansionSystem({
    required this.startingRings,
    required this.tileSize,
  }) : unlockedRings = startingRings;

  int unlockedRings;
  final int startingRings;
  final double tileSize;

  bool isCellUnlocked(Point<int> cell) {
    return ringForCell(cell) <= unlockedRings;
  }

  bool isCellUnlockedVector(Vector2 position) {
    return isCellUnlocked(worldToCell(position));
  }

  int ringForCell(Point<int> cell) {
    final absX = cell.x.abs();
    final absY = cell.y.abs();
    return absX > absY ? absX : absY;
  }

  Point<int> worldToCell(Vector2 position) {
    final snappedX = (position.x / tileSize).round();
    final snappedY = (position.y / tileSize).round();
    return Point<int>(snappedX, snappedY);
  }

  Vector2 cellToWorld(Point<int> cell) {
    return Vector2(cell.x * tileSize.toDouble(), cell.y * tileSize.toDouble());
  }

  bool isCellEmpty(Point<int> cell, Iterable<Point<int>> occupied) {
    return !occupied.contains(cell);
  }

  void unlockNextRing() {
    unlockedRings += 1;
  }
}
