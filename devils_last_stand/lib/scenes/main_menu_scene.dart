import 'package:flutter/material.dart';

import 'level_select_scene.dart';
import 'options_scene.dart';

class MainMenuScene extends StatelessWidget {
  const MainMenuScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Devil's Last Stand",
                style: TextStyle(fontSize: 36, letterSpacing: 3),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LevelSelectScene()),
                  );
                },
                child: const Text('Start Run'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OptionsScene()),
                  );
                },
                child: const Text('Options'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
