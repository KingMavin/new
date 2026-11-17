import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/race.dart';

class RaceEngine {
  static Race? raceOf(GameState state) =>
      state.raceId == null ? null : Race.byId(state.raceId!);

  static double qiMultiplier(GameState state) =>
      state.raceId == 'human' ? 1.10 : 1.0;

  static double attackMultiplier(GameState state) =>
      state.raceId == 'demon' ? 1.15 : 1.0;

  static double hpMultiplier(GameState state) =>
      state.raceId == 'demon' ? 1.10 : 1.0;

  static double defenseMultiplier(GameState state) =>
      state.raceId == 'demi_human' ? 1.15 : 1.0;

  static double stoneMultiplier(GameState state) =>
      state.raceId == 'demi_human' ? 1.10 : 1.0;
}
