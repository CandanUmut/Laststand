import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants.dart';
import '../../data/enemy_defs.dart';

typedef SpawnEnemyCallback = Future<void> Function(EnemyDefinition definition);

typedef WaveCompletedCallback = void Function(int clearedWave);

typedef WaveTimerCallback = void Function(double secondsRemaining);

class WaveManager extends Component {
  WaveManager({
    required this.enemyDatabase,
    required this.waveIndex,
    required this.onWaveCompleted,
    required this.spawnEnemy,
    required this.onWaveTimerChanged,
  });

  final EnemyDatabase enemyDatabase;
  final ValueNotifier<int> waveIndex;
  final WaveCompletedCallback onWaveCompleted;
  final SpawnEnemyCallback spawnEnemy;
  final WaveTimerCallback onWaveTimerChanged;

  bool isWaveRunning = false;
  double waveDuration = GameConstants.waveDurationSeconds;

  final List<_SpawnEvent> _currentWave = [];
  int _spawnIndex = 0;
  double _spawnTimer = 0;
  int _enemiesRemaining = 0;
  double _elapsed = 0;

  void startNextWave() {
    if (isWaveRunning) {
      return;
    }
    isWaveRunning = true;
    _elapsed = 0;
    waveDuration = _durationForWave(waveIndex.value);
    onWaveTimerChanged(waveDuration);
    _currentWave
      ..clear()
      ..addAll(_buildWave(waveIndex.value));
    _spawnIndex = 0;
    _spawnTimer = 0.5;
    _enemiesRemaining = _currentWave.length;
  }

  void onEnemyDefeated() {
    if (_enemiesRemaining > 0) {
      _enemiesRemaining -= 1;
    }
    if (_enemiesRemaining <= 0 && _spawnIndex >= _currentWave.length) {
      final clearedWave = waveIndex.value;
      isWaveRunning = false;
      waveIndex.value = waveIndex.value + 1;
      onWaveCompleted(clearedWave);
      onWaveTimerChanged(GameConstants.timeBetweenWaves);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isWaveRunning) {
      return;
    }
    _elapsed += dt;
    final remaining = math.max(0.0, waveDuration - _elapsed);
    onWaveTimerChanged(remaining);

    if (_spawnIndex < _currentWave.length) {
      _spawnTimer -= dt;
      if (_spawnTimer <= 0) {
        final event = _currentWave[_spawnIndex++];
        _spawnTimer = event.delay;
        spawnEnemy(event.definition);
      }
    } else if (_enemiesRemaining <= 0) {
      // Safety net in case enemy count got stuck.
      onEnemyDefeated();
    }
  }

  List<_SpawnEvent> _buildWave(int wave) {
    final events = <_SpawnEvent>[];
    final skitter = enemyDatabase.definitions['skitterling'];
    final brute = enemyDatabase.definitions['brute'];
    final bomber = enemyDatabase.definitions['imp_bomber'];
    final wraith = enemyDatabase.definitions['wraith'];
    if (skitter == null) {
      return events;
    }

    final rng = math.Random(wave * 997);
    final intensity = 1 + (wave - 1) * 0.18;
    final speedScale = 1 + (wave - 1) * 0.03;
    final damageScale = 1 + (wave - 1) * 0.12;
    final baseCount = (10 + wave * 3).clamp(10, 140);
    final delay = math.max(0.35, 0.95 - wave * 0.03);

    final pool = <EnemyDefinition>[
      _scaledDefinition(skitter, intensity, speedScale, damageScale),
      if (wraith != null && wave >= 2)
        _scaledDefinition(wraith, intensity * 0.9, speedScale * 1.25, damageScale * 0.9),
      if (brute != null && wave >= 3)
        _scaledDefinition(brute, intensity * 1.4, speedScale * 0.85, damageScale * 1.2),
      if (bomber != null && wave % 4 == 0)
        _scaledDefinition(bomber, intensity * 1.3, speedScale * 0.9, damageScale * 1.4),
    ];

    if (pool.isEmpty) {
      return events;
    }

    for (var i = 0; i < baseCount; i++) {
      final enemy = pool[rng.nextInt(pool.length)];
      final variance = (rng.nextDouble() * 0.35) - 0.15;
      events.add(_SpawnEvent(enemy, math.max(0.2, delay + variance)));
      if (enemy.id == 'brute') {
        events.add(_SpawnEvent(enemy, delay + 0.4));
      }
    }

    final miniBossCount = (wave / 6).floor();
    if (miniBossCount > 0 && brute != null) {
      final eliteBrute = _scaledDefinition(brute, intensity * 2.1, speedScale, damageScale * 1.8,
          eliteOverride: true);
      for (var i = 0; i < miniBossCount; i++) {
        events.add(_SpawnEvent(eliteBrute, delay * 2.5));
      }
    }

    return events;
  }

  double _durationForWave(int wave) {
    return GameConstants.waveDurationSeconds + wave * 2.5;
  }

  EnemyDefinition _scaledDefinition(
    EnemyDefinition base,
    double healthScale,
    double speedScale,
    double damageScale, {
    bool? eliteOverride,
  }) {
    final drops = base.dropTable.map(
      (key, value) => MapEntry(key, value * (0.8 + healthScale * 0.35)),
    );
    return EnemyDefinition(
      id: base.id,
      displayName: base.displayName,
      speed: base.speed * speedScale,
      health: base.health * healthScale,
      damage: base.damage * damageScale,
      isElite: eliteOverride ?? base.isElite,
      dropTable: drops,
    );
  }
}

class _SpawnEvent {
  _SpawnEvent(this.definition, this.delay);

  final EnemyDefinition definition;
  final double delay;
}
