import 'dart:math';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/engine/race_engine.dart';
import 'package:immortal_path/game/engine/reputation_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/engine/story_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/power.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/game/models/world_location.dart';

class MultiplierLayer {
  final String name;
  final double value;

  const MultiplierLayer(this.name, this.value);
}

class StatStack {
  final String stat;
  final List<MultiplierLayer> layers;
  final double flatBonus;

  const StatStack({
    required this.stat,
    required this.layers,
    this.flatBonus = 0,
  });

  double get total =>
      layers.fold(1.0, (product, layer) => product * layer.value) +
      flatBonus;
}

class ZoneCheck {
  final String location;
  final String beast;
  final int realm;
  final bool elite;
  final double killRounds;
  final double deathRounds;

  const ZoneCheck({
    required this.location,
    required this.beast,
    required this.realm,
    required this.elite,
    required this.killRounds,
    required this.deathRounds,
  });

  bool get winnable => killRounds <= deathRounds;

  String get verdict =>
      winnable ? 'win' : (deathRounds > killRounds * 1.25 ? 'death' : 'loss');
}

class CultivationStep {
  final int realm;
  final int stage;
  final double requirement;
  final double qiPerSecond;
  final double idleSeconds;

  const CultivationStep({
    required this.realm,
    required this.stage,
    required this.requirement,
    required this.qiPerSecond,
    required this.idleSeconds,
  });
}

class BalanceReport {
  final StatStack freshQi;
  final StatStack freshAttack;
  final StatStack maxedQi;
  final StatStack maxedAttack;
  final List<CultivationStep> freshCurve;
  final List<CultivationStep> maxedCurve;
  final List<ZoneCheck> freshZones;
  final List<ZoneCheck> peakZones;
  final List<ZoneCheck> maxedZones;

  const BalanceReport({
    required this.freshQi,
    required this.freshAttack,
    required this.maxedQi,
    required this.maxedAttack,
    required this.freshCurve,
    required this.maxedCurve,
    required this.freshZones,
    required this.peakZones,
    required this.maxedZones,
  });

  double get totalFreshIdleSeconds =>
      freshCurve.fold(0, (sum, step) => sum + step.idleSeconds);

  double get totalMaxedIdleSeconds =>
      maxedCurve.fold(0, (sum, step) => sum + step.idleSeconds);

  List<ZoneCheck> get unwinnableFreshZones =>
      freshZones.where((check) => !check.winnable).toList();

  List<ZoneCheck> get unwinnablePeakZones =>
      peakZones.where((check) => !check.winnable).toList();
}

class BalanceSimulator {
  static const List<String> allPowerIds = [
    'phoenix_ember',
    'dragon_scale_heart',
    'thunder_marrow',
    'void_insight',
    'moonveil_blessing',
    'sages_last_word',
    'sword_intent',
    'merged_scripture',
    'grand_formation',
  ];

  static const Map<String, int> maxSoulUpgrades = {
    'qi_attunement': 10,
    'battle_instinct': 10,
    'iron_soul': 10,
    'fortunes_favor': 5,
    'heavenly_insight': 5,
  };

  static GameState unbuffed(int realm, int stage) =>
      GameState.initial().copyWith(
        raceId: 'human',
        realmIndex: realm,
        stageIndex: stage,
      );

  static GameState maxedCombat(int realm, int stage) =>
      GameState.initial().copyWith(
        raceId: 'human',
        sectId: 'sword_sect',
        contribution: 800,
        techniqueId: 'sword',
        companion:
            const Companion(name: 'Frost Wyrm', bonusType: 'attack', level: 10),
        soulUpgrades: maxSoulUpgrades,
        reputation: {'human': 1500},
        pathPoints: const {'sovereignty': 10},
        discoveredPowers: allPowerIds,
        realmIndex: realm,
        stageIndex: stage,
      );

  static GameState maxedIdle(int realm, int stage) =>
      GameState.initial().copyWith(
        raceId: 'human',
        sectId: 'pill_valley',
        contribution: 800,
        techniqueId: 'flame',
        companion:
            const Companion(name: 'Cloud Serpent', bonusType: 'qi', level: 10),
        soulUpgrades: maxSoulUpgrades,
        reputation: {'human': 1500},
        discoveredPowers: allPowerIds,
        realmIndex: realm,
        stageIndex: stage,
      );

