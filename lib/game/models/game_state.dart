import 'companion.dart';
import 'disciple.dart';
import 'equipment.dart';
import 'realm_ladder.dart';

class GameState {
  static const Object _unset = Object();

  final int realmIndex;
  final int stageIndex;
  final double qi;
  final double totalQiGained;
  final int breakthroughsSucceeded;
  final int breakthroughsFailed;
  final bool ascended;
  final DateTime runStarted;
  final DateTime lastSaved;
  final double spiritStones;
  final int spiritHerbs;
  final int beastCores;
  final int qiPills;
  final int breakthroughPills;
  final int lifespanPills;
  final Equipment? weapon;
  final Equipment? armor;
  final double breakthroughBonus;
  final int lifespanBonusYears;
  final int selectedZoneIndex;
  final int battlesWon;
  final int battlesLost;
  final int equipmentSold;
  final String techniqueId;
  final List<String> discoveredTechniques;
  final Companion? companion;
  final bool tribulationActive;
  final int tribulationWavesTotal;
  final int tribulationWavesCleared;
  final double tribulationHp;
  final double tribulationMaxHp;
  final int tribulationTargetRealm;
  final double tribulationDeflectBonus;
  final List<String> tribulationLog;
  final int tribulationsSurvived;
  final int tribulationsFailed;
  final int soulPower;
  final int reincarnations;
  final Map<String, int> soulUpgrades;
  final String? sectId;
  final int contribution;
  final List<Disciple> disciples;
  final List<String> missionLog;
  final List<String> bestiary;
  final String? pendingEventId;

  const GameState({
    required this.realmIndex,
    required this.stageIndex,
    required this.qi,
    required this.totalQiGained,
    required this.breakthroughsSucceeded,
    required this.breakthroughsFailed,
    required this.ascended,
    required this.runStarted,
    required this.lastSaved,
    required this.spiritStones,
    required this.spiritHerbs,
    required this.beastCores,
    required this.qiPills,
    required this.breakthroughPills,
    required this.lifespanPills,
    required this.weapon,
    required this.armor,
    required this.breakthroughBonus,
    required this.lifespanBonusYears,
    required this.selectedZoneIndex,
    required this.battlesWon,
    required this.battlesLost,
    required this.equipmentSold,
    required this.techniqueId,
    required this.discoveredTechniques,
    required this.companion,
    required this.tribulationActive,
    required this.tribulationWavesTotal,
    required this.tribulationWavesCleared,
    required this.tribulationHp,
    required this.tribulationMaxHp,
    required this.tribulationTargetRealm,
    required this.tribulationDeflectBonus,
    required this.tribulationLog,
    required this.tribulationsSurvived,
    required this.tribulationsFailed,
    this.soulPower = 0,
    this.reincarnations = 0,
    this.soulUpgrades = const {},
    this.sectId,
    this.contribution = 0,
    this.disciples = const [],
    this.missionLog = const [],
    this.bestiary = const [],
    this.pendingEventId,
  });

  factory GameState.initial() => GameState(
        realmIndex: 0,
        stageIndex: 0,
        qi: 0,
        totalQiGained: 0,
        breakthroughsSucceeded: 0,
        breakthroughsFailed: 0,
        ascended: false,
        runStarted: DateTime.now(),
        lastSaved: DateTime.now(),
        spiritStones: 0,
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
        techniqueId: 'basic',
        discoveredTechniques: const ['basic'],
        companion: null,
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
      );

  int get globalStageIndex =>
      realmIndex * RealmLadder.stagesPerRealm + stageIndex;

  String get realmName => RealmLadder.realmName(realmIndex);

  String get stageName => RealmLadder.stageName(stageIndex);

  int get lifespanYears =>
      RealmLadder.lifespanYears(realmIndex) + lifespanBonusYears;

