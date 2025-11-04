import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight save manager for meta progression + options.
class SaveManager {
  static const _metaKey = 'meta_profile';
  static const _optionsKey = 'options';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<Map<String, dynamic>> loadMeta() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_metaKey);
    if (raw == null) {
      return {
        'currency': 0,
        'unlockedRings': 0,
        'blueprints': <String>[],
      };
    }
    return json.decode(raw) as Map<String, dynamic>;
  }

  Future<void> saveMeta(Map<String, dynamic> data) async {
    final prefs = await _prefs();
    await prefs.setString(_metaKey, json.encode(data));
  }

  Future<Map<String, dynamic>> loadOptions() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_optionsKey);
    if (raw == null) {
      return {
        'audio': 0.7,
        'reducedMotion': false,
        'colorBlindMode': 'none',
      };
    }
    return json.decode(raw) as Map<String, dynamic>;
  }

  Future<void> saveOptions(Map<String, dynamic> data) async {
    final prefs = await _prefs();
    await prefs.setString(_optionsKey, json.encode(data));
  }
}
