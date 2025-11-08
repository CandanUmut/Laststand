import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants.dart';
import '../../data/tower_defs.dart';
import '../app_game.dart';
import '../components/tower.dart';
import 'ring_expansion.dart';

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

  final Map<Point<int>, TowerComponent> _towers = {};
  final Set<Point<int>> _buildableCells = <Point<int>>{};

  int _redeemerCount = 0;

  Iterable<TowerComponent> get towers => _towers.values;
  int get buildableCellCount => _buildableCells.length;

  void setBuildableCells(Set<Point<int>> cells) {
    _buildableCells
      ..clear()
      ..addAll(cells);
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
    if (cell == const Point<int>(0, 0)) {
      return false;
    }
    if (_buildableCells.isNotEmpty && !_buildableCells.contains(cell)) {
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
    _towers[cell] = tower;
    return true;
  }

  void registerRedeemerConversion() {
    // Placeholder for future telemetry or once-per-run restrictions.
  }

  void removeTowerAt(Point<int> cell) {
    final tower = _towers.remove(cell);
    tower?.removeFromParent();
  }

  void reset() {
    for (final tower in _towers.values) {
      tower.removeFromParent();
    }
    _towers.clear();
    _redeemerCount = 0;
  }
}
