import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/sect_task_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/sect_task.dart';

GameState stateAt({required bool sworn, int realmIndex = 2}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    stageIndex: 0,
    raceId: 'human',
    sectId: sworn ? 'formation_hall' : null,
  );
}

void main() {
  group('SectTaskEngine boards', () {
    test('catalog covers five task types with distinct ids', () {
      final ids = SectTaskCatalog.all.map((type) => type.id).toSet();
      expect(SectTaskCatalog.all.length, 5);
      expect(ids.length, 5);
    });

    test('freshBoard issues three distinct tasks', () {
      final state = SectTaskEngine.freshBoard(
        stateAt(sworn: true),
        rng: Random(7),
      );
      expect(state.sectTasks, hasLength(SectTaskEngine.boardSize));
      final types = state.sectTasks.map((task) => task.typeId).toSet();
      expect(types.length, SectTaskEngine.boardSize);
    });

    test('errant boards never offer sect-banner tasks', () {
      for (var seed = 0; seed < 20; seed++) {
        final state = SectTaskEngine.freshBoard(
          stateAt(sworn: false),
          rng: Random(seed),
        );
        for (final task in state.sectTasks) {
          expect(task.typeId, isNot('war_serve'));
          expect(task.typeId, isNot('tournament_fight'));
        }
      }
    });

    test('ensureBoard is a no-op when the board is populated', () {
      final task = const ActiveTask(
        typeId: 'beast_hunt',
        target: 4,
        progress: 1,
        contribution: 25,
        reputation: 10,
        stones: 50,
      );
      final state = stateAt(sworn: true).copyWith(sectTasks: [task]);
      final ensured = SectTaskEngine.ensureBoard(state, rng: Random(3));
      expect(ensured, same(state));
    });

    test('ensureBoard fills an empty board', () {
      final filled = SectTaskEngine.ensureBoard(
        stateAt(sworn: true),
        rng: Random(11),
      );
      expect(filled.sectTasks, hasLength(SectTaskEngine.boardSize));
    });

    test('beast hunt targets grow with the realm', () {
      expect(
        SectTaskEngine.targetOf(SectTaskCatalog.beastHunt, 0),
        SectTaskCatalog.beastHunt.baseTarget,
      );
      expect(SectTaskEngine.targetOf(SectTaskCatalog.beastHunt, 3), 7);
      expect(
        SectTaskEngine.stonesOf(SectTaskCatalog.beastHunt, 2),
        closeTo(SectTaskCatalog.beastHunt.stonesBase * 1.8 * 1.8, 1e-9),
      );
    });
  });

  group('SectTaskEngine.progress', () {
    test('recordProgress fills the first matching incomplete task', () {
      final board = SectTaskEngine.issue(SectTaskCatalog.beastHunt, 2);
      final other = SectTaskEngine.issue(SectTaskCatalog.brewPills, 2);
      final state = stateAt(sworn: true).copyWith(sectTasks: [board, other]);
      final updated = SectTaskEngine.recordProgress(state, 'beast_hunt');
      expect(updated.sectTasks.first.progress, 1);
      expect(updated.sectTasks.last.progress, 0);
    });

    test('recordProgress caps at the target and skips completed tasks', () {
      final done = SectTaskEngine.issue(SectTaskCatalog.beastHunt, 2)
          .withProgress(SectTaskEngine.targetOf(SectTaskCatalog.beastHunt, 2));
      final fresh = SectTaskEngine.issue(SectTaskCatalog.beastHunt, 2);
      final state = stateAt(sworn: true).copyWith(sectTasks: [done, fresh]);
      final once = SectTaskEngine.recordProgress(state, 'beast_hunt');
      expect(once.sectTasks.first.progress, once.sectTasks.first.target);
      expect(once.sectTasks.last.progress, 1);
      for (var i = 0; i < 5; i++) {
        final again = SectTaskEngine.recordProgress(once, 'beast_hunt');
        expect(again.sectTasks.first.progress, again.sectTasks.first.target);
      }
    });

    test('recordProgress is a no-op for absent types', () {
      final state = stateAt(sworn: true);
      expect(SectTaskEngine.recordProgress(state, 'brew_pills'), same(state));
      expect(
        SectTaskEngine.recordProgress(state, 'war_serve'),
        same(state),
      );
    });
  });

  group('SectTaskEngine.claim', () {
    ActiveTask doneTask(SectTaskType type, int realm) =>
        SectTaskEngine.issue(type, realm)
            .withProgress(SectTaskEngine.targetOf(type, realm));

    test('claim on an incomplete task returns null', () {
      final board = SectTaskEngine.issue(SectTaskCatalog.warServe, 3);
      final state = stateAt(sworn: true).copyWith(sectTasks: [board]);
      expect(SectTaskEngine.claim(state, 0), isNull);
    });

    test('claim out of range returns null', () {
      final state = SectTaskEngine.freshBoard(stateAt(sworn: true));
      expect(SectTaskEngine.claim(state, -1), isNull);
      expect(SectTaskEngine.claim(state, 99), isNull);
    });

    test('member claim grants contribution, reputation and stones '
        'and replaces the slot with a different type', () {
      final done = doneTask(SectTaskCatalog.beastHunt, 3);
      final state = stateAt(sworn: true).copyWith(
        contribution: 10,
        sectTasks: [done],
      );
      final result = SectTaskEngine.claim(state, 0, rng: Random(5));
      expect(result, isNotNull);
      expect(result!.isClanTask, isTrue);
      expect(
        result.state.contribution,
        10 + SectTaskCatalog.beastHunt.contribution,
      );
      expect(result.state.raceId, 'human');
      expect(
        result.state.reputation['human'],
        SectTaskCatalog.beastHunt.reputation,
      );
      expect(
        result.state.spiritStones,
        SectTaskEngine.stonesOf(SectTaskCatalog.beastHunt, 3),
      );
      expect(result.state.sectTasks, hasLength(SectTaskEngine.boardSize));
      expect(result.state.sectTasks.first.typeId, isNot('beast_hunt'));
      expect(result.message, contains('fulfilled'));
    });

    test('errant claim pays multiplied reputation without contribution', () {
      final done = doneTask(SectTaskCatalog.beastHunt, 3);
      final state = stateAt(sworn: false).copyWith(sectTasks: [done]);
      final result = SectTaskEngine.claim(state, 0, rng: Random(5));
      expect(result, isNotNull);
      expect(result!.isClanTask, isFalse);
      expect(result.state.sectId, isNull);
      expect(result.state.contribution, 0);
      expect(
        result.state.reputation['human'],
        (SectTaskCatalog.beastHunt.reputation * 2.5).round(),
      );
      expect(result.message, contains('strength, counted'));
    });

    test('errant replacement slots remain eligible for the unsworn', () {
      for (var seed = 0; seed < 20; seed++) {
        final done = doneTask(SectTaskCatalog.wanderFar, 1);
        final state = stateAt(sworn: false).copyWith(sectTasks: [done]);
        final result = SectTaskEngine.claim(state, 0, rng: Random(seed));
        expect(result, isNotNull);
        final replacement = result!.state.sectTasks.first;
        expect(replacement.typeId, isNot('wander_far'));
        expect(replacement.typeId, isNot('war_serve'));
        expect(replacement.typeId, isNot('tournament_fight'));
      }
    });
  });
}
