import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants.dart';
import '../../data/enemy_defs.dart';
import '../components/enemy.dart';
import 'pathfinding.dart';
import 'ring_expansion.dart';

typedef WaveCompleteCallback = void Function();
typedef CoreDamageCallback = void Function(double normalizedHealth);

class WaveManager extends Component {
  WaveManager({
    required this.enemyDatabase,
    required this.waveIndex,
    required this.ringExpansion,
    required this.onWaveCompleted,
    required this.onCoreDamaged,
  });

  final EnemyDatabase enemyDatabase;
  final ValueNotifier<int> waveIndex;
  final RingExpansionSystem ringExpansion;
  final WaveCompleteCallback onWaveCompleted;
  final CoreDamageCallback onCoreDamaged;

  final PathfindingSystem pathfinding =
      PathfindingSystem(gridSize: Vector2.all(GameConstants.baseTileSize * 16));

  double timer = GameConstants.waveDuration.inSeconds.toDouble();
  double coreHealth = 1.0;

  @override
  void update(double dt) {
    super.update(dt);
    timer -= dt;
    if (timer <= 0) {
      onWaveCompleted();
      timer = GameConstants.waveDuration.inSeconds.toDouble();
      waveIndex.value += 1;
    }
  }

  void spawnWave() {
    final budget = waveIndex.value * 5;
    final enemies = enemyDatabase.definitions.values.toList();
    for (var i = 0; i < budget; i++) {
      final enemy = enemies[i % enemies.length];
      final navigator = pathfinding.navigatorFor(Vector2.zero(), Vector2.zero());
      final component = EnemyComponent(
        definition: enemy,
        navigator: navigator,
      );
      gameRef.add(component);
    }
  }

  void applyCoreDamage(double amount) {
    coreHealth = (coreHealth - amount).clamp(0, 1);
    onCoreDamaged(coreHealth);
  }
}
