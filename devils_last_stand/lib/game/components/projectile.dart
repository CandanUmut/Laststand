import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class ProjectileComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef {
  ProjectileComponent({
    required this.speed,
    required this.damage,
    required this.direction,
    super.position,
  }) : super(size: Vector2.all(12)) {
    anchor = Anchor.center;
  }

  final double speed;
  final double damage;
  final Vector2 direction;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(0.9, parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;

    if (!gameRef.camera.visibleWorldRect.containsPoint(position)) {
      removeFromParent();
    }
  }
}
