import 'dart:math' as math;

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
    final visited = <math.Point<int>>{};
    final start = math.Point<int>(columns ~/ 2, rows ~/ 2);
    final stack = <math.Point<int>>[start];

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

    _punchAdditionalLoops(grid);

    final spawnCells = _pickSpawnCells(grid, 3);

    final buildable = <math.Point<int>>{};
    final walkable = <math.Point<int>>{};
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        if (!grid[y][x]) {
          continue;
        }
        final cell = math.Point<int>(x, y);
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
      spawnCells: spawnCells.map(_toRelative).toList(growable: false),
      buildableCells: buildable,
      walkableCells: walkable,
      worldSize: worldSize,
      tileSize: tileSize,
    );
  }

  void _punchAdditionalLoops(List<List<bool>> grid) {
    final attempts = (columns * rows * 0.12).round();
    for (var i = 0; i < attempts; i++) {
      final x = rng.nextInt(columns - 2) + 1;
      final y = rng.nextInt(rows - 2) + 1;
      if (grid[y][x]) {
        continue;
      }
      final walkableNeighbors = _cardinalNeighbors(math.Point<int>(x, y))
          .where((neighbor) => grid[neighbor.y][neighbor.x])
          .length;
      if (walkableNeighbors >= 2) {
        grid[y][x] = true;
      }
    }
  }

  List<math.Point<int>> _unvisitedNeighbors(
      math.Point<int> cell, Set<math.Point<int>> visited) {
    final neighbors = <math.Point<int>>[];
    for (final direction in _directionOffsets) {
      final candidate =
          math.Point<int>(cell.x + direction.x * 2, cell.y + direction.y * 2);
      if (_inBounds(candidate) && !visited.contains(candidate)) {
        neighbors.add(candidate);
      }
    }
    return neighbors;
  }

  void _carvePath(List<List<bool>> grid, math.Point<int> from, math.Point<int> to) {
    final between = math.Point<int>((from.x + to.x) ~/ 2, (from.y + to.y) ~/ 2);
    grid[between.y][between.x] = true;
    grid[to.y][to.x] = true;
  }

  List<math.Point<int>> _pickSpawnCells(List<List<bool>> grid, int desired) {
    final borderCells = <math.Point<int>>[];
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        if (!grid[y][x]) {
          continue;
        }
        if (x == 0 || y == 0 || x == columns - 1 || y == rows - 1) {
          borderCells.add(math.Point<int>(x, y));
        }
      }
    }
    if (borderCells.isEmpty) {
      final candidates = <math.Point<int>>[];
      for (var y = 1; y < rows - 1; y++) {
        for (var x = 1; x < columns - 1; x++) {
          if (!grid[y][x]) {
            continue;
          }
          final dirs = _cardinalNeighbors(math.Point<int>(x, y)).where((neighbor) {
            if (!_inBounds(neighbor)) {
              return false;
            }
            return !grid[neighbor.y][neighbor.x];
          }).toList();
          if (dirs.isEmpty) {
            continue;
          }
          final edge = math.Point<int>(
            (dirs.first.x == x) ? dirs.first.x : (dirs.first.x < x ? 0 : columns - 1),
            (dirs.first.y == y) ? dirs.first.y : (dirs.first.y < y ? 0 : rows - 1),
          );
          grid[edge.y][edge.x] = true;
          candidates.add(edge);
        }
      }
      borderCells.addAll(candidates);
    }
    borderCells.shuffle(rng);
    if (borderCells.isEmpty) {
      return [math.Point<int>(columns - 1, rows ~/ 2)];
    }
    return borderCells.take(desired.clamp(1, borderCells.length)).toList();
  }

  Iterable<math.Point<int>> _cardinalNeighbors(math.Point<int> cell) sync* {
    for (final direction in _directionOffsets) {
      yield math.Point<int>(cell.x + direction.x, cell.y + direction.y);
    }
  }

  bool _inBounds(math.Point<int> cell) {
    return cell.x >= 0 && cell.y >= 0 && cell.x < columns && cell.y < rows;
  }

  math.Point<int> _toRelative(math.Point<int> absolute) {
    return math.Point<int>(absolute.x - columns ~/ 2, absolute.y - rows ~/ 2);
  }

  static const List<math.Point<int>> _directionOffsets = <math.Point<int>>[
    math.Point<int>(0, -1),
    math.Point<int>(1, 0),
    math.Point<int>(0, 1),
    math.Point<int>(-1, 0),
  ];
}