  static StatStack qiStack(GameState state) {
    final realmBase =
        pow(CultivationEngine.realmQiGrowth, state.realmIndex).toDouble() *
        (1.0 + 0.5 * state.stageIndex);
    final layers = [
      MultiplierLayer('realm & stage', realmBase),
      MultiplierLayer('technique', Technique.byId(state.techniqueId).qiMultiplier),
      MultiplierLayer(
        'companion',
        1.0 + (state.companion?.qiBonus ?? 0),
      ),
      MultiplierLayer('soul', 1.0 + SoulEngine.qiBonus(state)),
      MultiplierLayer('sect', SectEngine.qiMultiplier(state)),
      MultiplierLayer('race', RaceEngine.qiMultiplier(state)),
      MultiplierLayer('powers', 1.0 + PowerEngine.qiBonus(state)),
      MultiplierLayer('reputation', 1.0 + ReputationEngine.standingBonus(state)),
    ];
    return StatStack(stat: 'qi/s', layers: layers);
  }

  static StatStack attackStack(GameState state) {
    final technique = Technique.byId(state.techniqueId);
    final base =
        10.0 * _pow2(state.realmIndex) * (1.0 + 0.15 * state.stageIndex);
    final layers = [
      MultiplierLayer('realm & stage base', base),
      MultiplierLayer('technique', technique.attackMultiplier),
      MultiplierLayer(
        'companion',
        1.0 + (state.companion?.attackBonus ?? 0),
      ),
      MultiplierLayer('soul', 1.0 + SoulEngine.attackBonus(state)),
      MultiplierLayer('sect', SectEngine.attackMultiplier(state)),
      MultiplierLayer('race', RaceEngine.attackMultiplier(state)),
      MultiplierLayer('story', 1.0 + StoryEngine.attackBonus(state)),
      MultiplierLayer('powers', 1.0 + PowerEngine.attackBonus(state)),
    ];
    return StatStack(
      stat: 'attack',
      layers: layers,
      flatBonus: state.weapon?.power ?? 0,
    );
  }

  static List<CultivationStep> cultivationCurve(GameState base) {
    var state = base.copyWith(realmIndex: 0, stageIndex: 0, qi: 0);
    final steps = <CultivationStep>[];
    for (var g = 0; g < RealmLadder.totalStages; g++) {
      final realm = g ~/ RealmLadder.stagesPerRealm;
      final stage = g % RealmLadder.stagesPerRealm;
      state = state.copyWith(realmIndex: realm, stageIndex: stage, qi: 0);
      final requirement = CultivationEngine.qiToNextStage(state);
      final qiPerSecond = CultivationEngine.qiPerSecond(state);
      final idle = requirement / qiPerSecond;
      steps.add(
        CultivationStep(
          realm: realm,
          stage: stage,
          requirement: requirement,
          qiPerSecond: qiPerSecond,
          idleSeconds: idle,
        ),
      );
    }
    return steps;
  }

  static List<ZoneCheck> zoneChecks(GameState Function(int realm) profileFor) {
    final checks = <ZoneCheck>[];
    for (final location in WorldCatalog.locations) {
      final state = profileFor(location.requiredRealm);
      for (final beast in location.beasts) {
        final attack =
            CombatEngine.playerAttack(state) - (state.weapon?.power ?? 0);
        final defense =
            CombatEngine.playerDefense(state) - (state.armor?.power ?? 0);
        final hp = CombatEngine.playerMaxHp(state);
        final playerDamage = (attack - beast.defense).clamp(1.0, double.infinity);
        final foeDamage = (beast.attack - defense).clamp(1.0, double.infinity);
        checks.add(
          ZoneCheck(
            location: location.name,
            beast: beast.name,
            realm: location.requiredRealm,
            elite: location.isFactionHall || location.isRaid,
            killRounds: beast.hp / playerDamage,
            deathRounds: hp / foeDamage,
          ),
        );
      }
    }
    return checks;
  }

  static BalanceReport report() {
    final freshZones = zoneChecks(
      (realm) => unbuffed(realm, 0),
    );
    final peakZones = zoneChecks(
      (realm) => unbuffed(realm, RealmLadder.stagesPerRealm - 1),
    );
    final maxedZones = zoneChecks(
      (realm) => maxedCombat(realm, RealmLadder.stagesPerRealm - 1),
    );
    return BalanceReport(
      freshQi: qiStack(unbuffed(0, 0)),
      freshAttack: attackStack(unbuffed(0, 0)),
      maxedQi: qiStack(maxedIdle(8, RealmLadder.stagesPerRealm - 1)),
      maxedAttack: attackStack(maxedCombat(8, RealmLadder.stagesPerRealm - 1)),
      freshCurve: cultivationCurve(unbuffed(0, 0)),
      maxedCurve: cultivationCurve(maxedIdle(0, 0)),
      freshZones: freshZones,
      peakZones: peakZones,
      maxedZones: maxedZones,
    );
  }

  static double _pow2(int realm) {
    var value = 1.0;
    for (var i = 0; i < realm; i++) {
      value *= 2.0;
    }
    return value;
  }
}
