import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/zone.dart';

GameState stateAt({int realmIndex = 0, int stageIndex = 0}) {
  final base = GameState.initial();
  return base.copyWith(realmIndex: realmIndex, stageIndex: stageIndex);
}

void main() {
  group('player combat stats', () {
    test('scale with realm', () {
      final early = stateAt();
      final higher = stateAt(realmIndex: 3);
      expect(
        CombatEngine.playerAttack(higher),
        greaterThan(CombatEngine.playerAttack(early)),
      );
      expect(
        CombatEngine.playerMaxHp(higher),
        greaterThan(CombatEngine.playerMaxHp(early)),
      );
    });

    test('equipment adds to attack and defense', () {
      final bare = stateAt();
      final armed = bare.copyWith(
        weapon: const Equipment(
          name: 'Iron Sword',
          slot: EquipmentSlot.weapon,
          grade: 0,
          power: 50,
        ),
        armor: const Equipment(
          name: 'Leather Robe',
          slot: EquipmentSlot.armor,
          grade: 0,
          power: 30,
        ),
      );
      expect(
        CombatEngine.playerAttack(armed),
        CombatEngine.playerAttack(bare) + 50,
      );
      expect(
        CombatEngine.playerDefense(armed),
        CombatEngine.playerDefense(bare) + 30,
      );
    });
  });

  group('resolve', () {
    test('starter cultivator defeats a first-zone beast', () {
      final state = stateAt();
      final zone = ZoneCatalog.zones[0];
      final battle = CombatEngine.resolve(state, zone, zone.beasts[0],
          rng: Random(7));
      expect(battle.victory, isTrue);
      expect(battle.rounds, greaterThanOrEqualTo(1));
      expect(battle.log, isNotEmpty);
    });

    test('weak cultivator loses against a late-zone beast', () {
      final state = stateAt();
      final zone = ZoneCatalog.zones[8];
      final battle = CombatEngine.resolve(state, zone, zone.beasts[0],
          rng: Random(7));
      expect(battle.victory, isFalse);
    });

    test('defeat yields no loot', () {
      final state = stateAt();
      final zone = ZoneCatalog.zones[8];
      final battle = CombatEngine.resolve(state, zone, zone.beasts[0],
          rng: Random(7));
      expect(battle.loot.spiritStones, 0);
      expect(battle.loot.spiritHerbs, 0);
      expect(battle.loot.beastCores, 0);
      expect(battle.loot.equipment, isNull);
    });

    test('same seed produces the same battle', () {
      final state = stateAt();
      final zone = ZoneCatalog.zones[0];
      final a = CombatEngine.resolve(state, zone, zone.beasts[0], rng: Random(42));
      final b = CombatEngine.resolve(state, zone, zone.beasts[0], rng: Random(42));
      expect(a.victory, b.victory);
      expect(a.rounds, b.rounds);
      expect(a.log, b.log);
    });
  });

  group('applyLoot', () {
    test('adds resources and battle counters', () {
      final state = stateAt();
      final battle = const BattleResult(
        victory: true,
        rounds: 3,
        log: [],
        loot: LootReward(spiritStones: 12, spiritHerbs: 1, beastCores: 1),
      );
      final outcome = CombatEngine.applyLoot(state, battle);
      expect(outcome.state.spiritStones, 12);
      expect(outcome.state.spiritHerbs, 1);
      expect(outcome.state.beastCores, 1);
      expect(outcome.state.battlesWon, 1);
      expect(outcome.state.battlesLost, 0);
    });

    test('auto-equips stronger weapon and sells the old one', () {
      final state = stateAt().copyWith(
        weapon: const Equipment(
          name: 'Iron Sword',
          slot: EquipmentSlot.weapon,
          grade: 0,
          power: 10,
        ),
      );
      final battle = const BattleResult(
        victory: true,
        rounds: 3,
        log: [],
        loot: LootReward(
          spiritStones: 0,
          spiritHerbs: 0,
          beastCores: 0,
          equipment: Equipment(
            name: 'Spirit Blade',
            slot: EquipmentSlot.weapon,
            grade: 1,
            power: 100,
          ),
        ),
      );
      final outcome = CombatEngine.applyLoot(state, battle);
      expect(outcome.equipped, isTrue);
      expect(outcome.state.weapon?.name, 'Spirit Blade');
      expect(outcome.state.equipmentSold, 1);
      expect(outcome.soldFor, 5);
      expect(outcome.state.spiritStones, 5);
    });

    test('sells weaker equipment without equipping it', () {
      final state = stateAt().copyWith(
        weapon: const Equipment(
          name: 'Spirit Blade',
          slot: EquipmentSlot.weapon,
          grade: 1,
          power: 100,
        ),
      );
      final battle = const BattleResult(
        victory: true,
        rounds: 3,
        log: [],
        loot: LootReward(
          spiritStones: 0,
          spiritHerbs: 0,
          beastCores: 0,
          equipment: Equipment(
            name: 'Iron Sword',
            slot: EquipmentSlot.weapon,
            grade: 0,
            power: 10,
          ),
        ),
      );
      final outcome = CombatEngine.applyLoot(state, battle);
      expect(outcome.equipped, isFalse);
      expect(outcome.state.weapon?.name, 'Spirit Blade');
      expect(outcome.state.equipmentSold, 1);
      expect(outcome.state.spiritStones, 5);
    });

    test('defeat increments losses only', () {
      final state = stateAt();
      final battle = const BattleResult(
        victory: false,
        rounds: 5,
        log: [],
        loot: LootReward(spiritStones: 0, spiritHerbs: 0, beastCores: 0),
      );
      final outcome = CombatEngine.applyLoot(state, battle);
      expect(outcome.state.battlesLost, 1);
      expect(outcome.state.battlesWon, 0);
    });
  });

  group('zone catalog', () {
    test('nine zones with rising requirements', () {
      expect(ZoneCatalog.zones.length, 9);
      for (var i = 1; i < ZoneCatalog.zones.length; i++) {
        expect(
          ZoneCatalog.zones[i].requiredRealm,
          greaterThan(ZoneCatalog.zones[i - 1].requiredRealm),
        );
      }
    });

    test('first zone is unlocked from the start', () {
      expect(CombatEngine.isZoneUnlocked(stateAt(), ZoneCatalog.zones[0]),
          isTrue);
      expect(CombatEngine.isZoneUnlocked(stateAt(), ZoneCatalog.zones[8]),
          isFalse);
    });
  });
}
