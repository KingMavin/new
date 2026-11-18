import 'dart:math';

import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/engine/race_engine.dart';
import 'package:immortal_path/game/engine/story_engine.dart';
import 'package:immortal_path/game/engine/reputation_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/game/util/format.dart';

class OfflineReport {
  final Duration elapsed;
  final Duration counted;
  final double qiGained;
  final GameState stateAfter;

  const OfflineReport({
    required this.elapsed,
    required this.counted,
    required this.qiGained,
    required this.stateAfter,
  });
}

class BreakthroughResult {
  final GameState state;
  final bool success;
  final String message;

  const BreakthroughResult({
    required this.state,
    required this.success,
    required this.message,
  });
}

class BreakthroughAttempt {
  final bool tribulationStarted;
  final BreakthroughResult? result;

  const BreakthroughAttempt({this.tribulationStarted = false, this.result});
}

class CultivationEngine {
  static const double realmQiGrowth = 3.8;

  static double qiPerSecond(GameState state) {
    final realmMultiplier =
        pow(CultivationEngine.realmQiGrowth, state.realmIndex).toDouble();
    final stageMultiplier = 1.0 + 0.5 * state.stageIndex;
    final technique = Technique.byId(state.techniqueId);
    final companionMultiplier = 1.0 + (state.companion?.qiBonus ?? 0);
    return realmMultiplier *
        stageMultiplier *
        technique.qiMultiplier *
        companionMultiplier *
        (1.0 + SoulEngine.qiBonus(state)) *
        SectEngine.qiMultiplier(state) *
        RaceEngine.qiMultiplier(state) *
        (1.0 + PowerEngine.qiBonus(state)) *
        (1.0 + ReputationEngine.standingBonus(state));
  }

  static double qiToNextStage(GameState state) =>
      100.0 * pow(1.6, state.globalStageIndex).toDouble();

  static bool isBreakthroughReady(GameState state) =>
      !state.ascended &&
      !state.tribulationActive &&
      state.qi >= qiToNextStage(state);

  static bool isMajorBreakthrough(GameState state) =>
      state.stageIndex == RealmLadder.stagesPerRealm - 1;

  static double breakthroughChance(GameState state) =>
      isMajorBreakthrough(state) ? 0.60 : 0.90 - 0.10 * state.stageIndex;

  static double effectiveBreakthroughChance(GameState state) {
    final technique = Technique.byId(state.techniqueId);
    final chance = breakthroughChance(state) +
        state.breakthroughBonus +
        technique.breakthroughBonus +
        SoulEngine.breakthroughBonus(state) +
        SectEngine.breakthroughBonus(state) +
        StoryEngine.breakthroughBonus(state) +
        PowerEngine.breakthroughBonus(state);
    return chance.clamp(0.05, 0.95).toDouble();
  }

  static BreakthroughResult attemptStageBreakthrough(
    GameState state, {
    double? roll,
  }) {
    if (state.ascended ||
        state.tribulationActive ||
        !isBreakthroughReady(state) ||
        isMajorBreakthrough(state)) {
      return BreakthroughResult(
        state: state,
        success: false,
        message: 'A heavenly tribulation stands between you and the next realm.',
      );
    }

    final success =
        (roll ?? Random().nextDouble()) < effectiveBreakthroughChance(state);
    final now = DateTime.now();

    if (!success) {
      final lost = state.qi * 0.25;
      final updated = state.copyWith(
        qi: state.qi - lost,
        breakthroughsFailed: state.breakthroughsFailed + 1,
        breakthroughBonus: 0,
        lastSaved: now,
      );
      return BreakthroughResult(
        state: updated,
        success: false,
        message:
            'Your qi scatters and the bottleneck holds. You lost ${formatNumber(lost)} qi.',
      );
    }

    final nextStage = state.stageIndex + 1;
    final updated = state.copyWith(
      stageIndex: nextStage,
      qi: 0,
      breakthroughsSucceeded: state.breakthroughsSucceeded + 1,
      breakthroughBonus: 0,
      lastSaved: now,
    );
    return BreakthroughResult(
      state: updated,
      success: true,
      message:
          'Your qi surges — you have reached the ${RealmLadder.stageName(nextStage)} '
          'stage of ${state.realmName}.',
    );
  }

  static OfflineReport computeOfflineProgress(
    GameState state,
    DateTime now, {
    Duration maxOfflineDuration = const Duration(hours: 24),
  }) {
    final elapsed = now.difference(state.lastSaved);
    final counted = elapsed < Duration.zero
        ? Duration.zero
        : (elapsed > maxOfflineDuration ? maxOfflineDuration : elapsed);
    final qiGained = qiPerSecond(state) * counted.inMilliseconds / 1000.0;
    final stateAfter = state.copyWith(
      qi: state.qi + qiGained,
      totalQiGained: state.totalQiGained + qiGained,
      lastSaved: now,
    );
    return OfflineReport(
      elapsed: elapsed,
      counted: counted,
      qiGained: qiGained,
      stateAfter: stateAfter,
    );
  }
}
