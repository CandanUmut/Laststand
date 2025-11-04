import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'scenes/splash_scene.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DevilsLastStandApp());
}

class DevilsLastStandApp extends StatelessWidget {
  const DevilsLastStandApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      textTheme: GoogleFonts.orbitronTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF8243),
        secondary: Color(0xFF4DE1FF),
        background: Color(0xFF080B12),
      ),
    );

    return MaterialApp(
      title: "Devil's Last Stand",
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: const SplashScene(),
    );
  }
}
