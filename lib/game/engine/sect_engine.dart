import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/sect.dart';

class SectEngine {
  static const List<int> rankThresholds = [0, 100, 300, 800];
  static const List<String> rankNames = [
    'Outer Disciple',
    'Inner Disciple',
    'Core Disciple',
    'Elder',
  ];
  static const int joinRealmRequirement = 1;

  static bool canJoin(GameState state) =>
      state.sectId == null && state.realmIndex >= joinRealmRequirement;

  static String? joinBlocker(GameState state, String sectId) {
    if (state.sectId != null) {
      return 'You are already sworn to ${Sect.byId(state.sectId!).name}.';
    }
    final sect = Sect.byId(sectId);
    if (state.raceId != null && sect.factionId != state.raceId) {
      return 'They take only their own people.';
    }
    if (state.realmIndex < joinRealmRequirement) {
      return 'Requires realm ${joinRealmRequirement + 1} or beyond.';
    }
    if (state.sectBetrayed.contains(sectId)) {
      return 'Their gates will not open for you again this life.';
    }
    return null;
  }

  static bool canJoinSpecific(GameState state, String sectId) =>
      joinBlocker(state, sectId) == null;

  static bool hasPerk(String? sectId, String perkSectId) => sectId == perkSectId;

  static double tournamentPrizeBonus(GameState state) =>
      hasPerk(state.sectId, 'sword_sect') ? 0.5 : 0.0;

  static int tribulationWaveRelief(GameState state) =>
      hasPerk(state.sectId, 'formation_hall') ? 1 : 0;

  static double brewDoubleChance(GameState state) =>
      hasPerk(state.sectId, 'imperial_herbal_court') ? 0.30 : 0.0;

  static double forgeLuckBonus(GameState state) =>
      hasPerk(state.sectId, 'blood_furnace_clan') ? 0.10 : 0.0;

  static double pillValueBonus(GameState state) =>
      hasPerk(state.sectId, 'pill_valley') ? 0.25 : 0.0;

  static double discoveryScale(GameState state) =>
      hasPerk(state.sectId, 'nightveil_bureau') ? 1.5 : 1.0;

  static double companionScale(GameState state) =>
      hasPerk(state.sectId, 'beast_court') ? 2.0 : 1.0;

  static double lootStonesBonus(GameState state) =>
      hasPerk(state.sectId, 'verdant_grove') ? 0.20 : 0.0;

  static double cooldownScale(GameState state) =>
      hasPerk(state.sectId, 'wind_speaker_circle') ? 0.75 : 1.0;

  static GameState join(GameState state, String sectId) {
    if (!canJoin(state)) return state;
    return state.copyWith(sectId: sectId, contribution: 0);
  }

  static Sect? sectOf(GameState state) =>
      state.sectId == null ? null : Sect.byId(state.sectId!);

  static int rankOf(int contribution) {
    var rank = 0;
    for (var i = 0; i < rankThresholds.length; i++) {
      if (contribution >= rankThresholds[i]) rank = i;
    }
    return rank;
  }

  static String rankName(int contribution) => rankNames[rankOf(contribution)];

  static int nextRankThreshold(int contribution) {
    for (final threshold in rankThresholds) {
      if (contribution < threshold) return threshold;
    }
    return -1;
  }

  static const Set<String> attackAxes = {
    'sword_sect',
    'blood_furnace_clan',
    'beast_court',
  };

  static const Set<String> qiAxes = {
    'pill_valley',
    'imperial_herbal_court',
    'verdant_grove',
  };

  static const Set<String> breakthroughAxes = {
    'formation_hall',
    'nightveil_bureau',
    'wind_speaker_circle',
  };

  static double attackMultiplier(GameState state) {
    final sect = sectOf(state);
    if (sect == null || !attackAxes.contains(sect.id)) return 1.0;
    return 1.0 + 0.12 * (1 + rankOf(state.contribution));
  }

  static double qiMultiplier(GameState state) {
    final sect = sectOf(state);
    if (sect == null || !qiAxes.contains(sect.id)) return 1.0;
    return 1.0 + 0.10 * (1 + rankOf(state.contribution));
  }

  static double breakthroughBonus(GameState state) {
    final sect = sectOf(state);
    if (sect == null || !breakthroughAxes.contains(sect.id)) return 0.0;
    return 0.03 * (1 + rankOf(state.contribution));
  }
}
