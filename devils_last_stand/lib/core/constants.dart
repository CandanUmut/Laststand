import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Global configuration shared across systems.
class GameConstants {
  static const double gridSize = 64;
  static const int startingRings = 1;
  static const double timeBetweenWaves = 18;
  static const double waveDurationSeconds = 32;
  static const double dashCooldownSeconds = 1.0;
  static const double dashInvulnerabilityDuration = 0.25;
  static const double dashBurstSpeed = 480;
  static const double playerBaseMoveSpeed = 220;
  static const double playerBaseMagnet = 120;
  static const double playerBaseProjectileSpeed = 520;
  static const int baseCoreMaxHp = 200;
  static const int redeemerLimit = 1;

  static final Vector2 worldSize = Vector2(1600, 1200);
}

/// Shared palette to keep the UI cohesive until art lands.
class GamePalette {
  static const background = Color(0xFF080B12);
  static const coreGlow = Color(0xFFFFC857);
  static const accent = Color(0xFF4DE1FF);
  static const danger = Color(0xFFFF4F79);
  static const success = Color(0xFF6CFF6C);
  static const panel = Color(0x33101728);
}
