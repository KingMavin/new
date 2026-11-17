import 'dart:math';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/game/util/format.dart';

enum TribulationAction { withstand, deflect, channel }

class TribulationOutcome {
  final GameState state;
  final bool finished;
  final bool success;
  final String message;

  const TribulationOutcome({
    required this.state,
    required this.finished,
    required this.success,
    required this.message,
  });
}

class TribulationEngine {
  static const int maxWaves = 9;

  static int wavesForRealm(int realmIndex) => min(maxWaves, 3 + realmIndex);

  static double tribulationMaxHp(GameState state) =>
      CombatEngine.playerMaxHp(state) *
      Technique.byId(state.techniqueId).tribulationHpMultiplier;

  static double wavePower(GameState state) =>
      state.tribulationMaxHp * (0.15 + 0.02 * state.tribulationWavesTotal);

  static GameState begin(GameState state) {
    final targetRealm = state.realmIndex + 1;
    final maxHp = tribulationMaxHp(state);
    return state.copyWith(
      qi: 0,
      tribulationActive: true,
      tribulationWavesTotal: wavesForRealm(state.realmIndex),
      tribulationWavesCleared: 0,
      tribulationHp: maxHp,
      tribulationMaxHp: maxHp,
      tribulationTargetRealm: targetRealm,
      tribulationDeflectBonus: state.breakthroughBonus,
      breakthroughBonus: 0,
      tribulationLog: const [
        'Dark clouds gather. The heavenly tribulation begins!',
      ],
    );
  }

  static TribulationOutcome faceWave(
    GameState state,
    TribulationAction action, {
    Random? rng,
    double? roll,
  }) {
    if (!state.tribulationActive) {
      return TribulationOutcome(
        state: state,
        finished: false,
        success: false,
        message: 'No tribulation is underway.',
      );
    }
    final random = rng ?? Random();
    final power = wavePower(state);
    final log = <String>[];
    var updated = state;
    var damage = 0.0;

    switch (action) {
      case TribulationAction.withstand:
        damage = power;
        log.add('You stand firm and endure the lightning.');
      case TribulationAction.deflect:
        final chance =
            (0.5 + state.tribulationDeflectBonus).clamp(0.0, 0.9).toDouble();
        if ((roll ?? random.nextDouble()) < chance) {
          damage = 0;
          log.add('You deflect the bolt with a burst of qi!');
        } else {
          damage = power * 1.5;
          log.add('Your deflection fails — the lightning tears through.');
        }
      case TribulationAction.channel:
        final cost = state.qi * 0.1;
        damage = power * 0.4;
        log.add(
          'You channel ${formatNumber(cost)} qi into a protective barrier.',
        );
        updated = updated.copyWith(qi: state.qi * 0.9);
    }

    final hp = max(0.0, state.tribulationHp - damage);
    final wavesCleared = state.tribulationWavesCleared + 1;
    updated = updated.copyWith(
      tribulationHp: hp,
      tribulationWavesCleared: wavesCleared,
      tribulationLog: [...updated.tribulationLog, ...log],
    );

    if (hp <= 0) {
      updated = updated.copyWith(
        tribulationActive: false,
        tribulationsFailed: state.tribulationsFailed + 1,
        tribulationLog: [
          ...updated.tribulationLog,
          'Your body fails beneath the heavenly lightning.',
        ],
      );
      return TribulationOutcome(
        state: updated,
        finished: true,
        success: false,
        message:
            'The tribulation overwhelms you. The qi you gathered is scattered '
            'to the winds — cultivate and try again.',
      );
    }

    if (wavesCleared >= state.tribulationWavesTotal) {
      final targetRealm = state.tribulationTargetRealm;
      var advanced = updated;
      String message;
      if (targetRealm < RealmLadder.realmNames.length) {
        advanced = updated.copyWith(realmIndex: targetRealm, stageIndex: 0);
        message =
            'Heaven and earth tremble — you have broken through to '
            '${RealmLadder.realmName(targetRealm)}!';
      } else {
        advanced = updated.copyWith(ascended: true);
        message =
            'Tribulation lightning parts the clouds. You have ascended '
            'beyond the mortal world.';
      }
      advanced = advanced.copyWith(
        tribulationActive: false,
        tribulationsSurvived: state.tribulationsSurvived + 1,
        tribulationLog: [
          ...updated.tribulationLog,
          'The clouds part. You have survived!',
        ],
      );
      return TribulationOutcome(
        state: advanced,
        finished: true,
        success: true,
        message: message,
      );
    }

    return TribulationOutcome(
      state: updated,
      finished: false,
      success: false,
      message: log.last,
    );
  }
}
