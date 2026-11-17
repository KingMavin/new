import 'dart:math';

import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/disciple.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/util/format.dart';

class MissionType {
  final String id;
  final String name;
  final double herbsPerHour;
  final double stonesPerHour;
  final double coresPerHour;

  const MissionType({
    required this.id,
    required this.name,
    this.herbsPerHour = 0,
    this.stonesPerHour = 0,
    this.coresPerHour = 0,
  });
}

class MissionReport {
  final GameState state;
  final String message;

  const MissionReport({required this.state, required this.message});
}

class DiscipleEngine {
  static const int recruitCost = 100;
  static const int maxDisciples = 3;
  static const int maxDiscipleLevel = 10;
  static const int maxMissionLogEntries = 10;
  static const List<double> missionDurations = [0.5, 2, 8];
  static const List<String> discipleNames = [
    'Lin Xiao',
    'Bai Xue',
    'Chen Feng',
    'Su Yan',
    'Wu Kang',
    'Zhao Mei',
    'Han Li',
    'Yun Rou',
  ];

  static const List<MissionType> missionTypes = [
    MissionType(
      id: 'gather_herbs',
      name: 'Gather Herbs',
      herbsPerHour: 2,
    ),
    MissionType(
      id: 'mine_stones',
      name: 'Mine Spirit Stones',
      stonesPerHour: 15,
    ),
    MissionType(
      id: 'hunt',
      name: 'Hunt Beasts',
      coresPerHour: 0.25,
    ),
  ];

  static MissionType missionById(String id) => missionTypes.firstWhere(
        (mission) => mission.id == id,
        orElse: () => missionTypes.first,
      );

  static int contributionFor(double hours, int level) =>
      (10 * hours * (1 + 0.1 * level)).round();

  static bool canRecruit(GameState state) =>
      state.spiritStones >= recruitCost &&
      state.disciples.length < maxDisciples;

  static GameState recruit(GameState state, {Random? rng}) {
    if (!canRecruit(state)) return state;
    final random = rng ?? Random();
    final used = state.disciples.map((d) => d.name).toSet();
    final available =
        discipleNames.where((name) => !used.contains(name)).toList();
    final name = available.isEmpty
        ? 'Disciple ${state.disciples.length + 1}'
        : available[random.nextInt(available.length)];
    return state.copyWith(
      spiritStones: state.spiritStones - recruitCost,
      disciples: [
        ...state.disciples,
        Disciple(name: name, level: 1),
      ],
    );
  }

  static bool canDispatch(GameState state, int index) {
    if (index < 0 || index >= state.disciples.length) return false;
    return !state.disciples[index].onMission;
  }

  static GameState dispatch(
    GameState state,
    int index,
    String missionId,
    double hours, {
    DateTime? now,
  }) {
    if (!canDispatch(state, index)) return state;
    final end = (now ?? DateTime.now())
        .add(Duration(milliseconds: (hours * 3600 * 1000).round()));
    final disciples = List<Disciple>.from(state.disciples);
    final disciple = disciples[index];
    disciples[index] = Disciple(
      name: disciple.name,
      level: disciple.level,
      missionType: missionId,
      missionHours: hours,
      missionEndsAt: end,
    );
    return state.copyWith(disciples: disciples);
  }

  static MissionReport? collectIfReady(
    GameState state,
    int index, {
    DateTime? now,
  }) {
    if (index < 0 || index >= state.disciples.length) return null;
    final disciple = state.disciples[index];
    if (!disciple.onMission) return null;
    final current = now ?? DateTime.now();
    if (current.isBefore(disciple.missionEndsAt!)) return null;

    final mission = missionById(disciple.missionType!);
    final hours = disciple.missionHours ?? 0;
    final levelFactor = 1.0 + 0.1 * disciple.level;
    final herbs =
        (mission.herbsPerHour * hours * levelFactor).floor();
    final stones = mission.stonesPerHour *
        hours *
        levelFactor *
        (1.0 + SoulEngine.stoneBonus(state));
    final cores = mission.coresPerHour * hours * levelFactor;
    final coreCount = cores.floor();
    final contribution = contributionFor(hours, disciple.level);

    final log = [
      '${disciple.name} returned from ${mission.name}: '
          '+$herbs herbs, +${formatNumber(stones)} stones, +$coreCount cores.',
      ...state.missionLog,
    ];
    return MissionReport(
      state: state.copyWith(
        spiritHerbs: state.spiritHerbs + herbs,
        spiritStones: state.spiritStones + stones,
        beastCores: state.beastCores + coreCount,
        contribution: state.contribution + contribution,
        disciples: [
          for (var i = 0; i < state.disciples.length; i++)
            if (i == index)
              Disciple(
                name: disciple.name,
                level: disciple.level < maxDiscipleLevel
                    ? disciple.level + 1
                    : disciple.level,
              )
            else
              state.disciples[i],
        ],
        missionLog: log.sublist(0, log.length > maxMissionLogEntries ? maxMissionLogEntries : log.length),
      ),
      message:
          '${disciple.name} completed the mission and earned '
          '$contribution contribution.',
    );
  }
}
