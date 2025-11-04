import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class PickupComponent extends PositionComponent with CollisionCallbacks, HasGameRef {
  PickupComponent({
    required this.type,
    required this.amount,
    super.position,
  }) : super(size: Vector2.all(24)) {
    anchor = Anchor.center;
  }

  final String type;
  final int amount;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(1, parentSize: size));
  }
}
