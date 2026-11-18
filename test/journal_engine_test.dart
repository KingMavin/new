import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/journal_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  group('JournalEngine', () {
    test('record prepends the newest entry first', () {
      var state = GameState.initial();
      state = JournalEngine.record(state, 'A');
      state = JournalEngine.record(state, 'B');
      expect(state.journal.first.text, 'B');
      expect(state.journal.last.text, 'A');
      expect(state.journal, hasLength(2));
    });

    test('the chronicle is capped at 60 entries', () {
      var state = GameState.initial();
      for (var i = 0; i < 65; i++) {
        state = JournalEngine.record(state, 'entry $i');
      }
      expect(state.journal, hasLength(JournalEngine.cap));
      expect(state.journal.first.text, 'entry 64');
      expect(state.journal.last.text, 'entry 5');
    });

    test('entries roundtrip through json', () {
      var state = JournalEngine.record(
        GameState.initial(),
        'The crane crosses the moon.',
        now: DateTime(2026, 1, 2, 3, 4),
      );
      final json = state.toJson();
      final parsed = GameState.fromJson(json);
      expect(parsed.journal, hasLength(1));
      expect(parsed.journal.first.text, 'The crane crosses the moon.');
      expect(parsed.journal.first.time, DateTime(2026, 1, 2, 3, 4));
    });
  });
}
