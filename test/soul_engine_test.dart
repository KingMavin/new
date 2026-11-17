import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/soul_upgrade.dart';

GameState stateAt({
  int realmIndex = 0,
  int stageIndex = 0,
  bool ascended = false,
  int tribulationsSurvived = 0,
  int breakthroughsSucceeded = 0,
  int battlesWon = 0,
  int soulPower = 0,
  Map<String, int> soulUpgrades = const {},
}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    stageIndex: stageIndex,
    ascended: ascended,
    tribulationsSurvived: tribulationsSurvived,
    breakthroughsSucceeded: breakthroughsSucceeded,
    battlesWon: battlesWon,
    soulPower: soulPower,
    soulUpgrades: soulUpgrades,
  );
}

void main() {
  group('soul power gain', () {
    test('scales with realm, tribulations, breakthroughs, battles', () {
      expect(SoulEngine.soulPowerGain(stateAt(realmIndex: 0)), 20);
      expect(SoulEngine.soulPowerGain(stateAt(realmIndex: 8)), 180);
      expect(
        SoulEngine.soulPowerGain(
          stateAt(
            realmIndex: 2,
            tribulationsSurvived: 3,
            breakthroughsSucceeded: 10,
            battlesWon: 25,
          ),
        ),
        60 + 45 + 20 + 25,
      );
    });
  });

  group('reincarnate', () {
    test('refuses unless ascended', () {
      final state = stateAt(realmIndex: 5, spiritStones: 1000);
      final result = SoulEngine.reincarnate(state);
      expect(identical(result, state), isTrue);
    });

    test('resets the run and pays out soul power', () {
      final state = stateAt(
        realmIndex: 8,
        stageIndex: 3,
        ascended: true,
        breakthroughsSucceeded: 20,
        battlesWon: 100,
        tribulationsSurvived: 8,
        spiritStones: 1000,
      );
      final result = SoulEngine.reincarnate(state);
      expect(result.realmIndex, 0);
      expect(result.stageIndex, 0);
      expect(result.qi, 0);
      expect(result.ascended, isFalse);
      expect(result.spiritStones, 500);
      expect(result.spiritHerbs, 0);
      expect(result.beastCores, 0);
      expect(result.weapon, isNull);
      expect(result.sectId, isNull);
      expect(result.disciples, isEmpty);
      expect(result.soulPower, SoulEngine.soulPowerGain(state));
      expect(result.reincarnations, 1);
    });

    test('keeps techniques, companion, bestiary, and upgrades', () {
      final state = stateAt(
        ascended: true,
        soulPower: 40,
        soulUpgrades: const {'qi_attunement': 2},
      ).copyWith(
        discoveredTechniques: const ['basic', 'flame'],
        techniqueId: 'flame',
      );
      final result = SoulEngine.reincarnate(state);
      expect(result.discoveredTechniques, ['basic', 'flame']);
      expect(result.techniqueId, 'flame');
      expect(result.soulUpgrades, {'qi_attunement': 2});
      expect(result.soulPower, 40 + SoulEngine.soulPowerGain(state));
      expect(result.reincarnations, 1);
    });
  });

  group('soul upgrades', () {
    test('cost scales with level', () {
      final upgrade = SoulUpgrade.byId('qi_attunement');
      expect(SoulEngine.upgradeCost(upgrade, 0), 50);
      expect(SoulEngine.upgradeCost(upgrade, 3), 200);
    });

    test('buyUpgrade consumes soul power and levels up', () {
      final state = stateAt(soulPower: 150);
      final upgraded = SoulEngine.buyUpgrade(
        state,
        SoulUpgrade.byId('qi_attunement'),
      );
      expect(upgraded.soulPower, 100);
      expect(upgraded.soulUpgrades['qi_attunement'], 1);
    });

    test('refuses when unaffordable or maxed', () {
      final poor = stateAt(soulPower: 10);
      expect(
        identical(
          SoulEngine.buyUpgrade(poor, SoulUpgrade.byId('qi_attunement')),
          poor,
        ),
        isTrue,
      );
      final maxed = stateAt(
        soulPower: 9999,
        soulUpgrades: const {'fortunes_favor': 5},
      );
      expect(
        identical(
          SoulEngine.buyUpgrade(maxed, SoulUpgrade.byId('fortunes_favor')),
          maxed,
        ),
        isTrue,
      );
    });

    test('bonuses scale from upgrade levels', () {
      final state = stateAt(
        soulUpgrades: const {
          'qi_attunement': 2,
          'battle_instinct': 1,
          'iron_soul': 3,
          'fortunes_favor': 4,
          'heavenly_insight': 5,
        },
      );
      expect(SoulEngine.qiBonus(state), closeTo(0.5, 1e-9));
      expect(SoulEngine.attackBonus(state), closeTo(0.2, 1e-9));
      expect(SoulEngine.defenseBonus(state), closeTo(0.6, 1e-9));
      expect(SoulEngine.hpBonus(state), closeTo(0.6, 1e-9));
      expect(SoulEngine.stoneBonus(state), closeTo(0.4, 1e-9));
      expect(SoulEngine.breakthroughBonus(state), closeTo(0.2, 1e-9));
    });
  });
}
