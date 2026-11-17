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
      );

  int get globalStageIndex =>
      realmIndex * RealmLadder.stagesPerRealm + stageIndex;

  String get realmName => RealmLadder.realmName(realmIndex);

  String get stageName => RealmLadder.stageName(stageIndex);

  int get lifespanYears => RealmLadder.lifespanYears(realmIndex);

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
  }) {
    return GameState(
      realmIndex: realmIndex ?? this.realmIndex,
      stageIndex: stageIndex ?? this.stageIndex,
      qi: qi ?? this.qi,
      totalQiGained: totalQiGained ?? this.totalQiGained,
      breakthroughsSucceeded: breakthroughsSucceeded ?? this.breakthroughsSucceeded,
      breakthroughsFailed: breakthroughsFailed ?? this.breakthroughsFailed,
      ascended: ascended ?? this.ascended,
      runStarted: runStarted ?? this.runStarted,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'realmIndex': realmIndex,
        'stageIndex': stageIndex,
        'qi': qi,
        'totalQiGained': totalQiGained,
        'breakthroughsSucceeded': breakthroughsSucceeded,
        'breakthroughsFailed': breakthroughsFailed,
        'ascended': ascended,
        'runStarted': runStarted.toIso8601String(),
        'lastSaved': lastSaved.toIso8601String(),
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
      );
}
