import 'package:flame/components.dart';

/// Extremely lightweight grid-based path navigator placeholder.
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
    if (direction.length2 < 4) {
      _index++;
      return stepTowards(position);
    }
    return direction.normalized();
  }
}

/// TODO: replace with actual grid A* that re-runs when towers block lanes.
class PathfindingSystem {
  PathfindingSystem({required this.gridSize});

  final Vector2 gridSize;

  PathNavigator navigatorFor(Vector2 from, Vector2 to) {
    final waypoints = List<Vector2>.generate(
      5,
      (index) => Vector2(
        from.x + (to.x - from.x) * (index + 1) / 5,
        from.y + (to.y - from.y) * (index + 1) / 5,
      ),
    );
    return PathNavigator(path: waypoints);
  }
}
