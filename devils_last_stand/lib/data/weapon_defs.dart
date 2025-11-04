import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/assets.dart';

class WeaponDefinition {
  WeaponDefinition({
    required this.id,
    required this.displayName,
    required this.fireRate,
    required this.damage,
    required this.range,
    required this.behavior,
  });

  factory WeaponDefinition.fromJson(Map<String, dynamic> json) {
    return WeaponDefinition(
      id: json['id'] as String,
      displayName: json['name'] as String,
      fireRate: (json['fireRate'] as num).toDouble(),
      damage: (json['damage'] as num).toDouble(),
      range: (json['range'] as num).toDouble(),
      behavior: json['behavior'] as String,
    );
  }

  final String id;
  final String displayName;
  final double fireRate;
  final double damage;
  final double range;
  final String behavior;
}

class WeaponDatabase {
  WeaponDatabase(this.definitions);

  final Map<String, WeaponDefinition> definitions;

  static Future<WeaponDatabase> load() async {
    final raw = await rootBundle.loadString(AppAssets.dataWeapons);
    final data = json.decode(raw) as List<dynamic>;
    final entries = {
      for (final item in data)
        (item['id'] as String): WeaponDefinition.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
    };
    return WeaponDatabase(entries);
  }
}
