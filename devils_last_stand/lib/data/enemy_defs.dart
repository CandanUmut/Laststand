import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/assets.dart';

class EnemyDefinition {
  EnemyDefinition({
    required this.id,
    required this.displayName,
    required this.speed,
    required this.health,
    required this.damage,
    required this.isElite,
    required this.dropTable,
  });

  factory EnemyDefinition.fromJson(Map<String, dynamic> json) {
    return EnemyDefinition(
      id: json['id'] as String,
      displayName: json['name'] as String,
      speed: (json['speed'] as num).toDouble(),
      health: (json['health'] as num).toDouble(),
      damage: (json['damage'] as num).toDouble(),
      isElite: json['elite'] as bool? ?? false,
      dropTable: Map<String, double>.from(json['drops'] as Map),
    );
  }

  final String id;
  final String displayName;
  final double speed;
  final double health;
  final double damage;
  final bool isElite;
  final Map<String, double> dropTable;
}

class EnemyDatabase {
  EnemyDatabase(this.definitions);

  final Map<String, EnemyDefinition> definitions;

  static Future<EnemyDatabase> load() async {
    final raw = await rootBundle.loadString(AppAssets.dataEnemies);
    final data = json.decode(raw) as List<dynamic>;
    final entries = {
      for (final item in data)
        (item['id'] as String): EnemyDefinition.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
    };
    return EnemyDatabase(entries);
  }
}
