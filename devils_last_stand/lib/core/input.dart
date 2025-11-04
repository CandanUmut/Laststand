import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

/// Helper that exposes a unified interface for keyboard + touch movement.
class MovementInput extends Component with KeyboardHandler, HasGameRef {
  final Vector2 direction = Vector2.zero();
  JoystickComponent? joystick;

  @override
  void update(double dt) {
    super.update(dt);
    if (joystick != null) {
      direction.setFrom(joystick!.relativeDelta);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    direction
      ..setZero()
      ..x += keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0
      ..x -= keysPressed.contains(LogicalKeyboardKey.keyA) ? 1 : 0
      ..y += keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0
      ..y -= keysPressed.contains(LogicalKeyboardKey.keyW) ? 1 : 0;
    if (direction.length2 > 1) {
      direction.normalize();
    }
    return true;
  }
}
