import 'dart:math';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

class WarEngine {
  static const Duration cooldown = Duration(hours: 4);
  static const int requiredRealm = 2;

  static const List<String> _championNames = [
    'Demon Marshal Xue Mo',
    'Warlord Kang of the Broken Fang',
    'General Rao of the Iron Legion',
    'Blood Prince Yan Kuang',
  ];

  static double playerSideStrength(GameState state) {
    final discipleStrength = state.disciples.fold<int>(
      0,
      (sum, disciple) => sum + disciple.level * 5,
    );
    final sectStrength = state.sectId == null
        ? 0
        : (SectEngine.rankOf(state.contribution) + 1) * 20;
    return CombatEngine.playerAttack(state) +
        CombatEngine.playerDefense(state) +
        CombatEngine.playerMaxHp(state) / 10.0 +
        discipleStrength +
        sectStrength;
  }

  static double enemyStrength(GameState state, {Random? rng}) {
    final random = rng ?? Random();
    return playerSideStrength(state) * (0.7 + random.nextDouble() * 0.6);
  }

  static Beast champion(GameState state, {Random? rng}) {
    final random = rng ?? Random();
    final strength = enemyStrength(state, rng: random);
    final name = _championNames[random.nextInt(_championNames.length)];
    return Beast(
      name: name,
      hp: strength * 1.5,
      attack: strength * 0.3,
      defense: strength * 0.1,
      bonusType: 'attack',
    );
  }

  static String frontDescription(GameState state) {
    final yours = playerSideStrength(state);
    final enemy = enemyStrength(state);
    final balance = yours >= enemy
        ? 'Your banners outnumber theirs \u2014 the ranks believe.'
        : 'Their war drums outnumber your banners \u2014 the ranks whisper.';
    return 'The border between the Verdant Empire and the Ash Wastes has '
        'ignited. Your sect answers the call to arms.\n\n'
        'Your side\u2019s strength: ${yours.toStringAsFixed(0)}\n'
        'Enemy strength: ${enemy.toStringAsFixed(0)}\n\n'
        '$balance';
  }

  static double prizeStones(GameState state) =>
      200.0 * pow(2.0, state.realmIndex);

  static int prizeContribution(GameState state) => 100 + 25 * state.realmIndex;

  static String victoryText(GameState state) =>
      'Their champion falls and their line breaks. The war horns sound '
      'retreat across the Ash Wastes \u2014 the border holds, and your '
      'name travels home with the survivors.';

  static const String defeatText =
      'The line collapses around you. You carve your way out of the '
      'encirclement, but the border burns behind you as you retreat.';
}
