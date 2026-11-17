import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/soul_upgrade.dart';

class SoulEngine {
  static int soulPowerGain(GameState state) =>
      (state.realmIndex + 1) * 20 +
      state.tribulationsSurvived * 15 +
      state.breakthroughsSucceeded * 2 +
      state.battlesWon;

  static bool canReincarnate(GameState state) => state.ascended;

  static int upgradeLevel(GameState state, String id) =>
      state.soulUpgrades[id] ?? 0;

  static int upgradeCost(SoulUpgrade upgrade, int currentLevel) =>
      upgrade.baseCost * (currentLevel + 1);

  static double qiBonus(GameState state) =>
      0.25 * upgradeLevel(state, 'qi_attunement');

  static double attackBonus(GameState state) =>
      0.20 * upgradeLevel(state, 'battle_instinct');

  static double defenseBonus(GameState state) =>
      0.20 * upgradeLevel(state, 'iron_soul');

  static double hpBonus(GameState state) =>
      0.20 * upgradeLevel(state, 'iron_soul');

  static double stoneBonus(GameState state) =>
      0.10 * upgradeLevel(state, 'fortunes_favor');

  static double breakthroughBonus(GameState state) =>
      0.04 * upgradeLevel(state, 'heavenly_insight');

  static bool canBuyUpgrade(GameState state, SoulUpgrade upgrade) {
    final level = upgradeLevel(state, upgrade.id);
    if (level >= upgrade.maxLevel) return false;
    return state.soulPower >= upgradeCost(upgrade, level);
  }

  static GameState buyUpgrade(GameState state, SoulUpgrade upgrade) {
    if (!canBuyUpgrade(state, upgrade)) return state;
    final level = upgradeLevel(state, upgrade.id);
    final cost = upgradeCost(upgrade, level);
    final upgrades = Map<String, int>.from(state.soulUpgrades);
    upgrades[upgrade.id] = level + 1;
    return state.copyWith(
      soulPower: state.soulPower - cost,
      soulUpgrades: upgrades,
    );
  }

  static GameState reincarnate(GameState state) {
    if (!state.ascended) return state;
    final now = DateTime.now();
    final keptTechnique =
        state.discoveredTechniques.contains(state.techniqueId)
            ? state.techniqueId
            : 'basic';
    return GameState(
      realmIndex: 0,
      stageIndex: 0,
      qi: 0,
      totalQiGained: 0,
      breakthroughsSucceeded: 0,
      breakthroughsFailed: 0,
      ascended: false,
      runStarted: now,
      lastSaved: now,
      spiritStones: state.spiritStones * 0.5,
      spiritHerbs: 0,
      beastCores: 0,
      qiPills: 0,
      breakthroughPills: 0,
      lifespanPills: 0,
      weapon: null,
      armor: null,
      breakthroughBonus: 0,
      lifespanBonusYears: 0,
      selectedZoneIndex: 0,
      battlesWon: 0,
      battlesLost: 0,
      equipmentSold: 0,
      techniqueId: keptTechnique,
      discoveredTechniques: state.discoveredTechniques,
      companion: state.companion,
      tribulationActive: false,
      tribulationWavesTotal: 0,
      tribulationWavesCleared: 0,
      tribulationHp: 0,
      tribulationMaxHp: 0,
      tribulationTargetRealm: 0,
      tribulationDeflectBonus: 0,
      tribulationLog: const [],
      tribulationsSurvived: 0,
      tribulationsFailed: 0,
      soulPower: state.soulPower + soulPowerGain(state),
      reincarnations: state.reincarnations + 1,
      soulUpgrades: state.soulUpgrades,
      sectId: null,
      contribution: 0,
      disciples: const [],
      missionLog: const [],
      bestiary: state.bestiary,
      pendingEventId: null,
    );
  }
}