  GameState copyWith({
    int? realmIndex,
    int? stageIndex,
    double? qi,
    double? totalQiGained,
    int? breakthroughsSucceeded,
    int? breakthroughsFailed,
    bool? ascended,
    DateTime? runStarted,
    DateTime? lastSaved,
    double? spiritStones,
    int? spiritHerbs,
    int? beastCores,
    int? qiPills,
    int? breakthroughPills,
    int? lifespanPills,
    Equipment? weapon,
    Equipment? armor,
    double? breakthroughBonus,
    int? lifespanBonusYears,
    int? selectedZoneIndex,
    int? battlesWon,
    int? battlesLost,
    int? equipmentSold,
    String? techniqueId,
    List<String>? discoveredTechniques,
    Companion? companion,
    bool? tribulationActive,
    int? tribulationWavesTotal,
    int? tribulationWavesCleared,
    double? tribulationHp,
    double? tribulationMaxHp,
    int? tribulationTargetRealm,
    double? tribulationDeflectBonus,
    List<String>? tribulationLog,
    int? tribulationsSurvived,
    int? tribulationsFailed,
    int? soulPower,
    int? reincarnations,
    Map<String, int>? soulUpgrades,
    Object? sectId = _unset,
    int? contribution,
    List<Disciple>? disciples,
    List<String>? missionLog,
    List<String>? bestiary,
    Object? pendingEventId = _unset,
  }) {
    return GameState(
      realmIndex: realmIndex ?? this.realmIndex,
      stageIndex: stageIndex ?? this.stageIndex,
      qi: qi ?? this.qi,
      totalQiGained: totalQiGained ?? this.totalQiGained,
      breakthroughsSucceeded:
          breakthroughsSucceeded ?? this.breakthroughsSucceeded,
      breakthroughsFailed: breakthroughsFailed ?? this.breakthroughsFailed,
      ascended: ascended ?? this.ascended,
      runStarted: runStarted ?? this.runStarted,
      lastSaved: lastSaved ?? this.lastSaved,
      spiritStones: spiritStones ?? this.spiritStones,
      spiritHerbs: spiritHerbs ?? this.spiritHerbs,
      beastCores: beastCores ?? this.beastCores,
      qiPills: qiPills ?? this.qiPills,
      breakthroughPills: breakthroughPills ?? this.breakthroughPills,
      lifespanPills: lifespanPills ?? this.lifespanPills,
      weapon: weapon ?? this.weapon,
      armor: armor ?? this.armor,
      breakthroughBonus: breakthroughBonus ?? this.breakthroughBonus,
      lifespanBonusYears: lifespanBonusYears ?? this.lifespanBonusYears,
      selectedZoneIndex: selectedZoneIndex ?? this.selectedZoneIndex,
      battlesWon: battlesWon ?? this.battlesWon,
      battlesLost: battlesLost ?? this.battlesLost,
      equipmentSold: equipmentSold ?? this.equipmentSold,
      techniqueId: techniqueId ?? this.techniqueId,
      discoveredTechniques:
          discoveredTechniques ?? this.discoveredTechniques,
      companion: companion ?? this.companion,
      tribulationActive: tribulationActive ?? this.tribulationActive,
      tribulationWavesTotal:
          tribulationWavesTotal ?? this.tribulationWavesTotal,
      tribulationWavesCleared:
          tribulationWavesCleared ?? this.tribulationWavesCleared,
      tribulationHp: tribulationHp ?? this.tribulationHp,
      tribulationMaxHp: tribulationMaxHp ?? this.tribulationMaxHp,
      tribulationTargetRealm:
          tribulationTargetRealm ?? this.tribulationTargetRealm,
      tribulationDeflectBonus:
          tribulationDeflectBonus ?? this.tribulationDeflectBonus,
      tribulationLog: tribulationLog ?? this.tribulationLog,
      tribulationsSurvived:
          tribulationsSurvived ?? this.tribulationsSurvived,
      tribulationsFailed: tribulationsFailed ?? this.tribulationsFailed,
      soulPower: soulPower ?? this.soulPower,
      reincarnations: reincarnations ?? this.reincarnations,
      soulUpgrades: soulUpgrades ?? this.soulUpgrades,
      sectId: sectId == _unset ? this.sectId : sectId as String?,
      contribution: contribution ?? this.contribution,
      disciples: disciples ?? this.disciples,
      missionLog: missionLog ?? this.missionLog,
      bestiary: bestiary ?? this.bestiary,
      pendingEventId: pendingEventId == _unset
          ? this.pendingEventId
          : pendingEventId as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': 4,
        'realmIndex': realmIndex,
        'stageIndex': stageIndex,
        'qi': qi,
        'totalQiGained': totalQiGained,
        'breakthroughsSucceeded': breakthroughsSucceeded,
        'breakthroughsFailed': breakthroughsFailed,
        'ascended': ascended,
        'runStarted': runStarted.toIso8601String(),
        'lastSaved': lastSaved.toIso8601String(),
        'spiritStones': spiritStones,
        'spiritHerbs': spiritHerbs,
        'beastCores': beastCores,
        'qiPills': qiPills,
        'breakthroughPills': breakthroughPills,
        'lifespanPills': lifespanPills,
        'weapon': weapon?.toJson(),
        'armor': armor?.toJson(),
        'breakthroughBonus': breakthroughBonus,
        'lifespanBonusYears': lifespanBonusYears,
        'selectedZoneIndex': selectedZoneIndex,
        'battlesWon': battlesWon,
        'battlesLost': battlesLost,
        'equipmentSold': equipmentSold,
        'techniqueId': techniqueId,
        'discoveredTechniques': discoveredTechniques,
        'companion': companion?.toJson(),
        'tribulationActive': tribulationActive,
        'tribulationWavesTotal': tribulationWavesTotal,
        'tribulationWavesCleared': tribulationWavesCleared,
        'tribulationHp': tribulationHp,
        'tribulationMaxHp': tribulationMaxHp,
        'tribulationTargetRealm': tribulationTargetRealm,
        'tribulationDeflectBonus': tribulationDeflectBonus,
        'tribulationLog': tribulationLog,
        'tribulationsSurvived': tribulationsSurvived,
        'tribulationsFailed': tribulationsFailed,
        'soulPower': soulPower,
        'reincarnations': reincarnations,
        'soulUpgrades': soulUpgrades,
        'sectId': sectId,
        'contribution': contribution,
        'disciples': disciples.map((d) => d.toJson()).toList(),
        'missionLog': missionLog,
        'bestiary': bestiary,
        'pendingEventId': pendingEventId,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        realmIndex: json['realmIndex'] as int,
        stageIndex: json['stageIndex'] as int,
        qi: (json['qi'] as num).toDouble(),
        totalQiGained: (json['totalQiGained'] as num).toDouble(),
        breakthroughsSucceeded: json['breakthroughsSucceeded'] as int? ?? 0,
        breakthroughsFailed: json['breakthroughsFailed'] as int? ?? 0,
        ascended: json['ascended'] as bool? ?? false,
        runStarted: DateTime.parse(json['runStarted'] as String),
        lastSaved: DateTime.parse(json['lastSaved'] as String),
        spiritStones: (json['spiritStones'] as num?)?.toDouble() ?? 0,
        spiritHerbs: json['spiritHerbs'] as int? ?? 0,
        beastCores: json['beastCores'] as int? ?? 0,
        qiPills: json['qiPills'] as int? ?? 0,
        breakthroughPills: json['breakthroughPills'] as int? ?? 0,
        lifespanPills: json['lifespanPills'] as int? ?? 0,
        weapon: json['weapon'] == null
            ? null
            : Equipment.fromJson(json['weapon'] as Map<String, dynamic>),
        armor: json['armor'] == null
            ? null
            : Equipment.fromJson(json['armor'] as Map<String, dynamic>),
        breakthroughBonus: (json['breakthroughBonus'] as num?)?.toDouble() ?? 0,
        lifespanBonusYears: json['lifespanBonusYears'] as int? ?? 0,
        selectedZoneIndex: json['selectedZoneIndex'] as int? ?? 0,
        battlesWon: json['battlesWon'] as int? ?? 0,
        battlesLost: json['battlesLost'] as int? ?? 0,
        equipmentSold: json['equipmentSold'] as int? ?? 0,
        techniqueId: json['techniqueId'] as String? ?? 'basic',
        discoveredTechniques: (json['discoveredTechniques'] as List<dynamic>?)
                ?.map((entry) => entry as String)
                .toList() ??
            ['basic'],
        companion: json['companion'] == null
            ? null
            : Companion.fromJson(json['companion'] as Map<String, dynamic>),
        tribulationActive: json['tribulationActive'] as bool? ?? false,
        tribulationWavesTotal: json['tribulationWavesTotal'] as int? ?? 0,
        tribulationWavesCleared: json['tribulationWavesCleared'] as int? ?? 0,
        tribulationHp: (json['tribulationHp'] as num?)?.toDouble() ?? 0,
        tribulationMaxHp: (json['tribulationMaxHp'] as num?)?.toDouble() ?? 0,
        tribulationTargetRealm: json['tribulationTargetRealm'] as int? ?? 0,
        tribulationDeflectBonus:
            (json['tribulationDeflectBonus'] as num?)?.toDouble() ?? 0,
        tribulationLog: (json['tribulationLog'] as List<dynamic>?)
                ?.map((entry) => entry as String)
                .toList() ??
            const [],
        tribulationsSurvived: json['tribulationsSurvived'] as int? ?? 0,
        tribulationsFailed: json['tribulationsFailed'] as int? ?? 0,
        soulPower: json['soulPower'] as int? ?? 0,
        reincarnations: json['reincarnations'] as int? ?? 0,
        soulUpgrades: (json['soulUpgrades'] as Map<String, dynamic>?)
                ?.map(
                  (key, value) => MapEntry(key, (value as num).toInt()),
                ) ??
            const {},
        sectId: json['sectId'] as String?,
        contribution: json['contribution'] as int? ?? 0,
        disciples: (json['disciples'] as List<dynamic>?)
                ?.map(
                  (entry) => Disciple.fromJson(entry as Map<String, dynamic>),
                )
                .toList() ??
            const [],
        missionLog: (json['missionLog'] as List<dynamic>?)
                ?.map((entry) => entry as String)
                .toList() ??
            const [],
        bestiary: (json['bestiary'] as List<dynamic>?)
                ?.map((entry) => entry as String)
                .toList() ??
            const [],
        pendingEventId: json['pendingEventId'] as String?,
      );
}
