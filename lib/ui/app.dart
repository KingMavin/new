import 'package:flutter/material.dart';

import 'package:immortal_path/audio/music_director.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/models/sect_npc.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';
import 'package:immortal_path/ui/theme/voice_line.dart';
import 'package:immortal_path/ui/screens/world_screen.dart';
import 'package:immortal_path/ui/screens/alchemy_screen.dart';
import 'package:immortal_path/ui/screens/dao_screen.dart';
import 'package:immortal_path/ui/screens/home_screen.dart';
import 'package:immortal_path/ui/screens/event_dialog.dart';
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
  String? _shownEventId;

  void _updateMusic() {
    widget.controller.setMusicTrack(
      MusicDirector.trackFor(
        encounterActive: widget.controller.encounter != null,
        kind: widget.controller.encounterKind,
        tabIndex: _index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _maybeShowEvent(context);
    _maybeShowPromotion(context);
    _updateMusic();
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

  void _maybeShowPromotion(BuildContext context) {
    final controller = widget.controller;
    final rank = controller.consumePendingPromotion();
    if (rank == null) return;
    final sectId = controller.state.sectId;
    if (sectId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          final master = SectHallCatalog.byId(sectId).master;
          return AlertDialog(
            title: const Text('Promotion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: BackdropImage(
                      BackdropCatalog.forScreen('sect'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  SectEngine.rankNames[rank],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '"${master.lineFor(seed: rank)}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\u2014 ${master.name}, ${master.title}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                VoiceLine.caseOf(
                  'promotion',
                  seed: rank * 7 + controller.state.journal.length,
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    });
  }

  void _maybeShowEvent(BuildContext context) {
    final eventId = widget.controller.state.pendingEventId;
    if (eventId == null || _shownEventId == eventId) return;
    _shownEventId = eventId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => EventDialog(
          controller: widget.controller,
          eventId: eventId,
        ),
      );
    });
  }
}
