import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../data/tower_defs.dart';
import '../components/tower.dart';
import 'ring_expansion.dart';

class TowerBuilderSystem extends Component {
  TowerBuilderSystem({
    required this.towerDatabase,
    required this.ringExpansion,
    required this.essence,
  });

  final TowerDatabase towerDatabase;
  final RingExpansionSystem ringExpansion;
  final ValueNotifier<int> essence;

  TowerComponent? ghost;
  bool buildMode = false;
  String? selectedTowerId;

  void toggleBuildMode([bool? value]) {
    buildMode = value ?? !buildMode;
    if (!buildMode) {
      ghost?.removeFromParent();
      ghost = null;
    }
  }

  void selectTower(String id) {
    selectedTowerId = id;
  }

  void placeTower(Vector2 position) {
    if (!buildMode || selectedTowerId == null) {
      return;
    }
    final definition = towerDatabase.definitions[selectedTowerId];
    if (definition == null) {
      return;
    }
    if (essence.value < definition.cost) {
      return;
    }
    if (!ringExpansion.isTileUnlocked(position)) {
      // TODO: snap to grid and validate against unlocked rings properly.
      return;
    }
    final tower = TowerComponent(
      definition: definition,
      tier: 0,
      position: position,
    );
    gameRef.add(tower);
    essence.value -= definition.cost;
  }
}
