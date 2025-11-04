import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../../data/enemy_defs.dart';
import '../systems/pathfinding.dart';

class EnemyComponent extends PositionComponent with CollisionCallbacks, HasGameRef {
  EnemyComponent({
    required this.definition,
    required this.navigator,
    super.position,
  }) : super(size: Vector2.all(32));

  final EnemyDefinition definition;
  final PathNavigator navigator;

  double health = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
    add(CircleHitbox.relative(0.8, parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final nextDirection = navigator.stepTowards(position);
    position += nextDirection * definition.speed * dt;
  }

  void applyDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      removeFromParent();
    }
  }
}
