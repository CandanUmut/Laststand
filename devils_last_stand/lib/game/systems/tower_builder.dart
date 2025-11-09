import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants.dart';
import '../../data/tower_defs.dart';
import '../app_game.dart';
import '../components/tower.dart';
import 'ring_expansion.dart';
import 'pathfinding.dart';

class TowerBuilderSystem extends Component with HasGameRef<AppGame> {
  TowerBuilderSystem({
    required this.towerDatabase,
    required this.ringExpansion,
    required this.essence,
    required this.crackedSigils,
  });

  final TowerDatabase towerDatabase;
  final RingExpansionSystem ringExpansion;
  final ValueNotifier<int> essence;
  final ValueNotifier<int> crackedSigils;

  final Map<math.Point<int>, _PlacedTower> _towers = {};
  final Set<math.Point<int>> _buildableCells = <math.Point<int>>{};
  GridPathfinder? _pathfinding;

  int _redeemerCount = 0;

  Iterable<TowerComponent> get towers => _towers.values.map((entry) => entry.component);
  int get buildableCellCount => _buildableCells.length;

  void setBuildableCells(Set<math.Point<int>> cells) {
    _buildableCells
      ..clear()
      ..addAll(cells);
  }

  void setPathfinding(GridPathfinder pathfinding) {
    _pathfinding = pathfinding;
    for (final entry in _towers.entries) {
      if (entry.value.blocksPath) {
        _pathfinding?.blockCell(entry.key);
      }
    }
  }

  void prepareGhost(String towerId) {
    // TODO(nova): show placement preview when we add cursor tracking.
  }

  void clearGhost() {
    // No-op placeholder until the placement preview is implemented.
  }

  void setTowerTechFlags(Map<String, bool> flags) {
    // TODO(nova): propagate tower tech bonuses into placed towers.
  }

  bool placeTower(String towerId, Vector2 worldPosition) {
    final definition = towerDatabase.definitions[towerId];
    if (definition == null) {
      return false;
    }
    final cell = ringExpansion.worldToCell(worldPosition);
    if (cell == const math.Point<int>(0, 0)) {
      return false;
    }
    final isBlocking = definition.id == 'arcane_block';
    if (isBlocking) {
      final pathfinding = _pathfinding;
      if (pathfinding == null) {
        return false;
      }
      if (!pathfinding.layout.walkableCells.contains(cell)) {
        return false;
      }
      if (!pathfinding.canBlockCell(cell)) {
        return false;
      }
    } else if (_buildableCells.isNotEmpty && !_buildableCells.contains(cell)) {
      return false;
    }
    if (!ringExpansion.isCellUnlocked(cell)) {
      return false;
    }
    if (_towers.containsKey(cell)) {
      return false;
    }
    if (towerId == 'redeemer_totem') {
      if (_redeemerCount >= GameConstants.redeemerLimit) {
        return false;
      }
      if (!gameRef.spendSigil()) {
        return false;
      }
      _redeemerCount += 1;
    }
    if (!gameRef.spendEssence(definition.cost)) {
      return false;
    }
    final tower = createTowerComponent(definition, cell)
      ..position = ringExpansion.cellToWorld(cell);
    gameRef.world.add(tower);
    _towers[cell] = _PlacedTower(component: tower, blocksPath: isBlocking);
    if (isBlocking) {
      _pathfinding?.blockCell(cell);
    }
    return true;
  }

  void registerRedeemerConversion() {
    // Placeholder for future telemetry or once-per-run restrictions.
  }

  void removeTowerAt(math.Point<int> cell) {
    final removed = _towers.remove(cell);
    if (removed == null) {
      return;
    }
    if (removed.blocksPath) {
      _pathfinding?.unblockCell(cell);
    }
    removed.component.removeFromParent();
  }

  void reset() {
    for (final entry in _towers.values) {
      entry.component.removeFromParent();
    }
    _towers.clear();
    _redeemerCount = 0;
    _pathfinding?.clear();
  }
}

class _PlacedTower {
  _PlacedTower({required this.component, required this.blocksPath});

  final TowerComponent component;
  final bool blocksPath;
}
