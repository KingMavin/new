import 'dart:math';

import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
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

class CultivationEngine {
  static double qiPerSecond(GameState state) {
    final realmMultiplier = pow(2.0, state.realmIndex).toDouble();
    final stageMultiplier = 1.0 + 0.5 * state.stageIndex;
    return realmMultiplier * stageMultiplier;
  }

  static double qiToNextStage(GameState state) =>
      100.0 * pow(1.6, state.globalStageIndex).toDouble();

  static bool isBreakthroughReady(GameState state) =>
      !state.ascended && state.qi >= qiToNextStage(state);

  static bool isMajorBreakthrough(GameState state) =>
      state.stageIndex == RealmLadder.stagesPerRealm - 1;

  static double breakthroughChance(GameState state) =>
      isMajorBreakthrough(state) ? 0.60 : 0.90 - 0.10 * state.stageIndex;

  static double effectiveBreakthroughChance(GameState state) =>
      min(0.95, breakthroughChance(state) + state.breakthroughBonus);

  static BreakthroughResult attemptBreakthrough(GameState state, {double? roll}) {
    if (state.ascended || !isBreakthroughReady(state)) {
      return BreakthroughResult(
        state: state,
        success: false,
        message: 'Not enough qi to attempt a breakthrough.',
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

    if (state.stageIndex < RealmLadder.stagesPerRealm - 1) {
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

    final nextRealm = state.realmIndex + 1;
    if (nextRealm < RealmLadder.realmNames.length) {
      final updated = state.copyWith(
        realmIndex: nextRealm,
        stageIndex: 0,
        qi: 0,
        breakthroughsSucceeded: state.breakthroughsSucceeded + 1,
        breakthroughBonus: 0,
        lastSaved: now,
      );
      return BreakthroughResult(
        state: updated,
        success: true,
        message:
            'Heaven and earth tremble — you have broken through to '
            '${RealmLadder.realmName(nextRealm)}!',
      );
    }

    final updated = state.copyWith(
      qi: 0,
      ascended: true,
      breakthroughsSucceeded: state.breakthroughsSucceeded + 1,
      breakthroughBonus: 0,
      lastSaved: now,
    );
    return BreakthroughResult(
      state: updated,
      success: true,
      message:
          'Tribulation lightning parts the clouds. You have ascended beyond '
          'the mortal world.',
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
    final qiGained =
        qiPerSecond(state) * counted.inMilliseconds / 1000.0;
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
