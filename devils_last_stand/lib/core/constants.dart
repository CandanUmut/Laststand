import 'package:flutter/material.dart';

/// Global configuration shared across systems.
class GameConstants {
  static const double baseTileSize = 64;
  static const int startingRings = 2;
  static const Duration waveDuration = Duration(seconds: 120);
  static const Duration dashCooldown = Duration(seconds: 5);
  static const double dashInvulnerabilityDuration = 0.4;
  static const int redeemerLimit = 1;
}

/// Shared palette to keep the UI cohesive until art lands.
class GamePalette {
  static const background = Color(0xFF080B12);
  static const coreGlow = Color(0xFFFFC857);
  static const accent = Color(0xFF4DE1FF);
  static const danger = Color(0xFFFF4F79);
  static const success = Color(0xFF6CFF6C);
}
