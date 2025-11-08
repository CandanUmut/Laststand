import 'dart:collection';
import 'dart:math';

import 'package:flame/components.dart';

import '../../core/rng.dart';
import 'level_layout.dart';

class MazeGenerator {
  MazeGenerator({
    required this.columns,
    required this.rows,
    required this.tileSize,
    required this.rng,
  })  : assert(columns % 2 == 1, 'columns must be odd'),
        assert(rows % 2 == 1, 'rows must be odd');

  final int columns;
  final int rows;
  final double tileSize;
  final GameRng rng;

  LevelLayout generate() {
    final grid = List.generate(rows, (_) => List.filled(columns, false));
    final visited = <Point<int>>{};
    final start = Point<int>(columns ~/ 2, rows ~/ 2);
    final stack = <Point<int>>[start];

    grid[start.y][start.x] = true;
    visited.add(start);

    while (stack.isNotEmpty) {
      final current = stack.last;
      final neighbors = _unvisitedNeighbors(current, visited);
      if (neighbors.isEmpty) {
        stack.removeLast();
        continue;
      }
      final chosen = neighbors[rng.nextInt(neighbors.length)];
      _carvePath(grid, current, chosen);
      visited.add(chosen);
      stack.add(chosen);
    }

    final spawnCell = _pickSpawnCell(grid);
    final pathCells = _pathBetween(grid, spawnCell, start);

    final spawnPosition = _toWorld(spawnCell);
    final pathTargets = pathCells.skip(1).map(_toWorld).toList(growable: false);

    final buildable = <Point<int>>{};
    final walkable = <Point<int>>{};
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        if (!grid[y][x]) {
          continue;
        }
        final cell = Point<int>(x, y);
        walkable.add(_toRelative(cell));
        for (final neighbor in _cardinalNeighbors(cell)) {
          if (_inBounds(neighbor) && !grid[neighbor.y][neighbor.x]) {
            buildable.add(_toRelative(neighbor));
          }
        }
      }
    }

    final worldSize = Vector2(columns * tileSize.toDouble(), rows * tileSize.toDouble());

    return LevelLayout(
      walkableGrid: grid,
      pathTargets: pathTargets,
      spawnPosition: spawnPosition,
      buildableCells: buildable,
      walkableCells: walkable,
      worldSize: worldSize,
      tileSize: tileSize,
    );
  }

  List<Point<int>> _unvisitedNeighbors(Point<int> cell, Set<Point<int>> visited) {
    final neighbors = <Point<int>>[];
    for (final direction in _directionOffsets) {
      final candidate = Point<int>(cell.x + direction.x * 2, cell.y + direction.y * 2);
      if (_inBounds(candidate) && !visited.contains(candidate)) {
        neighbors.add(candidate);
      }
    }
    return neighbors;
  }

  void _carvePath(List<List<bool>> grid, Point<int> from, Point<int> to) {
    final between = Point<int>((from.x + to.x) ~/ 2, (from.y + to.y) ~/ 2);
    grid[between.y][between.x] = true;
    grid[to.y][to.x] = true;
  }

  Point<int> _pickSpawnCell(List<List<bool>> grid) {
    final borderCells = <Point<int>>[];
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        if (!grid[y][x]) {
          continue;
        }
        if (x == 0 || y == 0 || x == columns - 1 || y == rows - 1) {
          borderCells.add(Point<int>(x, y));
        }
      }
    }
    if (borderCells.isEmpty) {
      final candidates = <Point<int>>[];
      for (var y = 0; y < rows; y++) {
        for (var x = 0; x < columns; x++) {
          if (!grid[y][x]) {
            continue;
          }
          if (x == 1) {
            final edge = Point<int>(0, y);
            grid[edge.y][edge.x] = true;
            candidates.add(edge);
          } else if (x == columns - 2) {
            final edge = Point<int>(columns - 1, y);
            grid[edge.y][edge.x] = true;
            candidates.add(edge);
          } else if (y == 1) {
            final edge = Point<int>(x, 0);
            grid[edge.y][edge.x] = true;
            candidates.add(edge);
          } else if (y == rows - 2) {
            final edge = Point<int>(x, rows - 1);
            grid[edge.y][edge.x] = true;
            candidates.add(edge);
          }
        }
      }
      if (candidates.isNotEmpty) {
        borderCells.add(candidates[rng.nextInt(candidates.length)]);
      }
    }
    return borderCells.isNotEmpty
        ? borderCells[rng.nextInt(borderCells.length)]
        : Point<int>(columns - 1, rows ~/ 2);
  }

  List<Point<int>> _pathBetween(List<List<bool>> grid, Point<int> start, Point<int> goal) {
    final queue = Queue<Point<int>>()..add(start);
    final cameFrom = <Point<int>, Point<int>>{};
    final visited = <Point<int>>{start};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == goal) {
        break;
      }
      for (final neighbor in _cardinalNeighbors(current)) {
        if (!_inBounds(neighbor) || visited.contains(neighbor)) {
          continue;
        }
        if (!grid[neighbor.y][neighbor.x]) {
          continue;
        }
        visited.add(neighbor);
        queue.add(neighbor);
        cameFrom[neighbor] = current;
      }
    }

    final path = <Point<int>>[];
    var current = goal;
    path.add(current);
    final safety = rows * columns;
    var steps = 0;
    while (current != start && cameFrom.containsKey(current) && steps < safety) {
      current = cameFrom[current]!;
      path.add(current);
      steps += 1;
    }
    if (current != start) {
      path
        ..clear()
        ..addAll([start, goal]);
    } else {
      path.add(start);
    }
    return path.reversed.toList(growable: false);
  }

  Iterable<Point<int>> _cardinalNeighbors(Point<int> cell) sync* {
    for (final direction in _directionOffsets) {
      yield Point<int>(cell.x + direction.x, cell.y + direction.y);
    }
  }

  bool _inBounds(Point<int> cell) {
    return cell.x >= 0 && cell.y >= 0 && cell.x < columns && cell.y < rows;
  }

  Point<int> _toRelative(Point<int> absolute) {
    return Point<int>(absolute.x - columns ~/ 2, absolute.y - rows ~/ 2);
  }

  Vector2 _toWorld(Point<int> cell) {
    final relative = _toRelative(cell);
    return Vector2(relative.x * tileSize, relative.y * tileSize);
  }

  static const List<Point<int>> _directionOffsets = <Point<int>>[
    Point<int>(0, -1),
    Point<int>(1, 0),
    Point<int>(0, 1),
    Point<int>(-1, 0),
  ];
}
