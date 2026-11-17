import 'package:flutter/material.dart';

import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/home_screen.dart';

class ImmortalPathApp extends StatelessWidget {
  final GameController controller;

  const ImmortalPathApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Immortal Path',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(controller: controller),
    );
  }
}
