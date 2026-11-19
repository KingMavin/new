import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/consequence_engine.dart';
import 'package:immortal_path/game/models/consequence.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  test('catalog has unique ids and paired boons/banes', () {
    final ids = ConsequenceCatalog.all.map((c) => c.id).toSet();
    expect(ids.length, ConsequenceCatalog.all.length);
    expect(ConsequenceCatalog.all.where((c) => c.boon).length, greaterThan(0));
    expect(ConsequenceCatalog.all.where((c) => !c.boon).length, greaterThan(0));
    for (final c in ConsequenceCatalog.all) {
      final neutralMul = c.attackMul == 1.0 &&
          c.defenseMul == 1.0 &&
          c.hpMul == 1.0 &&
          c.qiMul == 1.0 &&
          c.stonesMul == 1.0;
      expect(neutralMul, isFalse, reason: '${c.id} has no effect');
    }
    expect(ConsequenceCatalog.byId('missing'), isNull);
  });

  test('factors multiply across marks and default to 1', () {
    final clean = GameState.initial();
    expect(ConsequenceEngine.attackFactor(clean), 1.0);
    expect(ConsequenceEngine.qiFactor(clean), 1.0);

    final marked = clean.copyWith(
      consequences: ['scarred', 'humiliated', 'cursed_wounds'],
    );
    expect(ConsequenceEngine.hpFactor(marked), closeTo(0.90, 0.0001));
    expect(ConsequenceEngine.qiFactor(marked), closeTo(0.97, 0.0001));
    expect(ConsequenceEngine.defenseFactor(marked), closeTo(0.92, 0.0001));
    expect(ConsequenceEngine.attackFactor(marked), 1.0);
  });

  test('combat feathers the marks in', () {
    final clean = GameState.initial().copyWith(raceId: 'human');
    final scarred = clean.copyWith(consequences: ['scarred']);
    expect(
      CombatEngine.playerMaxHp(scarred),
      closeTo(CombatEngine.playerMaxHp(clean) * 0.9, 0.0001),
    );
    final ironWill = clean.copyWith(consequences: ['iron_will']);
    expect(
      CombatEngine.playerAttack(ironWill),
      closeTo(CombatEngine.playerAttack(clean) * 1.05, 0.0001),
    );
    expect(
      CombatEngine.playerDefense(ironWill),
      closeTo(CombatEngine.playerDefense(clean) * 1.05, 0.0001),
    );
  });

  test('grant is idempotent, unknown ids ignored, journal recorded', () {
    final lines = <String>[];
    final first = ConsequenceEngine.grant(
      GameState.initial(),
      'stormtouched',
      lines,
    );
    expect(first, isNotNull);
    expect(first!.consequences, ['stormtouched']);
    expect(lines, hasLength(1));
    expect(lines.first, contains('Stormtouched'));

    final again = ConsequenceEngine.grant(first, 'stormtouched', lines);
    expect(again, isNull);
    expect(ConsequenceEngine.grant(first, 'no_such_mark', lines), isNull);
  });
}
