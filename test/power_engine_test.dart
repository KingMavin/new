import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/power.dart';
import 'package:immortal_path/game/models/world_location.dart';

void main() {
  group('PowerCatalog', () {
    test('ids are unique and every power has a bonus', () {
      final ids = PowerCatalog.powers.map((p) => p.id).toSet();
      expect(ids.length, PowerCatalog.powers.length);
      for (final power in PowerCatalog.powers) {
        expect(power.magnitude, greaterThan(0));
        expect(power.bonusLabel, isNotEmpty);
      }
      expect(PowerCatalog.foundPowers().length, 6);
      expect(PowerCatalog.sectPowers().length, 3);
    });

    test('byId resolves known and unknown ids', () {
      expect(PowerCatalog.byId('phoenix_ember'), isNotNull);
      expect(PowerCatalog.byId('nope'), isNull);
    });

    test('sect powers carry sect, cost and rank requirements', () {
      for (final power in PowerCatalog.sectPowers()) {
        expect(power.sectId, isNotNull);
        expect(power.contributionCost, greaterThan(0));
        expect(power.minSectRank, greaterThan(0));
      }
    });
  });

  group('PowerEngine bonuses', () {
    test('undiscovered powers grant nothing', () {
      final state = GameState.initial();
      expect(PowerEngine.qiBonus(state), 0);
      expect(PowerEngine.attackBonus(state), 0);
      expect(PowerEngine.defenseBonus(state), 0);
      expect(PowerEngine.hpBonus(state), 0);
      expect(PowerEngine.stoneBonus(state), 0);
      expect(PowerEngine.breakthroughBonus(state), 0);
    });

    test('bonusOf sums magnitudes of discovered powers per type', () {
      final state = GameState.initial().copyWith(
        discoveredPowers: const ['phoenix_ember', 'thunder_marrow'],
      );
      expect(PowerEngine.attackBonus(state), closeTo(0.10, 1e-9));
      expect(PowerEngine.hpBonus(state), closeTo(0.10, 1e-9));
      expect(PowerEngine.qiBonus(state), 0);
    });

    test('same-type powers stack and sect arts count once learned', () {
      final state = GameState.initial().copyWith(
        sectId: 'sword_sect',
        discoveredPowers: const ['phoenix_ember', 'sword_intent'],
      );
      expect(PowerEngine.attackBonus(state), closeTo(0.18, 1e-9));
    });

    test('isDiscovered reflects the state list', () {
      final state = GameState.initial().copyWith(
        discoveredPowers: const ['void_insight'],
      );
      expect(PowerEngine.isDiscovered(state, 'void_insight'), isTrue);
      expect(PowerEngine.isDiscovered(state, 'phoenix_ember'), isFalse);
    });
  });

  group('PowerEngine.rollDiscovery', () {
    final hunt = WorldCatalog.standardLocations().first;
    final elite = WorldCatalog.locations.firstWhere((l) => l.isRaid);

    test('elite locations find powers far more often than hunts', () {
      final rng = Random(7);
      var eliteHits = 0;
      var huntHits = 0;
      for (var i = 0; i < 5000; i++) {
        final state = GameState.initial();
        final eliteFind = PowerEngine.rollDiscovery(state, elite, rng);
        final huntFind = PowerEngine.rollDiscovery(state, hunt, rng);
        if (eliteFind != null) eliteHits++;
        if (huntFind != null) huntHits++;
      }
      expect(eliteHits, greaterThan(200));
      expect(eliteHits, lessThan(400));
      expect(huntHits, greaterThan(20));
      expect(huntHits, lessThan(80));
    });

    test('returns only undiscovered found powers, never sect arts', () {
      final rng = Random(11);
      final seen = <String>{};
      for (var i = 0; i < 3000; i++) {
        final state = GameState.initial();
        final find = PowerEngine.rollDiscovery(state, elite, rng);
        if (find == null) continue;
        final power = PowerCatalog.byId(find)!;
        expect(power.source, 'found');
        expect(power.isSectPower, isFalse);
        seen.add(find);
      }
      for (final id in seen) {
        final sectIds =
            PowerCatalog.sectPowers().map((p) => p.id).toSet();
        expect(sectIds.contains(id), isFalse);
      }
    });

    test('returns null once every found power is discovered', () {
      final allFound = PowerCatalog.foundPowers().map((p) => p.id).toList();
      final state = GameState.initial().copyWith(
        discoveredPowers: allFound,
      );
      final rng = Random(3);
      for (var i = 0; i < 200; i++) {
        expect(PowerEngine.rollDiscovery(state, elite, rng), isNull);
      }
    });
  });

  group('sect arts lapse', () {
    test('sect power bonuses vanish when you are no longer in that sect', () {
      final sworn = GameState.initial().copyWith(
        sectId: 'sword_sect',
        discoveredPowers: const ['phoenix_ember', 'sword_intent'],
      );
      expect(PowerEngine.attackBonus(sworn), closeTo(0.18, 1e-9));

      final left = sworn.copyWith(sectId: null);
      expect(PowerEngine.attackBonus(left), closeTo(0.10, 1e-9));
    });

    test('sect power returns once you rejoin the holding sect', () {
      final rejoined = GameState.initial().copyWith(
        sectId: 'sword_sect',
        discoveredPowers: const ['sword_intent'],
      );
      expect(PowerEngine.attackBonus(rejoined), closeTo(0.08, 1e-9));
    });
  });
}