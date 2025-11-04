import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/assets.dart';

class TowerTierStats {
  TowerTierStats({
    required this.range,
    required this.damage,
    required this.fireRate,
    required this.special,
  });

  factory TowerTierStats.fromJson(Map<String, dynamic> json) {
    return TowerTierStats(
      range: (json['range'] as num).toDouble(),
      damage: (json['damage'] as num).toDouble(),
      fireRate: (json['fireRate'] as num).toDouble(),
      special: json['special'] as String? ?? '',
    );
  }

  final double range;
  final double damage;
  final double fireRate;
  final String special;
}

class TowerDefinition {
  TowerDefinition({
    required this.id,
    required this.displayName,
    required this.cost,
    required this.allowedTargets,
    required this.tiers,
  });

  factory TowerDefinition.fromJson(Map<String, dynamic> json) {
    return TowerDefinition(
      id: json['id'] as String,
      displayName: json['name'] as String,
      cost: json['cost'] as int,
      allowedTargets: List<String>.from(json['targets'] as List),
      tiers: (json['tiers'] as List)
          .map((tier) => TowerTierStats.fromJson(
                Map<String, dynamic>.from(tier as Map),
              ))
          .toList(),
    );
  }

  final String id;
  final String displayName;
  final int cost;
  final List<String> allowedTargets;
  final List<TowerTierStats> tiers;
}

class TowerDatabase {
  TowerDatabase(this.definitions);

  final Map<String, TowerDefinition> definitions;

  static Future<TowerDatabase> load() async {
    final raw = await rootBundle.loadString(AppAssets.dataTowers);
    final data = json.decode(raw) as List<dynamic>;
    final entries = {
      for (final item in data)
        (item['id'] as String): TowerDefinition.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
    };
    return TowerDatabase(entries);
  }
}
