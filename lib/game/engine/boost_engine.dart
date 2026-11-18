import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/monetization.dart';

class BoostEngine {
  static List<ActiveBoost> active(GameState state, DateTime now) =>
      state.boosts.where((boost) => boost.isActive(now)).toList();

  static double multiplierFor(
    GameState state,
    String kind, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    var multiplier = 1.0;
    for (final boost in active(state, at)) {
      if (boost.kind == kind) multiplier *= boost.multiplier;
    }
    return multiplier;
  }

  static GameState grantPlacement(
    GameState state,
    AdPlacement placement, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final stamp = {
      ...state.lastAdWatch,
      placement.id: at.toIso8601String(),
    };
    if (placement.kind == 'cooldown') {
      return state.copyWith(
        lastTournamentAt: null,
        lastWarAt: null,
        lastAdWatch: stamp,
      );
    }
    final boost = ActiveBoost(
      id: placement.id,
      kind: placement.kind,
      multiplier: placement.multiplier,
      expiresAt: at.add(placement.duration),
    );
    final others = state.boosts.where((b) => b.id != boost.id).toList();
    return state.copyWith(
      boosts: [...others, boost],
      lastAdWatch: stamp,
    );
  }

  static Duration remainingCooldown(
    GameState state,
    AdPlacement placement, {
    DateTime? now,
  }) {
    final raw = state.lastAdWatch[placement.id];
    if (raw == null) return Duration.zero;
    final last = DateTime.parse(raw);
    final at = now ?? DateTime.now();
    final remaining = placement.cooldown - at.difference(last);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static bool canWatch(
    GameState state,
    String placementId, {
    DateTime? now,
  }) {
    final placement = MonetizationCatalog.placementById(placementId);
    if (placement == null) return false;
    return remainingCooldown(state, placement, now: now) == Duration.zero;
  }
}
