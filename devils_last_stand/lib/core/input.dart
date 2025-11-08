import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Unifies keyboard + touch controls. Touch devices receive a joystick while
/// desktop/web lean on WASD. Tapping (or space on keyboard) requests a dash.
class InputController extends Component
    with KeyboardHandler, TapCallbacks, HasGameRef {
  InputController({this.enableVirtualJoystick = false});

  final bool enableVirtualJoystick;

  final Vector2 movement = Vector2.zero();
  bool dashRequested = false;

  JoystickComponent? _joystick;

  JoystickComponent? get joystick => _joystick;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (enableVirtualJoystick) {
      _joystick = JoystickComponent(
        priority: 100,
        knob: CircleComponent(radius: 22, paint: Paint()..color = const Color(0xAAFFFFFF)),
        background:
            CircleComponent(radius: 46, paint: Paint()..color = const Color(0x55FFFFFF)),
        margin: const EdgeInsets.only(left: 32, bottom: 32),
      );
      gameRef.add(_joystick!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_joystick != null) {
      final delta = _joystick!.relativeDelta;
      movement.setFrom(delta);
      if (movement.length2 > 1) {
        movement.normalize();
      }
    }
  }

  /// Consumes the dash request so that systems can react once per tap.
  bool consumeDashRequest() {
    final requested = dashRequested;
    dashRequested = false;
    return requested;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      dashRequested = true;
    }
    final horizontal =
        (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) ? 1 : 0;
    final horizontalNeg =
        (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) ? 1 : 0;
    final vertical =
        (keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) ? 1 : 0;
    final verticalNeg =
        (keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) ? 1 : 0;
    movement
      ..setValues((horizontal - horizontalNeg).toDouble(), (vertical - verticalNeg).toDouble());
    if (movement.length2 > 1) {
      movement.normalize();
    }
    return true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (kIsWeb) {
      dashRequested = true;
    } else {
      dashRequested = true;
    }
  }
}
