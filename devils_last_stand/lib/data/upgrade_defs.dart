import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/assets.dart';

enum UpgradeType { playerPerk, weaponMod, towerTech }

class UpgradeDefinition {
  UpgradeDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.type,
    required this.effects,
  });

  factory UpgradeDefinition.fromJson(Map<String, dynamic> json) {
    return UpgradeDefinition(
      id: json['id'] as String,
      displayName: json['name'] as String,
      description: json['description'] as String,
      type: UpgradeType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => UpgradeType.playerPerk,
      ),
      effects: Map<String, dynamic>.from(json['effects'] as Map),
    );
  }

  final String id;
  final String displayName;
  final String description;
  final UpgradeType type;
  final Map<String, dynamic> effects;
}

class UpgradeDatabase {
  UpgradeDatabase(this.definitions);

  final Map<String, UpgradeDefinition> definitions;

  static Future<UpgradeDatabase> load() async {
    final raw = await rootBundle.loadString(AppAssets.dataUpgrades);
    final data = json.decode(raw) as List<dynamic>;
    final entries = {
      for (final item in data)
        (item['id'] as String): UpgradeDefinition.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
    };
    return UpgradeDatabase(entries);
  }
}
