import 'package:flutter/material.dart';

import 'main_menu_scene.dart';

class SplashScene extends StatefulWidget {
  const SplashScene({super.key});

  @override
  State<SplashScene> createState() => _SplashSceneState();
}

class _SplashSceneState extends State<SplashScene> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainMenuScene()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Devil's Last Stand",
              style: TextStyle(fontSize: 32, letterSpacing: 2),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
