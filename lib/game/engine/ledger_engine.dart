import 'dart:math';

import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/engine/journal_engine.dart';

class LedgerEngine {
  static const List<String> omens = [
    'The crane crosses the moon \u2014 fortune favors bold steps.',
    'Iron remembers every strike \u2014 persistence will be rewarded.',
    'A serpent sheds its skin \u2014 old burdens may be set down.',
    'The well does not scorn the small cup \u2014 steady sips run deep.',
    'Thunder sleeps in the bamboo \u2014 great force stirs in quiet places.',
    'Two rivers argue, the sea laughs \u2014 allies carry you farther.',
    'The lantern burns what feeds it \u2014 spend strength, not spirit.',
    'A path closed is a path withheld \u2014 the mountain tests before it yields.',
  ];

  static int dayOf(DateTime now) =>
      DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
      86400000;

  static bool canClaim(GameState state, {DateTime? now}) =>
      dayOf(now ?? DateTime.now()) != state.dailyLedgerClaimedOn;

  static String omenFor(int epochDay) => omens[epochDay % omens.length];

  static int stonesFor(int realmIndex) =>
      (150 * pow(1.8, realmIndex)).round();

  static GameState claim(GameState state, {DateTime? now}) {
    final at = now ?? DateTime.now();
    if (!canClaim(state, now: at)) return state;
    final day = dayOf(at);
    final omen = omenFor(day);
    final stones = stonesFor(state.realmIndex);
    final signed = state.copyWith(
      spiritStones: state.spiritStones + stones,
      qiPills: state.qiPills + 2,
      dailyLedgerClaimedOn: day,
    );
    return JournalEngine.record(
      signed,
      'Signed the sect ledger: $omen (+$stones stones, 2 qi pills)',
      now: at,
    );
  }
}
