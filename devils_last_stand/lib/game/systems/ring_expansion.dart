import 'package:flame/components.dart';

import '../../core/constants.dart';

class RingExpansionSystem extends Component {
  RingExpansionSystem({this.startingRings = GameConstants.startingRings})
      : unlockedRings = startingRings;

  int unlockedRings;
  final int startingRings;

  bool isTileUnlocked(Vector2 tile) {
    final ring = tile.length / GameConstants.baseTileSize;
    return ring <= unlockedRings + 0.01;
  }

  void unlockNextRing() {
    unlockedRings += 1;
  }
}
