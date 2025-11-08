import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight storage facade that stays web/mobile safe by relying solely on
/// [SharedPreferences]. The keys live next to the places that read them so the
/// data stays malleable while we shape the MVP.
class Storage {
  Storage._();

  static final Storage instance = Storage._();

  SharedPreferences? _prefs;

  /// Keys that other systems rely on. Intentionally kept small for now.
  static const keyOptionsVolume = 'options.volume';
  static const keyOptionsReducedMotion = 'options.reducedMotion';
  static const keyOptionsColorBlindMode = 'options.colorBlindMode';
  static const keyMetaCurrency = 'meta.currency';
  static const keyMetaUnlocks = 'meta.unlocks';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _ensurePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('Storage.init() must be awaited before use.');
    }
    return prefs;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _ensurePrefs.getInt(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) {
    return _ensurePrefs.setInt(key, value);
  }

  double getDouble(String key, {double defaultValue = 0}) {
    return _ensurePrefs.getDouble(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) {
    return _ensurePrefs.setDouble(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _ensurePrefs.getBool(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) {
    return _ensurePrefs.setBool(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _ensurePrefs.getString(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) {
    return _ensurePrefs.setString(key, value);
  }
}
