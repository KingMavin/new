import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

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

  group('world catalog', () {
    test('nine standard regions with rising requirements', () {
      final regions = WorldCatalog.standardLocations();
      expect(regions.length, 9);
      for (var i = 1; i < regions.length; i++) {
        expect(
          regions[i].requiredRealm,
          greaterThan(regions[i - 1].requiredRealm),
        );
      }
    });

    test('first region is unlocked from the start', () {
      final regions = WorldCatalog.standardLocations();
      expect(
        CombatEngine.isLocationUnlocked(stateAt(), regions[0]),
        isTrue,
      );
      expect(
        CombatEngine.isLocationUnlocked(stateAt(), regions[8]),
        isFalse,
      );
    });
  });
}
