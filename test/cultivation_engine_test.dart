import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/game_state.dart';

GameState stateAt({
  int realmIndex = 0,
  int stageIndex = 0,
  double qi = 0,
  DateTime? lastSaved,
}) {
  final base = GameState.initial();
  return base.copyWith(
    realmIndex: realmIndex,
    stageIndex: stageIndex,
    qi: qi,
    lastSaved: lastSaved,
  );
}

void main() {
  group('longevity', () {
    test('unmodified lives cultivate at base rate', () {
      final state = stateAt();
      expect(CultivationEngine.longevityFactor(state), 1.0);
    });

    test('centuries of lifespan grant 1% qi per century', () {
      final state = stateAt().copyWith(lifespanBonusYears: 250);
      expect(CultivationEngine.longevityFactor(state), closeTo(1.02, 0.0001));
      expect(
        CultivationEngine.qiPerSecond(state),
        CultivationEngine.qiPerSecond(stateAt()) * 1.02,
      );
    });

    test('the longevity blessing caps at +10%', () {
      final state = stateAt().copyWith(lifespanBonusYears: 5000);
      expect(CultivationEngine.longevityFactor(state), closeTo(1.10, 0.0001));
    });
  });
  group('qiPerSecond', () {
    test('scales with realm', () {
      final early = stateAt();
      final higher = stateAt(realmIndex: 2);
      expect(
        CultivationEngine.qiPerSecond(higher),
        greaterThan(CultivationEngine.qiPerSecond(early)),
      );
    });

    test('scales with stage', () {
      final early = stateAt();
      final peak = stateAt(stageIndex: 3);
      expect(
        CultivationEngine.qiPerSecond(peak),
        greaterThan(CultivationEngine.qiPerSecond(early)),
      );
    });

    test('initial rate is 1 qi per second', () {
      expect(CultivationEngine.qiPerSecond(stateAt()), 1.0);
    });

    test('technique multiplier applies', () {
      final basic = stateAt();
      final flame = basic.copyWith(techniqueId: 'flame');
      expect(
        CultivationEngine.qiPerSecond(flame),
        closeTo(CultivationEngine.qiPerSecond(basic) * 1.5, 1e-9),
      );
    });

    test('qi-type companion multiplier applies', () {
      final withCompanion = stateAt().copyWith(
        companion: const Companion(
          name: 'Ice Crow',
          bonusType: 'qi',
          level: 5,
        ),
      );
      expect(
        CultivationEngine.qiPerSecond(withCompanion),
        closeTo(CultivationEngine.qiPerSecond(stateAt()) * 1.2, 1e-9),
      );
    });
  });

  group('qiToNextStage', () {
    test('grows monotonically across the ladder', () {
      var previous = -1.0;
      for (var globalStage = 0; globalStage < 36; globalStage++) {
        final state = stateAt(
          realmIndex: globalStage ~/ 4,
          stageIndex: globalStage % 4,
        );
        final requirement = CultivationEngine.qiToNextStage(state);
        expect(requirement, greaterThan(previous));
        previous = requirement;
      }
    });

    test('first requirement is 100', () {
      expect(CultivationEngine.qiToNextStage(stateAt()), 100.0);
    });
  });

  group('attemptStageBreakthrough', () {
    test('success advances stage and resets qi', () {
      final state = stateAt(qi: 100000);
      final result =
          CultivationEngine.attemptStageBreakthrough(state, roll: 0.0);
      expect(result.success, isTrue);
      expect(result.state.stageIndex, 1);
      expect(result.state.qi, 0);
      expect(result.state.breakthroughsSucceeded, 1);
    });

    test('failure costs 25 percent of qi', () {
      final state = stateAt(qi: 100);
      final result =
          CultivationEngine.attemptStageBreakthrough(state, roll: 0.999);
      expect(result.success, isFalse);
      expect(result.state.qi, closeTo(75, 0.001));
      expect(result.state.breakthroughsFailed, 1);
    });

    test('refuses to run at a realm peak, a tribulation is required', () {
      final state = stateAt(realmIndex: 0, stageIndex: 3, qi: 1e6);
      final result =
          CultivationEngine.attemptStageBreakthrough(state, roll: 0.0);
      expect(result.success, isFalse);
      expect(result.state.realmIndex, 0);
      expect(result.state.stageIndex, 3);
    });

    test('pill bonus is consumed on success', () {
      final state = stateAt(qi: 100000).copyWith(breakthroughBonus: 0.2);
      final result =
          CultivationEngine.attemptStageBreakthrough(state, roll: 0.92);
      expect(result.success, isTrue);
      expect(result.state.breakthroughBonus, 0);
    });

    test('effective chance is capped and floored', () {
      expect(
        CultivationEngine.effectiveBreakthroughChance(
          stateAt(qi: 100000).copyWith(breakthroughBonus: 0.5),
        ),
        0.95,
      );
      expect(
        CultivationEngine.effectiveBreakthroughChance(
          stateAt(stageIndex: 3, qi: 100000).copyWith(
            techniqueId: 'flame',
          ),
        ),
        0.05,
      );
    });

    test('formation technique adds breakthrough bonus', () {
      final state = stateAt(qi: 100000).copyWith(techniqueId: 'formation');
      expect(
        CultivationEngine.effectiveBreakthroughChance(state),
        closeTo(0.95, 1e-9),
      );
    });

    test('not ready returns unchanged state', () {
      final state = stateAt(qi: 10);
      final result =
          CultivationEngine.attemptStageBreakthrough(state, roll: 0.0);
      expect(result.state.qi, 10);
      expect(result.success, isFalse);
    });
  });

  group('computeOfflineProgress', () {
    test('grants qi for elapsed time', () {
      final savedAt = DateTime.utc(2024, 1, 1);
      final state = stateAt(lastSaved: savedAt);
      final report = CultivationEngine.computeOfflineProgress(
        state,
        savedAt.add(const Duration(hours: 2)),
      );
      expect(
        report.qiGained,
        closeTo(CultivationEngine.qiPerSecond(state) * 7200, 1),
      );
    });

    test('caps at 24 hours', () {
      final savedAt = DateTime.utc(2024, 1, 1);
      final state = stateAt(lastSaved: savedAt);
      final report = CultivationEngine.computeOfflineProgress(
        state,
        savedAt.add(const Duration(days: 3)),
      );
      expect(report.counted, const Duration(hours: 24));
      expect(
        report.qiGained,
        closeTo(CultivationEngine.qiPerSecond(state) * 86400, 1),
      );
    });

    test('handles clock skew with zero gains', () {
      final savedAt = DateTime.utc(2024, 1, 1);
      final state = stateAt(lastSaved: savedAt);
      final report = CultivationEngine.computeOfflineProgress(
        state,
        savedAt.subtract(const Duration(hours: 1)),
      );
      expect(report.counted, Duration.zero);
      expect(report.qiGained, 0);
    });

    test('updates lastSaved on the resulting state', () {
      final savedAt = DateTime.utc(2024, 1, 1);
      final state = stateAt(lastSaved: savedAt);
      final now = savedAt.add(const Duration(minutes: 5));
      final report = CultivationEngine.computeOfflineProgress(state, now);
      expect(report.stateAfter.lastSaved, now);
    });
  });
}
