import 'package:flutter/material.dart';

class GameOverScene extends StatelessWidget {
  const GameOverScene({super.key, required this.metaCurrencyEarned});

  final int metaCurrencyEarned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Summary')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Meta currency earned: $metaCurrencyEarned'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Return to Sanctum'),
            ),
          ],
        ),
      ),
    );
  }
}
