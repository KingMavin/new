import 'package:flutter/material.dart';

class BackdropCatalog {
  static const Map<String, String> _screens = {
    'alchemy': 'assets/images/screen_alchemy.png',
    'dao': 'assets/images/screen_dao.png',
    'encounter': 'assets/images/screen_encounter.png',
    'home': 'assets/images/screen_home.png',
    'sect': 'assets/images/screen_sect.png',
    'settings': 'assets/images/screen_settings.png',
    'store': 'assets/images/screen_store.png',
    'tribulation': 'assets/images/screen_tribulation.png',
    'world': 'assets/images/screen_world.png',
  };

  static const Map<String, String> _events = {
    'ancient_tomb': 'assets/images/event_ancient_tomb.png',
    'bandit_ambush': 'assets/images/event_bandit_ambush.png',
    'beggar_sage': 'assets/images/event_beggar_sage.png',
    'dragon_bones': 'assets/images/event_dragon_bones.png',
    'faceless_messenger': 'assets/images/event_faceless_messenger.png',
    'fallen_cultivator': 'assets/images/event_fallen_cultivator.png',
    'lost_child': 'assets/images/event_lost_child.png',
    'old_monk': 'assets/images/event_old_monk.png',
    'secret_auction': 'assets/images/event_secret_auction.png',
    'spirit_spring': 'assets/images/event_spirit_spring.png',
    'the_beggar': 'assets/images/event_the_beggar.png',
    'thunder_cave': 'assets/images/event_thunder_cave.png',
    'wandering_merchant': 'assets/images/event_wandering_merchant.png',
    'wild_garden': 'assets/images/event_wild_garden.png',
  };

  static const Map<String, String> _locations = {
    'ash_sanctum': 'assets/images/loc_ash_sanctum.png',
    'bamboo_forest': 'assets/images/loc_bamboo_forest.png',
    'beast_wasteland': 'assets/images/loc_beast_wasteland.png',
    'bone_pits': 'assets/images/loc_bone_pits.png',
    'ember_valley': 'assets/images/loc_ember_valley.png',
    'fallen_yan': 'assets/images/loc_fallen_yan.png',
    'fallen_zhao': 'assets/images/loc_fallen_zhao.png',
    'heavenly_gate': 'assets/images/loc_heavenly_gate.png',
    'hells_gorge': 'assets/images/loc_hells_gorge.png',
    'lotus_lake': 'assets/images/loc_lotus_lake.png',
    'misty_mountains': 'assets/images/loc_misty_mountains.png',
    'moonveil_glade': 'assets/images/loc_moonveil_glade.png',
    'serpent_peak': 'assets/images/loc_serpent_peak.png',
    'sword_tomb': 'assets/images/loc_sword_tomb.png',
    'sword_vault': 'assets/images/loc_sword_vault.png',
    'verdant_palace': 'assets/images/loc_verdant_palace.png',
    'void_rift': 'assets/images/loc_void_rift.png',
  };

  static const Map<String, String> _stories = {
    'demi': 'assets/images/story_demi.png',
    'demon': 'assets/images/story_demon.png',
    'human': 'assets/images/story_human.png',
  };

  static const String fallbackAsset = 'assets/images/screen_world.png';

  static String forScreen(String key) =>
      _screens[key] ?? 'assets/images/screen_$key.png';

  static String forEvent(String eventId) => _events[eventId] ?? fallbackAsset;

  static String forLocation(String locationId) =>
      _locations[locationId] ?? fallbackAsset;

  static String forStory(String raceId) => _stories[raceId] ?? fallbackAsset;

  static bool hasEvent(String eventId) => _events.containsKey(eventId);
}

class BackdropImage extends StatelessWidget {
  final String asset;
  final BoxFit fit;
  final List<Color> scrim;

  const BackdropImage(
    this.asset, {
    super.key,
    this.fit = BoxFit.cover,
    this.scrim = const [Color(0x33000000), Color(0x99000000)],
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      frameBuilder: (context, child, frame, wasSync) {
        if (frame == null) return child;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: scrim,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class BackdropScaffold extends StatelessWidget {
  final String asset;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  const BackdropScaffold({
    super.key,
    required this.asset,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFF0C0E14),
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          BackdropImage(asset),
          body,
        ],
      ),
    );
  }
}
