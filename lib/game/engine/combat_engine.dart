import 'dart:math';

import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/game/models/zone.dart';
import 'package:immortal_path/game/util/format.dart';

class LootReward {
  final double spiritStones;
  final int spiritHerbs;
  final int beastCores;
  final Equipment? equipment;
  final Technique? technique;
  final Companion? tamedCompanion;

  const LootReward({
    required this.spiritStones,
    required this.spiritHerbs,
    required this.beastCores,
    this.equipment,
    this.technique,
    this.tamedCompanion,
  });
}

class BattleResult {
  final bool victory;
  final int rounds;
  final List<String> log;
  final LootReward loot;

  const BattleResult({
    required this.victory,
    required this.rounds,
    required this.log,
    required this.loot,
  });
}

class ExploreOutcome {
  final BattleResult battle;
  final GameState state;
  final bool equipped;
  final double soldFor;

  const ExploreOutcome({
    required this.battle,
    required this.state,
    required this.equipped,
    required this.soldFor,
  });
}

class CombatEngine {
  static double playerAttack(GameState state) {
    final technique = Technique.byId(state.techniqueId);
    final companionMultiplier = 1.0 + (state.companion?.attackBonus ?? 0);
    return 10.0 *
            pow(2.0, state.realmIndex) *
            (1.0 + 0.15 * state.stageIndex) *
            technique.attackMultiplier *
            companionMultiplier +
        (state.weapon?.power ?? 0);
  }

  static double playerDefense(GameState state) {
    final technique = Technique.byId(state.techniqueId);
    return 5.0 *
            pow(2.0, state.realmIndex) *
            (1.0 + 0.15 * state.stageIndex) *
            technique.defenseMultiplier +
        (state.armor?.power ?? 0);
  }

  static double playerMaxHp(GameState state) {
    final technique = Technique.byId(state.techniqueId);
    return 100.0 *
        pow(2.0, state.realmIndex) *
        (1.0 + 0.2 * state.stageIndex) *
        technique.hpMultiplier;
  }

  static bool isZoneUnlocked(GameState state, Zone zone) =>
      state.realmIndex >= zone.requiredRealm;

  static BattleResult resolve(
    GameState state,
    Zone zone,
    Beast beast, {
    Random? rng,
  }) {
    final random = rng ?? Random();
    final attack = playerAttack(state);
    final defense = playerDefense(state);
    var playerHp = playerMaxHp(state);
    var beastHp = beast.hp;
    final log = <String>[];
    var rounds = 0;
    var victory = false;

    while (rounds < 100) {
      rounds++;
      final playerDamage =
          max(1.0, attack - beast.defense) * (0.85 + random.nextDouble() * 0.3);
      beastHp -= playerDamage;
      log.add(
        'Round $rounds: You strike the ${beast.name} for '
        '${playerDamage.toStringAsFixed(1)} damage.',
      );
      if (beastHp <= 0) {
        victory = true;
        log.add('The ${beast.name} is slain!');
        break;
      }
      final beastDamage =
          max(1.0, beast.attack - defense) * (0.85 + random.nextDouble() * 0.3);
      playerHp -= beastDamage;
      log.add(
        'Round $rounds: The ${beast.name} hits you for '
        '${beastDamage.toStringAsFixed(1)} damage.',
      );
      if (playerHp <= 0) {
        log.add('You barely escape with your life.');
        break;
      }
    }

    final loot = victory
        ? rollLoot(state, zone, beast, random)
        : const LootReward(spiritStones: 0, spiritHerbs: 0, beastCores: 0);
    return BattleResult(
      victory: victory,
      rounds: rounds,
      log: log,
      loot: loot,
    );
  }

