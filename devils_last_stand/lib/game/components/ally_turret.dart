import 'package:flame/components.dart';

import '../app_game.dart';
import 'enemy.dart';
import 'projectile.dart';

class AllyTurret extends PositionComponent with HasGameRef<AppGame> {
  AllyTurret({required this.baseDamage})
      : super(size: Vector2.all(56), anchor: Anchor.center);

  factory AllyTurret.fromEnemy(EnemyComponent enemy) {
    return AllyTurret(baseDamage: enemy.definition.damage * 1.5);
  }

  final double baseDamage;
  double _cooldown = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _cooldown -= dt;
    if (_cooldown <= 0) {
      if (_performAttack()) {
        _cooldown = 0.6;
      } else {
        _cooldown = 0.2;
      }
    }
  }

  bool _performAttack() {
    EnemyComponent? closest;
    double closestDist = double.infinity;
    for (final enemy in gameRef.world.children.whereType<EnemyComponent>()) {
      final dist = enemy.position.distanceToSquared(position);
      if (dist < closestDist) {
        closestDist = dist;
        closest = enemy;
      }
    }
    if (closest == null) {
      return false;
    }
    final direction = (closest.position - position).normalized();
    final projectile = Projectile(
      startPosition: position.clone(),
      direction: direction,
      speed: 480,
      damage: baseDamage,
      owner: ProjectileOwner.ally,
    );
    gameRef.world.add(projectile);
    return true;
  }
}
