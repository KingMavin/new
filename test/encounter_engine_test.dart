import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/encounter_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

GameState stateAt({String techniqueId = 'basic', int realmIndex = 0}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    techniqueId: techniqueId,
  );
}

EncounterState playedOut(
  GameState state,
  Beast beast, {
  double? momentRoll,
}) {
  var encounter = EncounterEngine.begin(state, beast);
  var guard = 0;
  while (!encounter.finished && guard < 500) {
    guard++;
    final moment = encounter.pendingMoment;
    if (moment != null) {
      encounter = EncounterEngine.choose(
        encounter,
        state,
        1,
        rng: Random(3),
        roll: momentRoll,
      );
    } else {
      encounter = EncounterEngine.advance(encounter, state, rng: Random(11));
    }
  }
  return encounter;
}

void main() {
  final beast = WorldCatalog.standardLocations()[0].beasts[0];

  test('begin creates an opening moment and full health', () {
    final state = stateAt();
    final encounter = EncounterEngine.begin(state, beast);
    expect(encounter.finished, isFalse);
    expect(encounter.playerHp, CombatEngine.playerMaxHp(state));
    expect(encounter.foeHp, beast.hp);
    expect(encounter.pendingMoment, isNotNull);
    expect(encounter.pendingMoment!.title, 'First Contact');
    expect(encounter.log, isNotEmpty);
  });

  test('advance is blocked while a moment is pending', () {
    final encounter = EncounterEngine.begin(stateAt(), beast);
    final advanced = EncounterEngine.advance(encounter, stateAt(), rng: Random(1));
    expect(identical(advanced, encounter), isTrue);
  });

  test('opening choice success deals damage and clears the moment', () {
    final state = stateAt();
    final encounter = EncounterEngine.begin(state, beast);
    final after = EncounterEngine.choose(
      encounter,
      state,
      0,
      rng: Random(1),
      roll: 0.01,
    );
    expect(after.pendingMoment, isNull);
    expect(after.foeHp, lessThan(beast.hp));
    expect(after.finished, isFalse);
    expect(after.log.length, greaterThan(2));
  });

  test('opening choice failure damages the player', () {
    final state = stateAt();
    final encounter = EncounterEngine.begin(state, beast);
    final after = EncounterEngine.choose(
      encounter,
      state,
      1,
      rng: Random(1),
      roll: 0.99,
    );
    expect(after.playerHp, lessThan(encounter.playerMaxHp));
    expect(after.pendingMoment, isNull);
    expect(after.finished, isFalse);
  });

  test('desperate moment appears when player health is low', () {
    final state = stateAt();
    final encounter = EncounterEngine.begin(state, beast);
    final wounded = EncounterState(
      beast: beast,
      foeHp: beast.hp,
      foeMaxHp: beast.hp,
      playerHp: encounter.playerMaxHp * 0.2,
      playerMaxHp: encounter.playerMaxHp,
      round: 4,
      log: const [],
    );
    final moment = EncounterEngine.advance(wounded, state, rng: Random(2));
    expect(moment.pendingMoment, isNotNull);
    expect(moment.pendingMoment!.title, 'Desperate Straits');
  });

  test('finishing moment appears when the beast is nearly dead', () {
    final state = stateAt();
    final encounter = EncounterEngine.begin(state, beast);
    final bleeding = EncounterState(
      beast: beast,
      foeHp: beast.hp * 0.1,
      foeMaxHp: beast.hp,
      playerHp: encounter.playerMaxHp,
      playerMaxHp: encounter.playerMaxHp,
      round: 4,
      log: const [],
    );
    final moment = EncounterEngine.advance(bleeding, state, rng: Random(2));
    expect(moment.pendingMoment, isNotNull);
    expect(moment.pendingMoment!.title, 'Blood in the Air');
  });

  test('technique moments reflect the equipped technique', () {
    final state = stateAt(techniqueId: 'thunder');
    final encounter = EncounterEngine.begin(state, beast);
    final mid = EncounterState(
      beast: beast,
      foeHp: beast.hp * 0.9,
      foeMaxHp: beast.hp,
      playerHp: encounter.playerMaxHp,
      playerMaxHp: encounter.playerMaxHp,
      round: 3,
      log: const [],
    );
    for (var seed = 0; seed < 40; seed++) {
      final next = EncounterEngine.advance(mid, state, rng: Random(seed));
      if (next.pendingMoment != null) {
        expect(next.pendingMoment!.title, contains('Thunder'));
        return;
      }
    }
    fail('expected a technique moment within 40 seeds');
  });

  test('fleeing successfully ends the encounter without victory', () {
    final state = stateAt();
    final encounter = EncounterEngine.begin(state, beast);
    final desperate = EncounterState(
      beast: beast,
      foeHp: beast.hp,
      foeMaxHp: beast.hp,
      playerHp: encounter.playerMaxHp * 0.2,
      playerMaxHp: encounter.playerMaxHp,
      round: 4,
      log: const [],
      pendingMoment: const EncounterMoment(
        title: 'Desperate Straits',
        text: 'Run.',
        choices: [
          EncounterChoice(
            label: 'Flee',
            successText: 'gone',
            failText: 'caught',
            isFlee: true,
            baseChance: 0.6,
          ),
        ],
      ),
    );
    final fled = EncounterEngine.choose(
      desperate,
      state,
      0,
      rng: Random(1),
      roll: 0.01,
    );
    expect(fled.finished, isTrue);
    expect(fled.fled, isTrue);
    expect(fled.victory, isFalse);
  });

  test('a strong cultivator defeats a starter beast through moments', () {
    final state = stateAt(realmIndex: 4);
    final result = playedOut(state, beast);
    expect(result.finished, isTrue);
    expect(result.victory, isTrue);
  });

  test('encounters are deterministic for a fixed seed path', () {
    final state = stateAt();
    final a = playedOut(state, beast);
    final b = playedOut(state, beast);
    expect(a.victory, b.victory);
    expect(a.log, b.log);
  });

  test('hopeless fights end in defeat, not flee \u2014 the loss that '
      'battlesLost records', () {
    final state = stateAt();
    const juggernaut = Beast(
      name: 'Juggernaut',
      hp: 999999,
      attack: 999,
      defense: 3,
      bonusType: 'attack',
    );
    final result = playedOut(state, juggernaut);
    expect(result.finished, isTrue);
    expect(result.victory, isFalse);
    expect(result.fled, isFalse);
    expect(result.playerHp, 0);
  });
}
