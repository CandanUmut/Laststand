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
      waveIndex.value = math.min(10, waveIndex.value + 1);
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
    final remaining = math.max(0, waveDuration - _elapsed);
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
    if (skitter == null || brute == null) {
      return events;
    }

    final baseCount = 6 + wave * 2;
    for (var i = 0; i < baseCount; i++) {
      final def = i % 5 == 0 && wave > 2 ? brute : skitter;
      events.add(_SpawnEvent(def, 0.9));
    }

    if (wave >= 4) {
      for (var i = 0; i < wave ~/ 2; i++) {
        events.add(_SpawnEvent(brute, 1.2));
      }
    }

    if (wave == 5 && bomber != null) {
      events.add(_SpawnEvent(bomber, 1.5));
    }
    if (wave == 10 && bomber != null) {
      events
        ..add(_SpawnEvent(brute, 1.2))
        ..add(_SpawnEvent(brute, 1.2))
        ..add(_SpawnEvent(bomber, 1.8));
    }

    return events;
  }
}

class _SpawnEvent {
  _SpawnEvent(this.definition, this.delay);

  final EnemyDefinition definition;
  final double delay;
}
