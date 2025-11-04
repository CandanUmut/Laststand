import 'package:flame/components.dart';

import '../../data/enemy_defs.dart';

class AllyTurretComponent extends PositionComponent with HasGameRef {
  AllyTurretComponent({
    required this.sourceEnemy,
    super.position,
  }) : super(size: Vector2.all(48)) {
    anchor = Anchor.center;
  }

  final EnemyDefinition sourceEnemy;
  double fireTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    fireTimer -= dt;
    if (fireTimer <= 0) {
      _fire();
    }
  }

  void _fire() {
    fireTimer = 1.2;
    // TODO: mimic the converted devil's attack pattern against foes.
  }
}
