import 'dart:math';

/// Thin wrapper to inject deterministic seeds across systems.
class GameRng {
  GameRng([int? seed]) : _random = Random(seed);

  final Random _random;

  double nextDouble() => _random.nextDouble();

  int nextInt(int max) => _random.nextInt(max);

  T pick<T>(List<T> items) => items[_random.nextInt(items.length)];
}
