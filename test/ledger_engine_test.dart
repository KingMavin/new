import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/ledger_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  final now = DateTime(2026, 3, 10, 15, 30);

  group('LedgerEngine', () {
    test('a fresh state can claim', () {
      final state = GameState.initial();
      expect(LedgerEngine.canClaim(state, now: now), isTrue);
    });

    test('claim grants scaled stones, two pills, and marks the day', () {
      final claimed = LedgerEngine.claim(
        GameState.initial().copyWith(realmIndex: 2),
        now: now,
      );
      expect(claimed.dailyLedgerClaimedOn, LedgerEngine.dayOf(now));
      expect(claimed.spiritStones, LedgerEngine.stonesFor(2));
      expect(claimed.qiPills, 2);
      expect(claimed.journal, hasLength(1));
      expect(claimed.journal.first.text, contains('ledger'));
    });

    test('claiming twice on the same day changes nothing', () {
      final state = GameState.initial();
      final claimed = LedgerEngine.claim(state, now: now);
      final again = LedgerEngine.claim(claimed, now: now);
      expect(identical(again, claimed), isTrue);
    });

    test('claiming again the next day works', () {
      final claimed = LedgerEngine.claim(GameState.initial(), now: now);
      final nextDay = LedgerEngine.claim(
        claimed,
        now: now.add(const Duration(days: 1)),
      );
      expect(
        nextDay.dailyLedgerClaimedOn,
        LedgerEngine.dayOf(now.add(const Duration(days: 1))),
      );
      expect(nextDay.spiritStones, LedgerEngine.stonesFor(0) * 2);
    });

    test('omens are deterministic and cycle by day', () {
      expect(LedgerEngine.omenFor(5), LedgerEngine.omenFor(5));
      expect(LedgerEngine.omenFor(5), LedgerEngine.omenFor(13));
      expect(
        LedgerEngine.omenFor(0) != LedgerEngine.omenFor(1),
        isTrue,
      );
    });
  });
}