  static LootReward rollLoot(
    GameState state,
    Zone zone,
    Beast beast,
    Random random,
  ) {
    final stones = zone.spiritStoneReward * (0.8 + random.nextDouble() * 0.4);
    var herbs = 0;
    var cores = 0;
    Equipment? equipment;
    Technique? technique;
    Companion? tamed;

    if (random.nextDouble() < 0.6) {
      herbs = random.nextDouble() < 0.2 ? 2 : 1;
    }
    if (random.nextDouble() < 0.25) cores = 1;
    if (random.nextDouble() < 0.2) {
      final roll = random.nextDouble() *
          random.nextDouble() *
          (zone.maxEquipmentGrade + 1);
      final grade = roll.floor().clamp(0, zone.maxEquipmentGrade).toInt();
      final slot =
          random.nextBool() ? EquipmentSlot.weapon : EquipmentSlot.armor;
      final power = (grade + 1) *
          10.0 *
          pow(1.8, zone.requiredRealm).toDouble() *
          (0.9 + random.nextDouble() * 0.2);
      equipment = Equipment.create(slot, grade, power);
    }
    if (zone.requiredRealm >= 1 && random.nextDouble() < 0.04) {
      final undiscovered = Technique.catalog
          .where(
            (candidate) =>
                candidate.id != 'basic' &&
                !state.discoveredTechniques.contains(candidate.id),
          )
          .toList();
      if (undiscovered.isNotEmpty) {
        technique = undiscovered[random.nextInt(undiscovered.length)];
      }
    }
    if (state.companion == null && random.nextDouble() < 0.08) {
      tamed = Companion(
        name: beast.name,
        bonusType: beast.bonusType,
        level: 1,
      );
    }

    return LootReward(
      spiritStones: stones,
      spiritHerbs: herbs,
      beastCores: cores,
      equipment: equipment,
      technique: technique,
      tamedCompanion: tamed,
    );
  }

  static ExploreOutcome applyLoot(GameState state, BattleResult battle) {
    final loot = battle.loot;
    var updated = state.copyWith(
      spiritStones: state.spiritStones + loot.spiritStones,
      spiritHerbs: state.spiritHerbs + loot.spiritHerbs,
      beastCores: state.beastCores + loot.beastCores,
      battlesWon: state.battlesWon + (battle.victory ? 1 : 0),
      battlesLost: state.battlesLost + (battle.victory ? 0 : 1),
    );

    var equipped = false;
    var soldFor = 0.0;
    final equipment = loot.equipment;
    if (equipment != null) {
      final current = equipment.slot == EquipmentSlot.weapon
          ? state.weapon
          : state.armor;
      if (current == null || equipment.power > current.power) {
        if (current != null) soldFor = current.power * 0.5;
        updated = updated.copyWith(
          weapon: equipment.slot == EquipmentSlot.weapon ? equipment : null,
          armor: equipment.slot == EquipmentSlot.armor ? equipment : null,
          spiritStones: updated.spiritStones + soldFor,
          equipmentSold: state.equipmentSold + (current != null ? 1 : 0),
        );
        equipped = true;
      } else {
        soldFor = equipment.power * 0.5;
        updated = updated.copyWith(
          spiritStones: updated.spiritStones + soldFor,
          equipmentSold: state.equipmentSold + 1,
        );
      }
    }

    if (loot.technique != null) {
      if (!updated.discoveredTechniques.contains(loot.technique!.id)) {
        updated = updated.copyWith(
          discoveredTechniques: [
            ...updated.discoveredTechniques,
            loot.technique!.id,
          ],
        );
      } else {
        updated = updated.copyWith(
          spiritStones: updated.spiritStones + 50,
        );
      }
    }

    if (loot.tamedCompanion != null) {
      updated = updated.copyWith(companion: loot.tamedCompanion);
    }

    return ExploreOutcome(
      battle: battle,
      state: updated,
      equipped: equipped,
      soldFor: soldFor,
    );
  }

  static String describeLoot(LootReward loot) {
    final parts = <String>[
      '${formatNumber(loot.spiritStones)} spirit stones',
      if (loot.spiritHerbs > 0) '${loot.spiritHerbs} spirit herb(s)',
      if (loot.beastCores > 0) '${loot.beastCores} beast core(s)',
      if (loot.equipment != null)
        '${loot.equipment!.name} (${loot.equipment!.gradeName})',
      if (loot.technique != null) 'Technique scroll: ${loot.technique!.name}',
      if (loot.tamedCompanion != null)
        'Tamed companion: ${loot.tamedCompanion!.name}',
    ];
    return parts.join(', ');
  }
}
