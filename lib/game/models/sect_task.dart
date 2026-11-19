
class SectTaskType {
  final String id;
  final String title;
  final String description;
  final int baseTarget;
  final int contribution;
  final int reputation;
  final double stonesBase;

  const SectTaskType({
    required this.id,
    required this.title,
    required this.description,
    required this.baseTarget,
    required this.contribution,
    required this.reputation,
    required this.stonesBase,
  });
}

class SectTaskCatalog {
  static const SectTaskType beastHunt = SectTaskType(
    id: 'beast_hunt',
    title: 'Cull the Beasts',
    description: 'The wilds press on the sect roads. Hunt beasts until the '
        'steward marks the tally fulfilled.',
    baseTarget: 4,
    contribution: 25,
    reputation: 10,
    stonesBase: 50,
  );

  static const SectTaskType warServe = SectTaskType(
    id: 'war_serve',
    title: 'Serve the Banner',
    description: 'A clan war stirs the borders. Answer the war horn once, '
        'victory or no.',
    baseTarget: 1,
    contribution: 80,
    reputation: 40,
    stonesBase: 120,
  );

  static const SectTaskType tournamentFight = SectTaskType(
    id: 'tournament_fight',
    title: 'Wear the Sect Colors',
    description: 'The tournament ring shows the strength of the hall. Fight '
        'for the name on your back.',
    baseTarget: 2,
    contribution: 40,
    reputation: 20,
    stonesBase: 70,
  );

  static const SectTaskType brewPills = SectTaskType(
    id: 'brew_pills',
    title: 'Feed the Furnace',
    description: 'The infirmary runs thin. Brew pills for the wounded and '
        'the striving.',
    baseTarget: 2,
    contribution: 30,
    reputation: 8,
    stonesBase: 55,
  );

  static const SectTaskType wanderFar = SectTaskType(
    id: 'wander_far',
    title: 'Walk the Wilds',
    description: 'The sect needs eyes on the roads and maps in the library. '
        'Travel to two different places.',
    baseTarget: 2,
    contribution: 25,
    reputation: 10,
    stonesBase: 45,
  );

  static const List<SectTaskType> all = [
    beastHunt,
    warServe,
    tournamentFight,
    brewPills,
    wanderFar,
  ];
}

class ActiveTask {
  final String typeId;
  final int target;
  final int progress;
  final int contribution;
  final int reputation;
  final double stones;

  const ActiveTask({
    required this.typeId,
    required this.target,
    this.progress = 0,
    required this.contribution,
    required this.reputation,
    required this.stones,
  });

  SectTaskType type() => SectTaskCatalog.all.firstWhere(
        (type) => type.id == typeId,
        orElse: () => SectTaskCatalog.all.first,
      );

  String get title => type().title;

  bool get complete => progress >= target;

  ActiveTask withProgress(int amount) => ActiveTask(
        typeId: typeId,
        target: target,
        progress: (progress + amount).clamp(0, target),
        contribution: contribution,
        reputation: reputation,
        stones: stones,
      );

  Map<String, dynamic> toJson() => {
        'typeId': typeId,
        'target': target,
        'progress': progress,
        'contribution': contribution,
        'reputation': reputation,
        'stones': stones,
      };

  factory ActiveTask.fromJson(Map<String, dynamic> json) => ActiveTask(
        typeId: json['typeId'] as String? ?? 'beast_hunt',
        target: json['target'] as int? ?? 4,
        progress: json['progress'] as int? ?? 0,
        contribution: json['contribution'] as int? ?? 25,
        reputation: json['reputation'] as int? ?? 10,
        stones: (json['stones'] as num?)?.toDouble() ?? 50,
      );
}
