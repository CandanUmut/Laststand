import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../app_game.dart';
import 'enemy.dart';

enum ProjectileOwner { player, tower, ally }

class Projectile extends CircleComponent
    with CollisionCallbacks, HasGameRef<AppGame> {
  Projectile({
    required Vector2 startPosition,
    required Vector2 direction,
    required this.speed,
    required this.damage,
    this.pierce = 0,
    this.lifetime = 2,
    this.owner = ProjectileOwner.player,
  })  : velocity = direction.normalized() * speed,
        super(radius: 6, anchor: Anchor.center) {
    position = startPosition;
  }

  Projectile.player({
    required Vector2 startPosition,
    required Vector2 direction,
    double speed = 520,
    double damage = 16,
    int pierce = 0,
  }) : this(
          startPosition: startPosition,
          direction: direction,
          speed: speed,
          damage: damage,
          pierce: pierce,
          owner: ProjectileOwner.player,
        );

  Projectile.tower({
    required Vector2 startPosition,
    required Vector2 direction,
    double speed = 420,
    double damage = 12,
    int pierce = 0,
  }) : this(
          startPosition: startPosition,
          direction: direction,
          speed: speed,
          damage: damage,
          pierce: pierce,
          owner: ProjectileOwner.tower,
        );

  final double speed;
  final double damage;
  final ProjectileOwner owner;
  final int pierce;
  final double lifetime;
  final Vector2 velocity;

  double _age = 0;
  int _remainingPierce = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _remainingPierce = pierce;
    add(CircleHitbox.relative(1, parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    _age += dt;
    if (_age >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is EnemyComponent && owner != ProjectileOwner.ally) {
      other.applyDamage(damage);
      if (_remainingPierce > 0) {
        _remainingPierce -= 1;
      } else {
        removeFromParent();
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
