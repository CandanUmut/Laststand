import 'dart:collection';
import 'dart:math' as math;

import 'package:flame/components.dart';

import 'level_layout.dart';

class PathNavigator {
  PathNavigator({required this.path}) : _index = 0;

  final List<Vector2> path;
  int _index;

  Vector2 stepTowards(Vector2 position) {
    if (_index >= path.length) {
      return Vector2.zero();
    }
    final target = path[_index];
    final direction = (target - position);
    if (direction.length2 < 16) {
      _index++;
      return stepTowards(position);
    }
    return direction.normalized();
  }
}

class GridPathfinder {
  GridPathfinder({required this.layout});

  final LevelLayout layout;
  final Set<math.Point<int>> _blocked = <math.Point<int>>{};

  Iterable<math.Point<int>> get spawnCells => layout.spawnCells;

  void clear() {
    _blocked.clear();
  }

  void blockCell(math.Point<int> cell) {
    _blocked.add(cell);
  }

  void unblockCell(math.Point<int> cell) {
    _blocked.remove(cell);
  }

  bool canBlockCell(math.Point<int> cell) {
    if (!layout.walkableCells.contains(cell) || _blocked.contains(cell)) {
      return false;
    }
    _blocked.add(cell);
    final hasPath =
        spawnCells.every((spawn) => _findPath(spawn, const math.Point<int>(0, 0)) != null);
    _blocked.remove(cell);
    return hasPath;
  }

  PathNavigator? navigatorFromSpawn(math.Point<int> spawnCell) {
    final path = _findPath(spawnCell, const math.Point<int>(0, 0));
    if (path == null || path.length < 2) {
      return null;
    }
    final points = path.map(layout.cellCenterWorld).toList(growable: false);
    return PathNavigator(path: points);
  }

  List<math.Point<int>>? _findPath(math.Point<int> start, math.Point<int> goal) {
    if (!_isWalkable(start) || !_isWalkable(goal)) {
      return null;
    }
    final queue = Queue<math.Point<int>>()..addLast(start);
    final cameFrom = <math.Point<int>, math.Point<int>>{};
    final visited = <math.Point<int>>{start};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == goal) {
        break;
      }
      for (final neighbor in _neighbors(current)) {
        if (visited.contains(neighbor)) {
          continue;
        }
        visited.add(neighbor);
        cameFrom[neighbor] = current;
        queue.addLast(neighbor);
      }
    }

    if (!visited.contains(goal)) {
      return null;
    }

    final path = <math.Point<int>>[];
    var current = goal;
    path.add(current);
    var safety = layout.columns * layout.rows;
    while (current != start && safety-- > 0) {
      final previous = cameFrom[current];
      if (previous == null) {
        break;
      }
      current = previous;
      path.add(current);
    }
    if (current != start) {
      return null;
    }
    return path.reversed.toList(growable: false);
  }

  bool _isWalkable(math.Point<int> cell) {
    return layout.walkableCells.contains(cell) && !_blocked.contains(cell);
  }

  Iterable<math.Point<int>> _neighbors(math.Point<int> cell) sync* {
    const offsets = <math.Point<int>>[
      math.Point<int>(0, -1),
      math.Point<int>(1, 0),
      math.Point<int>(0, 1),
      math.Point<int>(-1, 0),
    ];
    for (final offset in offsets) {
      final next = math.Point<int>(cell.x + offset.x, cell.y + offset.y);
      if (_isWalkable(next)) {
        yield next;
      }
    }
  }
}
