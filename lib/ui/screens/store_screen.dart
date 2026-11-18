import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/boost_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/monetization.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';

class StoreScreen extends StatefulWidget {
  final GameController controller;

  const StoreScreen({super.key, required this.controller});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Temple of Support'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!widget.controller.monetizationConfigured)
                Card(
                  child: const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Store not connected'),
                    subtitle: Text(
                      'AdMob and billing are not configured yet, so every '
                      'blessing and offering below completes instantly in '
                      'this build. Nothing is charged.',
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Blessings \u00b7 opt-in ads',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Watch a short scroll (an ad) and the temple grants a timed '
                'boon. Always optional \u2014 never required to progress.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final placement in MonetizationCatalog.adPlacements)
                _PlacementCard(
                  state: state,
                  placement: placement,
                  busy: _busyId == placement.id,
                  remaining: BoostEngine.remainingCooldown(state, placement),
                  onWatch: () => _watch(placement),
                ),
              const SizedBox(height: 16),
              Text(
                'Support & Scrolls',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Coin buys identity and comfort, never power. The ladder, '
                'loot and tribulations stay honest for everyone.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final product in MonetizationCatalog.products)
                _ProductCard(
                  state: state,
                  product: product,
                  busy: _busyId == product.id,
                  onPurchase: () => _purchase(product),
                  onSelectTheme: () =>
                      widget.controller.chooseTheme(product.id),
                ),
              if (state.supportTier) ...[
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium),
                    title: Text(
                      '${state.legacyName ?? 'Immortal'} \u00b7 Patron of the Temple',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Your name wears gold in your legend, and the '
                      'Celestial Gold theme is yours.',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _watch(AdPlacement placement) async {
    setState(() => _busyId = placement.id);
    final ok = await widget.controller.watchAdFor(placement.id);
    if (!mounted) return;
    setState(() => _busyId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${placement.title}: ${placement.rewardText}'
              : 'That blessing is still gathering strength.',
        ),
      ),
    );
  }

  Future<void> _purchase(StoreProduct product) async {
    setState(() => _busyId = product.id);
    final ok = await widget.controller.purchaseProduct(product.id);
    if (!mounted) return;
    setState(() => _busyId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${product.title} is yours. The temple bows.'
              : 'That offering could not be completed.',
        ),
      ),
    );
  }
}

class _PlacementCard extends StatelessWidget {
  final GameState state;
  final AdPlacement placement;
  final bool busy;
  final Duration remaining;
  final VoidCallback onWatch;

  const _PlacementCard({
    required this.state,
    required this.placement,
    required this.busy,
    required this.remaining,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    if (placement.kind != 'cooldown') {
      final mine = state.boosts
          .where((boost) => boost.id == placement.id && boost.isActive(DateTime.now()))
          .toList();
      if (mine.isNotEmpty) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: Text(placement.title),
            subtitle: Text(
              'Burning \u2014 ${formatDuration(
                mine.first.expiresAt.difference(DateTime.now()),
              )} remaining. ${placement.rewardText}.',
            ),
            trailing: const Chip(label: Text('Active')),
          ),
        );
      }
    }
    return Card(
      child: ListTile(
        leading: Icon(
          placement.kind == 'qi'
              ? Icons.bolt
              : placement.kind == 'stones'
                  ? Icons.diamond
                  : Icons.alternate_email,
        ),
        isThreeLine: true,
        title: Text(placement.title),
        subtitle: Text('${placement.description}\n${placement.rewardText}'),
        trailing: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton.tonal(
                onPressed:
                    remaining == Duration.zero ? onWatch : null,
                child: Text(
                  remaining == Duration.zero
                      ? 'Watch'
                      : formatDuration(remaining),
                ),
              ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final GameState state;
  final StoreProduct product;
  final bool busy;
  final VoidCallback onPurchase;
  final VoidCallback onSelectTheme;

  const _ProductCard({
    required this.state,
    required this.product,
    required this.busy,
    required this.onPurchase,
    required this.onSelectTheme,
  });

  @override
  Widget build(BuildContext context) {
    final owned = product.id == 'immortal_patron'
        ? state.supportTier
        : state.ownedCosmetics.contains(product.id);
    final selected = state.activeThemeId == product.id;
    return Card(
      child: ListTile(
        leading: Icon(
          product.kind == 'support'
              ? Icons.workspace_premium
              : Icons.palette,
          color:
              owned && selected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          product.title,
          style: product.id == 'immortal_patron' && owned
              ? const TextStyle(color: Colors.amber)
              : null,
        ),
        isThreeLine: true,
        subtitle: Text('${product.description}\n${product.priceLabel}'),
        trailing: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : owned
                ? (product.kind == 'theme'
                    ? FilledButton.tonal(
                        onPressed: selected ? null : onSelectTheme,
                        child: Text(selected ? 'Worn' : 'Wear'),
                      )
                    : const Chip(label: Text('Patron')))
                : FilledButton(
                    onPressed: onPurchase,
                    child: Text(product.priceLabel),
                  ),
      ),
    );
  }
}
