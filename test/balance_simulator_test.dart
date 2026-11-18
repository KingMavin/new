import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/balance_simulator.dart';
import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/world_location.dart';

void main() {
  final report = BalanceSimulator.report();

  double bonusMultiplier(StatStack stack) => stack.layers
      .skip(1)
      .fold(1.0, (product, layer) => product * layer.value);

  group('zone difficulty curve', () {
    test('every zone is winnable by a peak-stage unbuffed cultivator', () {
      final failures = report.peakZones
          .where((check) => !check.winnable)
          .map((c) => '${c.beast} (${c.killRounds} vs ${c.deathRounds})')
          .toList();
      expect(failures, isEmpty);
    });

    test('early zones are winnable the moment you enter the realm', () {
      final earlyFresh = report.freshZones
          .where((check) => check.realm <= 2 && !check.elite)
          .toList();
      expect(earlyFresh, isNotEmpty);
      for (final check in earlyFresh) {
        expect(
          check.winnable,
          isTrue,
          reason: '${check.beast} should be beatable on realm entry',
        );
      }
    });

    test('a fully stacked cultivator clears every zone', () {
      for (final check in report.maxedZones) {
        expect(
          check.winnable,
          isTrue,
          reason: '${check.beast} must fall to a maxed build',
        );
      }
    });

    test('only elite grounds may resist a fresh-realm entrant', () {
      final unwinnable = report.unwinnableFreshZones;
      expect(unwinnable, isNotEmpty);
      expect(unwinnable.every((check) => check.elite), isTrue);
    });

    test('beast stats track 2^realm with tuned difficulty bands', () {
      for (final location in WorldCatalog.locations) {
        final elite = location.isFactionHall || location.isRaid;
        for (final beast in location.beasts) {
          final realmScale = _pow2(location.requiredRealm);
          final base = beast.hp / 40.0 / realmScale;
          final difficulty = elite ? base / 2.5 : base;
          final floor = elite ? 1.3 : 0.8;
          final ceiling = elite ? 1.46 : 1.56;
          expect(
            difficulty,
            greaterThan(floor),
            reason: '${beast.name} difficulty $difficulty below floor',
          );
          expect(
            difficulty,
            lessThan(ceiling),
            reason: '${beast.name} difficulty $difficulty above ceiling',
          );
        }
      }
    });
  });

  group('cultivation pacing', () {
    test('opening stage takes about ninety seconds unbuffed', () {
      final first = report.freshCurve.first;
      expect(first.idleSeconds, greaterThan(80));
      expect(first.idleSeconds, lessThan(100));
    });

    test('a full unbuffed climb takes under two days of pure idle', () {
      final hours = report.totalFreshIdleSeconds / 3600;
      expect(hours, greaterThan(15));
      expect(hours, lessThan(40));
    });

    test('realm time ramps smoothly instead of exploding', () {
      final realmCount = RealmLadder.totalStages ~/ RealmLadder.stagesPerRealm;
      final perRealm = List<double>.filled(realmCount, 0);
      for (final step in report.freshCurve) {
        perRealm[step.realm] += step.idleSeconds;
      }
      expect(perRealm.first, lessThan(0.35));
      expect(perRealm.last, greaterThan(4));
      expect(perRealm.last, lessThan(12));
      for (var i = 1; i < perRealm.length; i++) {
        expect(
          perRealm[i] / perRealm[i - 1],
          inInclusiveRange(1.5, 2.2),
          reason: 'realm $i must ramp smoothly over the previous realm',
        );
      }
    });

    test('legacy multipliers meaningfully shorten the climb', () {
      final freshHours = report.totalFreshIdleSeconds / 3600;
      final maxedHours = report.totalMaxedIdleSeconds / 3600;
      expect(freshHours / maxedHours, greaterThan(5));
      expect(maxedHours, greaterThan(0.5));
    });
  });

  group('multiplier stacks', () {
    test('fresh profiles carry no hidden bonuses', () {
      expect(bonusMultiplier(report.freshQi), closeTo(1.0, 1e-9));
      expect(bonusMultiplier(report.freshAttack), closeTo(1.0, 1e-9));
    });

    test('a maxed build lands in a sane band', () {
      final qiBonus = bonusMultiplier(report.maxedQi);
      final attackBonus = bonusMultiplier(report.maxedAttack);
      expect(qiBonus, greaterThan(8));
      expect(qiBonus, lessThan(25));
      expect(attackBonus, greaterThan(5));
      expect(attackBonus, lessThan(25));
    });

    test('stack layers reproduce the engine rates exactly', () {
      final state = BalanceSimulator.maxedIdle(8, 3);
      expect(
        BalanceSimulator.qiStack(state).total,
        closeTo(CultivationEngine.qiPerSecond(state), 1e-6),
      );
      final combatState = BalanceSimulator.maxedCombat(8, 3);
      expect(
        BalanceSimulator.attackStack(combatState).total,
        closeTo(
          CombatEngine.playerAttack(combatState) -
              (combatState.weapon?.power ?? 0),
          1e-6,
        ),
      );
    });
  });
}

double _pow2(int realm) {
  var value = 1.0;
  for (var i = 0; i < realm; i++) {
    value *= 2.0;
  }
  return value;
}
