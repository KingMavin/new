import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/mastery_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  group('MasteryEngine', () {
    test('victories train only the equipped technique', () {
      var state = GameState.initial();
      state = MasteryEngine.recordVictory(state);
      state = MasteryEngine.recordVictory(state);
      expect(state.techniqueMastery['basic'], 2);
      state = state.copyWith(techniqueId: 'sword');
      state = MasteryEngine.recordVictory(state);
      expect(state.techniqueMastery['basic'], 2);
      expect(state.techniqueMastery['sword'], 1);
    });

    test('levels and bonus cap at 15 and +15%', () {
      var state = GameState.initial();
      for (var i = 0; i < 40; i++) {
        state = MasteryEngine.recordVictory(state);
      }
      expect(MasteryEngine.levelOf(state), MasteryEngine.maxLevel);
      expect(MasteryEngine.bonus(state), closeTo(0.15, 0.0001));
    });

    test('a fresh cultivator gains no mastery bonus', () {
      expect(MasteryEngine.bonus(GameState.initial()), 0);
    });

    test('combat attack carries the mastery multiplier', () {
      var state = GameState.initial();
      final before = CombatEngine.playerAttack(state);
      for (var i = 0; i < 15; i++) {
        state = MasteryEngine.recordVictory(state);
      }
      final after = CombatEngine.playerAttack(state);
      expect(after, closeTo(before * 1.15, 0.0001));
    });
  });
}
