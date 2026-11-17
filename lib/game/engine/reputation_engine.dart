import 'package:immortal_path/game/models/game_state.dart';

class ReputationEngine {
  static const List<int> tierThresholds = [0, 100, 300, 700, 1500];

  static const List<String> tierNames = [
    'Stranger',
    'Acknowledged',
    'Sworn Ally',
    'Champion',
    'Beloved of the Heavens',
  ];

  static const Map<String, String> factionNames = {
    'human': 'Verdant Empire',
    'demon': 'Ash Wastes Clans',
    'demi_human': 'Border Forest Tribes',
  };

  static const Map<String, String> factionMottos = {
    'human':
        'Ten thousand sects, one empire \u2014 the stairs to heaven are open to any who climb.',
    'demon':
        'The old blood remembers what the heavens tried to bury in ash.',
    'demi_human':
        'The forest walks with those the empire turned away.',
  };

  static int reputationOf(GameState state, String raceId) =>
      state.reputation[raceId] ?? 0;

  static int ownReputation(GameState state) =>
      state.raceId == null ? 0 : reputationOf(state, state.raceId!);

  static int tierOf(int reputation) {
    var tier = 0;
    for (var i = 0; i < tierThresholds.length; i++) {
      if (reputation >= tierThresholds[i]) tier = i;
    }
    return tier;
  }

  static String tierName(int reputation) => tierNames[tierOf(reputation)];

  static int nextThreshold(int reputation) {
    for (final threshold in tierThresholds) {
      if (reputation < threshold) return threshold;
    }
    return -1;
  }

  static double standingBonus(GameState state) =>
      tierOf(ownReputation(state)) * 0.03;

  static int huntGain(GameState state) => 5 + 3 * state.realmIndex;

  static int tournamentWinGain(GameState state) => 20 + 10 * state.realmIndex;

  static const int tournamentLossGain = 3;

  static int warWinGain(GameState state) => 60 + 20 * state.realmIndex;

  static const int warLossGain = 10;

  static Map<String, int> gain(GameState state, int amount) {
    final raceId = state.raceId;
    if (raceId == null || amount <= 0) return state.reputation;
    return {
      ...state.reputation,
      raceId: reputationOf(state, raceId) + amount,
    };
  }
}
