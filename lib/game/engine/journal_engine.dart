import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/journal.dart';

class JournalEngine {
  static const int cap = 60;

  static GameState record(GameState state, String text, {DateTime? now}) {
    final entry = JournalEntry(time: now ?? DateTime.now(), text: text);
    final journal = [entry, ...state.journal];
    return state.copyWith(
      journal: journal.length > cap ? journal.sublist(0, cap) : journal,
    );
  }
}
