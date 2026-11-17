import 'equipment.dart';
import 'realm_ladder.dart';

class GameState {
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
    );
  }

  Map<String, dynamic> toJson() => {
        'version': 2,
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
      );
}
