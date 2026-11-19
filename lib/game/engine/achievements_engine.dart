import 'package:immortal_path/game/models/game_state.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final bool Function(GameState state) check;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.check,
  });
}

class AchievementsEngine {
  static const List<Achievement> catalog = [
    Achievement(
      id: 'first_blood',
      title: 'First Blood',
      description: 'Win your first hunt.',
      check: (s) => s.battlesWon >= 1,
    ),
    Achievement(
      id: 'hunter',
      title: 'Hunter of the Wilds',
      description: 'Win 50 hunts.',
      check: (s) => s.battlesWon >= 50,
    ),
    Achievement(
      id: 'slayer',
      title: 'Slayer of Hundreds',
      description: 'Win 200 hunts.',
      check: (s) => s.battlesWon >= 200,
    ),
    Achievement(
      id: 'stage_climber',
      title: 'Stage Climber',
      description: 'Succeed at 10 breakthroughs.',
      check: (s) => s.breakthroughsSucceeded >= 10,
    ),
    Achievement(
      id: 'realm_elite',
      title: 'Realm Elite',
      description: 'Reach the Soul Formation realm or beyond.',
      check: (s) => s.realmIndex >= 5,
    ),
    Achievement(
      id: 'near_immortal',
      title: 'Near Immortal',
      description: 'Reach the Void Refinement realm or beyond.',
      check: (s) => s.realmIndex >= 7,
    ),
    Achievement(
      id: 'storm_rider',
      title: 'Storm Rider',
      description: 'Survive 3 heavenly tribulations.',
      check: (s) => s.tribulationsSurvived >= 3,
    ),
    Achievement(
      id: 'wheel_of_nine',
      title: 'Wheel of Nine',
      description: 'Survive 9 heavenly tribulations.',
      check: (s) => s.tribulationsSurvived >= 9,
    ),
    Achievement(
      id: 'sands_champion',
      title: 'Sands Champion',
      description: 'Win 10 sect tournaments.',
      check: (s) => s.tournamentsWon >= 10,
    ),
    Achievement(
      id: 'warlord',
      title: 'Warlord of the Front',
      description: 'Win 5 sect wars.',
      check: (s) => s.warsWon >= 5,
    ),
    Achievement(
      id: 'reincarnator',
      title: 'The Wheel Turns',
      description: 'Reincarnate once.',
      check: (s) => s.reincarnations >= 1,
    ),
    Achievement(
      id: 'eternal_wheel',
      title: 'Eternal Wheel',
      description: 'Reincarnate three times.',
      check: (s) => s.reincarnations >= 3,
    ),
    Achievement(
      id: 'collector',
      title: 'Collector of Relics',
      description: 'Sell 10 pieces of equipment.',
      check: (s) => s.equipmentSold >= 10,
    ),
    Achievement(
      id: 'beast_lore',
      title: 'Beast Lore',
      description: 'Record 10 beasts in the bestiary.',
      check: (s) => s.bestiary.length >= 10,
    ),
    Achievement(
      id: 'loremaster',
      title: 'Loremaster',
      description: 'Record 25 beasts in the bestiary.',
      check: (s) => s.bestiary.length >= 25,
    ),
    Achievement(
      id: 'technique_seeker',
      title: 'Technique Seeker',
      description: 'Discover 4 cultivation techniques.',
      check: (s) => s.discoveredTechniques.length >= 4,
    ),
    Achievement(
      id: 'power_hunter',
      title: 'Power Hunter',
      description: 'Discover 3 special powers.',
      check: (s) => s.discoveredPowers.length >= 3,
    ),
    Achievement(
      id: 'sect_sworn',
      title: 'Sect Sworn',
      description: 'Join a sect.',
      check: (s) => s.sectId != null,
    ),
    Achievement(
      id: 'inner_circle',
      title: 'Inner Circle',
      description: 'Reach 100 sect contribution.',
      check: (s) => s.contribution >= 100,
    ),
    Achievement(
      id: 'elder',
      title: 'Sect Elder',
      description: 'Reach 800 sect contribution.',
      check: (s) => s.contribution >= 800,
    ),
    Achievement(
      id: 'wanderer',
      title: 'Wanderer',
      description: 'Discover 8 locations.',
      check: (s) => s.discoveredLocations.length >= 8,
    ),
    Achievement(
      id: 'hidden_paths',
      title: 'Hidden Paths',
      description: 'Discover 15 locations.',
      check: (s) => s.discoveredLocations.length >= 15,
    ),
    Achievement(
      id: 'story_complete',
      title: 'A Path Fulfilled',
      description: 'Complete your race\u2019s story arc.',
      check: (s) => s.achievedEndings.isNotEmpty,
    ),
    Achievement(
      id: 'ending_seeker',
      title: 'Seeker of Ends',
      description: 'Reach 3 different endings.',
      check: (s) => s.achievedEndings.length >= 3,
    ),
    Achievement(
      id: 'six_paths',
      title: 'Six Paths Walked',
      description: 'Reach all six endings.',
      check: (s) => s.achievedEndings.length >= 6,
    ),
    Achievement(
      id: 'patron_legend',
      title: 'Patron of the Temple',
      description: 'Support the temple with any patron blessing.',
      check: (s) => s.supportTier,
    ),
  ];

  static Achievement? byId(String id) {
    for (final a in catalog) {
      if (a.id == id) return a;
    }
    return null;
  }

  static GameState evaluate(GameState state) {
    final earned = state.achievements.toSet();
    for (final a in catalog) {
      if (!earned.contains(a.id) && a.check(state)) earned.add(a.id);
    }
    final list = earned.toList();
    return list.length == state.achievements.length
        ? state
        : state.copyWith(achievements: list);
  }
}
