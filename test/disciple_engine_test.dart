import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/disciple_engine.dart';
import 'package:immortal_path/game/models/disciple.dart';
import 'package:immortal_path/game/models/game_state.dart';

GameState stateAt({
  double spiritStones = 0,
  List<Disciple> disciples = const [],
}) {
  return GameState.initial().copyWith(
    spiritStones: spiritStones,
    disciples: disciples,
  );
}

void main() {
  group('recruit', () {
    test('requires stones and open slots', () {
      expect(
        DiscipleEngine.canRecruit(stateAt(spiritStones: 50)),
        isFalse,
      );
      expect(
        DiscipleEngine.canRecruit(stateAt(spiritStones: 150)),
        isTrue,
      );
      final full = stateAt(
        spiritStones: 500,
        disciples: const [
          Disciple(name: 'A', level: 1),
          Disciple(name: 'B', level: 1),
          Disciple(name: 'C', level: 1),
        ],
      );
      expect(DiscipleEngine.canRecruit(full), isFalse);
    });

    test('recruit charges stones and adds a named disciple', () {
      final state = stateAt(spiritStones: 200);
      final updated = DiscipleEngine.recruit(state, rng: Random(1));
      expect(updated.spiritStones, 100);
      expect(updated.disciples.length, 1);
      expect(updated.disciples.first.level, 1);
      expect(updated.disciples.first.onMission, isFalse);
    });
  });

  group('dispatch', () {
    test('cannot dispatch an already-dispatched disciple', () {
      final state = stateAt(
        disciples: [
          const Disciple(
            name: 'Lin Xiao',
            level: 1,
            missionType: 'hunt',
            missionHours: 2,
          ),
        ],
      );
      expect(DiscipleEngine.canDispatch(state, 0), isFalse);
      expect(
        identical(DiscipleEngine.dispatch(state, 0, 'hunt', 2), state),
        isTrue,
      );
    });

    test('dispatch sets mission type, hours, and end time', () {
      final state = stateAt(
        disciples: const [Disciple(name: 'Lin Xiao', level: 1)],
      );
      final now = DateTime(2024, 5, 5, 12);
      final updated = DiscipleEngine.dispatch(
        state,
        0,
        'gather_herbs',
        2,
        now: now,
      );
      expect(updated.disciples.first.onMission, isTrue);
      expect(updated.disciples.first.missionHours, 2);
      expect(updated.disciples.first.missionEndsAt, now.add(const Duration(hours: 2)));
    });
  });

  group('collectIfReady', () {
    test('returns null while the mission is still running', () {
      final now = DateTime(2024, 5, 5, 12);
      final state = stateAt(
        disciples: [
          Disciple(
            name: 'Lin Xiao',
            level: 1,
            missionType: 'gather_herbs',
            missionHours: 2,
            missionEndsAt: now.add(const Duration(hours: 1)),
          ),
        ],
      );
      expect(DiscipleEngine.collectIfReady(state, 0, now: now), isNull);
    });

    test('collects herbs, contribution, and levels the disciple', () {
      final now = DateTime(2024, 5, 5, 12);
      final state = stateAt(
        spiritStones: 0,
        disciples: [
          Disciple(
            name: 'Lin Xiao',
            level: 1,
            missionType: 'gather_herbs',
            missionHours: 2,
            missionEndsAt: now.subtract(const Duration(minutes: 1)),
          ),
        ],
      );
      final report = DiscipleEngine.collectIfReady(state, 0, now: now);
      expect(report, isNotNull);
      expect(report!.state.spiritHerbs, (2 * 2 * 1.1).floor());
      expect(
        report.state.contribution,
        DiscipleEngine.contributionFor(2, 1),
      );
      expect(report.state.disciples.first.onMission, isFalse);
      expect(report.state.disciples.first.level, 2);
      expect(report.state.missionLog.length, 1);
      expect(report.message, contains('Lin Xiao'));
    });

    test('stone missions apply fortune bonus and floor cores', () {
      final now = DateTime(2024, 5, 5, 12);
      final stones = stateAt(
        spiritStones: 0,
        disciples: [
          Disciple(
            name: 'Bai Xue',
            level: 1,
            missionType: 'mine_stones',
            missionHours: 2,
            missionEndsAt: now.subtract(const Duration(minutes: 1)),
          ),
        ],
      );
      final report = DiscipleEngine.collectIfReady(stones, 0, now: now);
      expect(report!.state.spiritStones, closeTo(15 * 2 * 1.1, 1e-9));

      final hunt = stateAt(
        disciples: [
          Disciple(
            name: 'Chen Feng',
            level: 1,
            missionType: 'hunt',
            missionHours: 2,
            missionEndsAt: now.subtract(const Duration(minutes: 1)),
          ),
        ],
      );
      final huntReport = DiscipleEngine.collectIfReady(hunt, 0, now: now);
      expect(huntReport!.state.beastCores, 0);
    });
  });

  test('disciple json roundtrip preserves missions', () {
    const disciple = Disciple(
      name: 'Su Yan',
      level: 4,
      missionType: 'hunt',
      missionHours: 0.5,
    );
    final parsed = Disciple.fromJson(disciple.toJson());
    expect(parsed.name, 'Su Yan');
    expect(parsed.level, 4);
    expect(parsed.missionType, 'hunt');
    expect(parsed.missionHours, 0.5);
  });
}
