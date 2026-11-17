import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/tribulation_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

GameState peakState({int realmIndex = 0, double qi = 1e6}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    stageIndex: 3,
    qi: qi,
  );
}

void main() {
  group('begin', () {
    test('consumes qi and starts a tribulation', () {
      final state = TribulationEngine.begin(peakState(realmIndex: 0));
      expect(state.tribulationActive, isTrue);
      expect(state.qi, 0);
      expect(state.tribulationWavesTotal, 3);
      expect(state.tribulationWavesCleared, 0);
      expect(state.tribulationHp, greaterThan(0));
      expect(state.tribulationTargetRealm, 1);
    });

    test('wave count rises with realm and is capped at nine', () {
      expect(TribulationEngine.wavesForRealm(0), 3);
      expect(TribulationEngine.wavesForRealm(4), 7);
      expect(TribulationEngine.wavesForRealm(8), 9);
      expect(TribulationEngine.wavesForRealm(20), 9);
    });

    test('pill bonus converts to deflect bonus', () {
      final state = TribulationEngine.begin(
        peakState().copyWith(breakthroughBonus: 0.2),
      );
      expect(state.tribulationDeflectBonus, 0.2);
      expect(state.breakthroughBonus, 0);
    });

    test('technique tribulation health multiplier applies', () {
      final basic = TribulationEngine.begin(peakState());
      final thunder =
          TribulationEngine.begin(peakState().copyWith(techniqueId: 'thunder'));
      expect(
        thunder.tribulationMaxHp,
        closeTo(basic.tribulationMaxHp * 1.5, 1e-6),
      );
    });
  });

  group('faceWave', () {
    test('withstand always takes full wave damage', () {
      var state = TribulationEngine.begin(peakState());
      final before = state.tribulationHp;
      final outcome = TribulationEngine.faceWave(
        state,
        TribulationAction.withstand,
        rng: Random(1),
      );
      state = outcome.state;
      expect(outcome.finished, isFalse);
      expect(state.tribulationWavesCleared, 1);
      expect(
        state.tribulationHp,
        closeTo(before - TribulationEngine.wavePower(state), 1e-6),
      );
    });

    test('deflect succeeds on a low roll and takes no damage', () {
      var state = TribulationEngine.begin(peakState());
      final before = state.tribulationHp;
      final outcome = TribulationEngine.faceWave(
        state,
        TribulationAction.deflect,
        roll: 0.1,
      );
      state = outcome.state;
      expect(state.tribulationHp, before);
    });

    test('deflect failure takes 150 percent damage', () {
      var state = TribulationEngine.begin(peakState());
      final power = TribulationEngine.wavePower(state);
      final before = state.tribulationHp;
      final outcome = TribulationEngine.faceWave(
        state,
        TribulationAction.deflect,
        roll: 0.99,
      );
      state = outcome.state;
      expect(state.tribulationHp, closeTo(before - power * 1.5, 1e-6));
    });

    test('channel costs 10 percent of qi and reduces damage', () {
      var state = TribulationEngine.begin(peakState(qi: 1000));
      final power = TribulationEngine.wavePower(state);
      final beforeHp = state.tribulationHp;
      final outcome = TribulationEngine.faceWave(
        state,
        TribulationAction.channel,
      );
      state = outcome.state;
      expect(state.qi, closeTo(900, 1e-6));
      expect(state.tribulationHp, closeTo(beforeHp - power * 0.4, 1e-6));
    });

    test('surviving all waves advances the realm', () {
      var state = TribulationEngine.begin(peakState(realmIndex: 0));
      final waves = state.tribulationWavesTotal;
      TribulationOutcome outcome = TribulationEngine.faceWave(
        state,
        TribulationAction.withstand,
      );
      for (var i = 1; i < waves; i++) {
        outcome = TribulationEngine.faceWave(
          outcome.state,
          TribulationAction.withstand,
        );
      }
      expect(outcome.finished, isTrue);
      expect(outcome.success, isTrue);
      expect(outcome.state.realmIndex, 1);
      expect(outcome.state.stageIndex, 0);
      expect(outcome.state.tribulationActive, isFalse);
      expect(outcome.state.tribulationsSurvived, 1);
    });

    test('repeated withstand at low realm survives the tribulation', () {
      var state = TribulationEngine.begin(peakState(realmIndex: 0));
      TribulationOutcome outcome;
      do {
        outcome = TribulationEngine.faceWave(
          state,
          TribulationAction.withstand,
        );
        state = outcome.state;
      } while (!outcome.finished);
      expect(outcome.success, isTrue);
    });

    test('final realm tribulation grants ascension', () {
      var state = TribulationEngine.begin(peakState(realmIndex: 8));
      TribulationOutcome outcome;
      do {
        outcome = TribulationEngine.faceWave(
          state,
          TribulationAction.deflect,
          roll: 0.1,
        );
        state = outcome.state;
      } while (!outcome.finished);
      expect(outcome.success, isTrue);
      expect(outcome.state.ascended, isTrue);
    });

    test('inactive tribulation returns unchanged state', () {
      final state = peakState();
      final outcome = TribulationEngine.faceWave(
        state,
        TribulationAction.withstand,
      );
      expect(outcome.finished, isFalse);
      expect(outcome.state.tribulationActive, isFalse);
    });
  });
}
