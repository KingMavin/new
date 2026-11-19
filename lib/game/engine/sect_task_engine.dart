import 'dart:math';

import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/sect_task.dart';

class TaskClaim {
  final GameState state;
  final bool isClanTask;
  final String message;

  const TaskClaim({
    required this.state,
    required this.isClanTask,
    required this.message,
  });
}

class SectTaskEngine {
  static const int boardSize = 3;

  static int targetOf(SectTaskType type, int realmIndex) {
    switch (type.id) {
      case 'beast_hunt':
        return type.baseTarget + realmIndex;
      case 'tournament_fight':
        return type.baseTarget + (realmIndex >= 4 ? 1 : 0);
      default:
        return type.baseTarget;
    }
  }

  static double stonesOf(SectTaskType type, int realmIndex) {
    return type.stonesBase * _pow1_8(realmIndex);
  }

  static double _pow1_8(int realmIndex) {
    var out = 1.0;
    for (var i = 0; i < realmIndex; i++) {
      out *= 1.8;
    }
    return out;
  }

  static ActiveTask issue(SectTaskType type, int realmIndex) => ActiveTask(
        typeId: type.id,
        target: targetOf(type, realmIndex),
        contribution: type.contribution,
        reputation: type.reputation,
        stones: stonesOf(type, realmIndex),
      );

  static List<SectTaskType> eligibleTypes({required bool sworn}) => SectTaskCatalog.all
      .where(
        (type) =>
            sworn ||
            (type.id != 'war_serve' && type.id != 'tournament_fight'),
      )
      .toList();

  static GameState freshBoard(GameState state, {Random? rng}) {
    final random = rng ?? Random();
    final types = List<SectTaskType>.of(
      eligibleTypes(sworn: state.sectId != null),
    )..shuffle(random);
    final board = <ActiveTask>[
      for (var i = 0; i < boardSize; i++)
        issue(types[i % types.length], state.realmIndex),
    ];
    return state.copyWith(sectTasks: board);
  }

  static GameState ensureBoard(GameState state, {Random? rng}) {
    if (state.sectTasks.isNotEmpty) return state;
    return freshBoard(state, rng: rng);
  }

  static GameState recordProgress(GameState state, String typeId,
      {int amount = 1}) {
    final tasks = state.sectTasks;
    if (tasks.isEmpty) return state;
    final updated = <ActiveTask>[];
    var touched = false;
    for (final task in tasks) {
      if (!touched && !task.complete && task.typeId == typeId) {
        touched = true;
        updated.add(task.withProgress(amount));
      } else {
        updated.add(task);
      }
    }
    if (!touched) return state;
    return state.copyWith(sectTasks: updated);
  }

  static TaskClaim? claim(GameState state, int index, {Random? rng}) {
    final tasks = state.sectTasks;
    if (index < 0 || index >= tasks.length) return null;
    final task = tasks[index];
    if (!task.complete) return null;
    final type = task.type();
    final isClanTask = state.sectId != null;
    final random = rng ?? Random();
    final remaining = List<SectTaskType>.of(
          eligibleTypes(sworn: state.sectId != null),
        )
          ..removeWhere((candidate) => candidate.id == type.id)
          ..shuffle(random);
    final replacement = issue(remaining.first, state.realmIndex);
    final board = List<ActiveTask>.of(tasks)..[index] = replacement;

    if (isClanTask) {
      final contribution = state.contribution + task.contribution;
      var reputation = state.reputation;
      final raceId = state.raceId;
      if (raceId != null) {
        reputation = {
          ...reputation,
          raceId: (reputation[raceId] ?? 0) + task.reputation,
        };
      }
      return TaskClaim(
        state: state.copyWith(
          contribution: contribution,
          reputation: reputation,
          spiritStones: state.spiritStones + task.stones,
          sectTasks: board,
        ),
        isClanTask: true,
        message: '${type.title} fulfilled: +${task.contribution} '
            'contribution, +${task.reputation} reputation, '
            '+ inscribed reward.',
      );
    }
    final raceId = state.raceId;
    if (raceId == null) return null;
    final reputationGain = (task.reputation * 2.5).round();
    return TaskClaim(
      state: state.copyWith(
        reputation: {
          ...state.reputation,
          raceId: (state.reputation[raceId] ?? 0) + reputationGain,
        },
        spiritStones: state.spiritStones + task.stones,
        sectTasks: board,
      ),
      isClanTask: false,
      message: '${type.title} proven for the halls: +$reputationGain '
          'reputation \u2014 strength, counted.',
    );
  }
}
