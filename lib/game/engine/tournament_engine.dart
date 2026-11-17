import 'dart:math';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

class TournamentEngine {
  static const Duration cooldown = Duration(hours: 1);

  static const List<String> _opponentNames = [
    'Wu Jian of the Storm Blade Hall',
    'Qing Lian of the Jade Lotus Pavilion',
    'Bai Hu of the White Tiger Dojo',
    'Shen Kuo of the Nine Stars Sect',
    'Yan Zhu of the Crimson Banner',
    'Mo Ling of the Silent Cloud Temple',
  ];

  static double playerTournamentPower(GameState state) =>
      CombatEngine.playerAttack(state) +
      CombatEngine.playerDefense(state) +
      CombatEngine.playerMaxHp(state) / 10.0;

  static Beast opponent(GameState state, {Random? rng}) {
    final random = rng ?? Random();
    final power = playerTournamentPower(state) * (0.75 + random.nextDouble() * 0.5);
    final name = _opponentNames[random.nextInt(_opponentNames.length)];
    return Beast(
      name: name,
      hp: power * 1.2,
      attack: power * 0.35,
      defense: power * 0.12,
      bonusType: 'attack',
    );
  }

  static double prizeStones(GameState state) => 50.0 * pow(2.0, state.realmIndex);

  static int prizeContribution(GameState state) => 30 + 10 * state.realmIndex;

  static String victoryText(GameState state) =>
      'The referee raises his hand. The crowd roars as you are named '
      'victor of the bout \u2014 your sect\u2019s banner flies a little '
      'prouder tonight.';

  static const String defeatText =
      'Your opponent\u2019s final strike lands clean. You bow, defeated '
      'but not disgraced \u2014 the elders note your form regardless.';
}
