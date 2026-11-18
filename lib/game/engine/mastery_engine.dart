import 'dart:math';

import 'package:immortal_path/game/models/game_state.dart';

class MasteryEngine {
  static const int maxLevel = 15;

  static GameState recordVictory(GameState state) {
    final current = state.techniqueMastery[state.techniqueId] ?? 0;
    return state.copyWith(
      techniqueMastery: {
        ...state.techniqueMastery,
        state.techniqueId: current + 1,
      },
    );
  }

  static int levelOf(GameState state) =>
      min(state.techniqueMastery[state.techniqueId] ?? 0, maxLevel);

  static double bonus(GameState state) => 0.01 * levelOf(state);
}
