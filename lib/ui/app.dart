import 'package:flutter/material.dart';

import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/world_screen.dart';
import 'package:immortal_path/ui/screens/alchemy_screen.dart';
import 'package:immortal_path/ui/screens/dao_screen.dart';
import 'package:immortal_path/ui/screens/home_screen.dart';
import 'package:immortal_path/ui/screens/sect_screen.dart';

class ImmortalPathApp extends StatelessWidget {
  final GameController controller;

  const ImmortalPathApp({super.key, required this.controller});

  static const Map<String, Color> themeSeeds = {
    'theme_ember': Color(0xFFFF7043),
    'theme_ashen': Color(0xFFB71C1C),
    'theme_moonveil': Color(0xFF7E57C2),
    'theme_celestial_gold': Color(0xFFFFC107),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final themeId = controller.state.activeThemeId;
        final seed = themeSeeds[themeId] ?? Colors.deepPurple;
        return MaterialApp(
          title: 'Immortal Path',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: seed),
          ),
          home: MainShell(controller: controller),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  final GameController controller;

  const MainShell({super.key, required this.controller});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(controller: widget.controller),
          WorldScreen(controller: widget.controller),
          AlchemyScreen(controller: widget.controller),
          SectScreen(controller: widget.controller),
          DaoScreen(controller: widget.controller),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Cultivate',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'World',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Alchemy',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Sect',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Dao',
          ),
        ],
      ),
    );
  }
}
