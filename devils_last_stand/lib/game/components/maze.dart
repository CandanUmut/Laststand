import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../systems/level_layout.dart';

class MazeComponent extends PositionComponent {
  MazeComponent({
    required this.layout,
  }) : super(
          size: Vector2(
            layout.columns * layout.tileSize,
            layout.rows * layout.tileSize,
          ),
          anchor: Anchor.center,
          priority: -50,
        );

  final LevelLayout layout;

  late final Paint _pathPaint = Paint()
    ..color = const Color(0xFF1B2A49).withOpacity(0.85);
  late final Paint _wallPaint = Paint()
    ..color = Colors.black.withOpacity(0.55);
  late final Paint _buildPaint = Paint()
    ..color = GamePalette.accent.withOpacity(0.08);
  late final Paint _spawnPaint = Paint()
    ..color = GamePalette.accent.withOpacity(0.45);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tileSize = layout.tileSize;
    final offsetX = size.x / 2;
    final offsetY = size.y / 2;

    final wallRect = Rect.fromLTWH(-offsetX, -offsetY, size.x, size.y);
    canvas.drawRect(wallRect, _wallPaint);

    for (var y = 0; y < layout.rows; y++) {
      for (var x = 0; x < layout.columns; x++) {
        if (!layout.walkableGrid[y][x]) {
          continue;
        }
        final left = x * tileSize - offsetX;
        final top = y * tileSize - offsetY;
        final rect = Rect.fromLTWH(left, top, tileSize, tileSize);
        canvas.drawRect(rect, _pathPaint);
      }
    }

    for (final cell in layout.buildableCells) {
      final worldX = (cell.x + layout.columns ~/ 2) * tileSize - offsetX;
      final worldY = (cell.y + layout.rows ~/ 2) * tileSize - offsetY;
      final rect = Rect.fromLTWH(worldX + tileSize * 0.2, worldY + tileSize * 0.2,
          tileSize * 0.6, tileSize * 0.6);
      canvas.drawRect(rect, _buildPaint);
    }

    for (final spawn in layout.spawnCells) {
      final worldX = (spawn.x + layout.columns ~/ 2) * tileSize - offsetX + tileSize / 2;
      final worldY = (spawn.y + layout.rows ~/ 2) * tileSize - offsetY + tileSize / 2;
      canvas.drawCircle(Offset(worldX, worldY), tileSize * 0.3, _spawnPaint);
    }
  }
}
