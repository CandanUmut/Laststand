import 'package:flutter/foundation.dart';

import '../../core/rng.dart';
import '../../data/upgrade_defs.dart';

typedef UpgradeChosenCallback = void Function(UpgradeDefinition definition);

class UpgradeDraftSystem {
  UpgradeDraftSystem({
    required this.upgradeDatabase,
    required this.rng,
    required this.onUpgradeChosen,
  });

  final UpgradeDatabase upgradeDatabase;
  final GameRng rng;
  final UpgradeChosenCallback onUpgradeChosen;

  final ValueNotifier<List<UpgradeDefinition>> choices =
      ValueNotifier<List<UpgradeDefinition>>(<UpgradeDefinition>[]);

  List<UpgradeDefinition> get currentChoices => List.unmodifiable(choices.value);

  void presentChoices() {
    final pool = upgradeDatabase.definitions.values.toList();
    for (var i = pool.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = pool[i];
      pool[i] = pool[j];
      pool[j] = tmp;
    }
    choices.value = pool.take(3).toList();
  }

  void pickUpgrade(UpgradeDefinition definition) {
    onUpgradeChosen(definition);
    choices.value = const <UpgradeDefinition>[];
  }
}
