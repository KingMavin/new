import 'dart:math';

import 'package:immortal_path/game/engine/store_engine.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';

import 'package:immortal_path/game/models/forge.dart';

class ForgeOutcome {
  final bool success;
  final String message;
  final GameState state;

  const ForgeOutcome({
    required this.success,
    required this.message,
    required this.state,
  });
}

class ForgeEngine {
  static String? blocker(GameState state, ForgeRecipe recipe) {
    if (state.spiritStones < recipe.stoneCostFor(state.realmIndex)) {
      return 'Not enough spirit stones.';
    }
    if (state.spiritHerbs < recipe.herbCost) {
      return 'Not enough spirit herbs.';
    }
    if (state.beastCores < recipe.coreCost) {
      return 'Not enough beast cores.';
    }
    return null;
  }

  static ForgeOutcome attempt(
    GameState state,
    ForgeRecipe recipe, {
    Random? rng,
    double? roll,
  }) {
    final blockerMessage = blocker(state, recipe);
    if (blockerMessage != null) {
      return ForgeOutcome(success: false, message: blockerMessage, state: state);
    }
    final r = roll ?? rng?.nextDouble() ?? Random().nextDouble();
    final success = r < recipe.successChance;
    final cost = recipe.stoneCostFor(state.realmIndex).toDouble();
    final refund = success ? 0.0 : (cost * 0.4).roundToDouble();
    var updated = state.copyWith(
      spiritStones: state.spiritStones - cost + refund,
      spiritHerbs: state.spiritHerbs - recipe.herbCost,
      beastCores: state.beastCores - recipe.coreCost,
    );
    if (!success) {
      return ForgeOutcome(
        success: false,
        message:
            'The forge flames gutter \u2014 the materials shatter. Stones '
            'remaining in the ashes are salvaged.',
        state: updated,
      );
    }
    final item = Equipment.create(
      recipe.slot,
      recipe.grade,
      recipe.powerFor(state.realmIndex),
    );
    final before = updated;
    updated = StoreEngine.equipIfBetter(updated, item);
    final equipped = !identical(before, updated);
    return ForgeOutcome(
      success: true,
      message: equipped
          ? 'The forge bellows roar \u2014 ${item.name} is born in starlight '
              'and placed in your hands.'
          : '${item.name} cooled well, but it gathers dust \u2014 what you '
              'carry is stronger.',
      state: updated,
    );
  }
}
