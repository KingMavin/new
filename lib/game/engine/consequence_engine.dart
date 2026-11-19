import 'package:immortal_path/game/models/consequence.dart';
import 'package:immortal_path/game/models/game_state.dart';

class ConsequenceEngine {
  static bool has(GameState state, String id) =>
      state.consequences.contains(id);

  static double _fold(
    GameState state,
    double Function(GameConsequence) pick,
  ) {
    var out = 1.0;
    for (final id in state.consequences) {
      final consequence = ConsequenceCatalog.byId(id);
      if (consequence != null) out *= pick(consequence);
    }
    return out;
  }

  static double attackFactor(GameState state) =>
      _fold(state, (c) => c.attackMul);

  static double defenseFactor(GameState state) =>
      _fold(state, (c) => c.defenseMul);

  static double hpFactor(GameState state) => _fold(state, (c) => c.hpMul);

  static double qiFactor(GameState state) => _fold(state, (c) => c.qiMul);

  static double stonesFactor(GameState state) =>
      _fold(state, (c) => c.stonesMul);

  static int count(GameState state) => state.consequences.length;

  static GameConsequence? byId(String id) => ConsequenceCatalog.byId(id);

  static GameState? grant(
    GameState state,
    String id,
    List<String> journalLines,
  ) {
    if (has(state, id)) return null;
    final consequence = ConsequenceCatalog.byId(id);
    if (consequence == null) return null;
    journalLines.add(
      consequence.boon
          ? 'Mark earned \u2014 ${consequence.title}: ${consequence.description}'
          : 'Mark scarred \u2014 ${consequence.title}: ${consequence.description}',
    );
    return state.copyWith(
      consequences: [...state.consequences, consequence.id],
    );
  }
}
