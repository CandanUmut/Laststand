import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../core/rng.dart';
import '../../data/upgrade_defs.dart';
import '../../data/weapon_defs.dart';

class UpgradeDraftSystem extends Component {
  UpgradeDraftSystem({
    required this.upgradeDatabase,
    required this.weaponDatabase,
    required this.essence,
    required this.rng,
    required this.onUpgradeChosen,
  });

  final UpgradeDatabase upgradeDatabase;
  final WeaponDatabase weaponDatabase;
  final ValueNotifier<int> essence;
  final GameRng rng;
  final void Function(UpgradeDefinition) onUpgradeChosen;

  List<UpgradeDefinition> currentChoices = const [];

  void presentChoices() {
    final definitions = upgradeDatabase.definitions.values.toList();
    definitions.shuffle();
    currentChoices = definitions.take(3).toList();
    // TODO: trigger overlay to display cards.
  }

  void pickUpgrade(UpgradeDefinition upgrade) {
    onUpgradeChosen(upgrade);
    currentChoices = const [];
    // TODO: close overlay and resume game.
  }
}
