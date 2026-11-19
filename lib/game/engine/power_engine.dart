import 'dart:math';

import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/power.dart';
import 'package:immortal_path/game/models/world_location.dart';

class PowerEngine {
  static bool isDiscovered(GameState state, String id) =>
      state.discoveredPowers.contains(id);

  static double bonusOf(GameState state, String bonusType) {
    var total = 0.0;
    for (final id in state.discoveredPowers) {
      final power = PowerCatalog.byId(id);
      if (power == null || power.bonusType != bonusType) continue;
      if (power.sectId != null && power.sectId != state.sectId) {
        continue;
      }
      total += power.magnitude;
    }
    return total;
  }

  static String? rollDiscovery(
    GameState state,
    WorldLocation location,
    Random random,
  ) {
    final elite = location.isRaid || location.isFactionHall;
    final chance = elite ? 0.06 : 0.01;
    if (random.nextDouble() >=
        (chance * SectEngine.discoveryScale(state)).clamp(0.0, 1.0)) {
      return null;
    }
    final candidates = PowerCatalog.foundPowers()
        .where((power) => !state.discoveredPowers.contains(power.id))
        .toList();
    if (candidates.isEmpty) return null;
    return candidates[random.nextInt(candidates.length)].id;
  }

  static double qiBonus(GameState state) => bonusOf(state, 'qi');

  static double attackBonus(GameState state) => bonusOf(state, 'attack');

  static double defenseBonus(GameState state) => bonusOf(state, 'defense');

  static double hpBonus(GameState state) => bonusOf(state, 'hp');

  static double stoneBonus(GameState state) => bonusOf(state, 'stones');

  static double breakthroughBonus(GameState state) =>
      bonusOf(state, 'breakthrough');
}
