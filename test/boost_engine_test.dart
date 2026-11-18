import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/boost_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/monetization.dart';

final DateTime now = DateTime(2025, 1, 1, 12);

void main() {
  group('MonetizationCatalog', () {
    test('placement and product ids are unique', () {
      final placementIds = MonetizationCatalog.adPlacements
          .map((placement) => placement.id)
          .toList();
      final productIds =
          MonetizationCatalog.products.map((product) => product.id).toList();
      expect(placementIds.toSet().length, placementIds.length);
      expect(productIds.toSet().length, productIds.length);
    });

    test('ads grant timed boons, never permanent power', () {
      for (final placement in MonetizationCatalog.adPlacements) {
        expect(placement.multiplier, lessThanOrEqualTo(2.0));
        expect(placement.duration, lessThanOrEqualTo(const Duration(hours: 8)));
        expect(placement.cooldown, greaterThan(Duration.zero));
      }
    });

    test('store sells only known product kinds', () {
      for (final product in MonetizationCatalog.products) {
        expect(
          StoreProduct.kinds.contains(product.kind),
          isTrue,
          reason: '${product.id} has unknown kind ${product.kind}',
        );
      }
    });
  });

  group('BoostEngine', () {
    final incense = MonetizationCatalog.placementById('qi_incense')!;
    final favor = MonetizationCatalog.placementById('stone_favor')!;
    final pigeon = MonetizationCatalog.placementById('cooldown_pigeon')!;

    test('no boosts means every multiplier is 1.0', () {
      final state = GameState.initial();
      expect(BoostEngine.multiplierFor(state, 'qi', now: now), 1.0);
      expect(BoostEngine.multiplierFor(state, 'stones', now: now), 1.0);
      expect(BoostEngine.multiplierFor(state, 'attack', now: now), 1.0);
      expect(BoostEngine.active(state, now), isEmpty);
    });

    test('active boosts multiply only their own kind', () {
      final state = BoostEngine.grantPlacement(
        BoostEngine.grantPlacement(
          GameState.initial(),
          incense,
          now: now,
        ),
        favor,
        now: now,
      );
      expect(BoostEngine.multiplierFor(state, 'qi', now: now), 2.0);
      expect(BoostEngine.multiplierFor(state, 'stones', now: now), 1.5);
      expect(BoostEngine.multiplierFor(state, 'attack', now: now), 1.0);
    });

    test('boosts expire at their expiry', () {
      final state =
          BoostEngine.grantPlacement(GameState.initial(), incense, now: now);
      expect(
        BoostEngine.multiplierFor(state, 'qi', now: now.add(const Duration(hours: 8))),
        2.0,
      );
      final after = now.add(const Duration(hours: 8).add(const Duration(seconds: 1)));
      expect(BoostEngine.multiplierFor(state, 'qi', now: after), 1.0);
      expect(BoostEngine.active(state, now.add(const Duration(hours: 8).add(const Duration(seconds: 1)))), isEmpty);
    });

    test('rewatching replaces the same boost instead of stacking', () {
      final first = BoostEngine.grantPlacement(GameState.initial(), incense, now: now);
      final second = BoostEngine.grantPlacement(first, incense, now: now.add(const Duration(hours: 1)));
      expect(second.boosts.length, 1);
      expect(second.boosts.single.expiresAt, now.add(const Duration(hours: 9)));
    });

    test('cooldowns gate rewatches per placement', () {
      final state =
          BoostEngine.grantPlacement(GameState.initial(), incense, now: now);
      expect(BoostEngine.canWatch(state, 'qi_incense', now: now), isFalse);
      expect(
        BoostEngine.canWatch(
          state,
          'qi_incense',
          now: now.add(incense.cooldown),
        ),
        isTrue,
      );
      expect(BoostEngine.canWatch(state, 'stone_favor', now: now), isTrue);
      expect(
        BoostEngine.remainingCooldown(state, incense, now: now),
        incense.cooldown,
      );
    });

    test('the duel pigeon clears tournament and war cooldowns', () {
      final state = GameState.initial().copyWith(
        lastTournamentAt: now.subtract(const Duration(minutes: 10)),
        lastWarAt: now.subtract(const Duration(hours: 1)),
      );
      final cleared = BoostEngine.grantPlacement(state, pigeon, now: now);
      expect(cleared.lastTournamentAt, isNull);
      expect(cleared.lastWarAt, isNull);
      expect(
        BoostEngine.remainingCooldown(cleared, pigeon, now: now),
        pigeon.cooldown,
      );
      expect(BoostEngine.multiplierFor(cleared, 'qi', now: now), 1.0);
    });

    test('patron, themes, boosts and ad stamps survive reincarnation', () {
      final state = BoostEngine.grantPlacement(
        GameState.initial().copyWith(
          ascended: true,
          supportTier: true,
          ownedCosmetics: const ['theme_ember'],
          activeThemeId: 'theme_ember',
        ),
        incense,
        now: now,
      );
      final reincarnated = SoulEngine.reincarnate(state);
      expect(reincarnated.boosts, state.boosts);
      expect(reincarnated.supportTier, isTrue);
      expect(reincarnated.ownedCosmetics, ['theme_ember']);
      expect(reincarnated.activeThemeId, 'theme_ember');
      expect(reincarnated.lastAdWatch, state.lastAdWatch);
    });
  });
}
