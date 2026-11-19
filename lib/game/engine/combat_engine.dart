import 'dart:math';
import 'package:immortal_path/game/engine/consequence_engine.dart';

import 'package:immortal_path/game/engine/boost_engine.dart';
import 'package:immortal_path/game/engine/mastery_engine.dart';
import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/engine/race_engine.dart';
import 'package:immortal_path/game/engine/reputation_engine.dart';
import 'package:immortal_path/game/engine/story_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/game/models/world_location.dart';
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
  final String beastName;
  final List<String> log;
  final LootReward loot;

  const BattleResult({
    required this.victory,
    required this.rounds,
    this.beastName = '',
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
    final companionMultiplier = 1.0 +
        (state.companion?.attackBonus ?? 0) *
            SectEngine.companionScale(state);
    return 10.0 *
            pow(2.0, state.realmIndex) *
            (1.0 + 0.15 * state.stageIndex) *
            technique.attackMultiplier *
            companionMultiplier *
            (1.0 + SoulEngine.attackBonus(state)) *
            SectEngine.attackMultiplier(state) *
            RaceEngine.attackMultiplier(state) *
            (1.0 + StoryEngine.attackBonus(state)) *
            (1.0 + PowerEngine.attackBonus(state)) *
            (1.0 + MasteryEngine.bonus(state)) *
            ConsequenceEngine.attackFactor(state) +
        (state.weapon?.power ?? 0) +
        (state.amulet?.power ?? 0) * 0.5;
  }

  static double playerDefense(GameState state) {
    final technique = Technique.byId(state.techniqueId);
    return 5.0 *
            pow(2.0, state.realmIndex) *
            (1.0 + 0.15 * state.stageIndex) *
            technique.defenseMultiplier *
            (1.0 + SoulEngine.defenseBonus(state)) *
            RaceEngine.defenseMultiplier(state) *
            (1.0 + PowerEngine.defenseBonus(state)) *
            ConsequenceEngine.defenseFactor(state) +
        (state.armor?.power ?? 0) +
        (state.amulet?.power ?? 0) * 0.5;
  }

  static double playerMaxHp(GameState state) {
    final technique = Technique.byId(state.techniqueId);
    return 100.0 *
        pow(2.0, state.realmIndex) *
        (1.0 + 0.2 * state.stageIndex) *
        technique.hpMultiplier *
        (1.0 + SoulEngine.hpBonus(state)) *
        RaceEngine.hpMultiplier(state) *
        (1.0 + PowerEngine.hpBonus(state)) *
        ConsequenceEngine.hpFactor(state);  }

  static bool isLocationUnlocked(GameState state, WorldLocation location) {
    if (state.realmIndex < location.requiredRealm) return false;
    if (location.requiredReputation > 0) {
      final raceId = location.raceId;
      if (raceId == null || state.raceId != raceId) return false;
      return ReputationEngine.reputationOf(state, raceId) >=
          location.requiredReputation;
    }
    return true;
  }

  static LootReward rollLoot(
    GameState state,
    WorldLocation location,
    Beast beast,
    Random random,
  ) {
    final stones = location.spiritStoneReward *
        (0.8 + random.nextDouble() * 0.4) *
        (1.0 + SoulEngine.stoneBonus(state)) *
        RaceEngine.stoneMultiplier(state) *
        (1.0 + ReputationEngine.standingBonus(state)) *
        (1.0 + StoryEngine.stoneBonus(state)) *
        (1.0 + PowerEngine.stoneBonus(state)) *
        (1.0 + SectEngine.lootStonesBonus(state)) *
        ConsequenceEngine.stonesFactor(state) *
        BoostEngine.multiplierFor(state, 'stones');
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
          (location.maxEquipmentGrade + 1);
      final grade = roll.floor().clamp(0, location.maxEquipmentGrade).toInt();
      final slot =
          random.nextBool() ? EquipmentSlot.weapon : EquipmentSlot.armor;
      final power = (grade + 1) *
          10.0 *
          pow(1.8, location.requiredRealm).toDouble() *
          (0.9 + random.nextDouble() * 0.2);
      equipment = Equipment.create(slot, grade, power);
    }
    if (location.requiredRealm >= 1 && random.nextDouble() < 0.04) {
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

    if (battle.victory &&
        battle.beastName.isNotEmpty &&
        !updated.bestiary.contains(battle.beastName)) {
      updated = updated.copyWith(
        bestiary: [...updated.bestiary, battle.beastName],
      );
    }

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
