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

  static double attackMultiplier(GameState state) {
    final sect = sectOf(state);
    if (sect == null || sect.id != 'sword_sect') return 1.0;
    return 1.0 + 0.12 * (1 + rankOf(state.contribution));
  }

  static double qiMultiplier(GameState state) {
    final sect = sectOf(state);
    if (sect == null || sect.id != 'pill_valley') return 1.0;
    return 1.0 + 0.10 * (1 + rankOf(state.contribution));
  }

  static double breakthroughBonus(GameState state) {
    final sect = sectOf(state);
    if (sect == null || sect.id != 'formation_hall') return 0.0;
    return 0.03 * (1 + rankOf(state.contribution));
  }
}
