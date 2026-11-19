import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/monetization.dart';
import 'package:immortal_path/game/models/narration.dart';
import 'package:immortal_path/game/models/sect_store.dart';
import 'package:immortal_path/game/models/sect.dart';
import 'package:immortal_path/game/models/forge.dart';
import 'package:immortal_path/game/engine/forge_engine.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/voice_line.dart';
import 'package:immortal_path/ui/screens/store_screen.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class SectStoreScreen extends StatelessWidget {
  final GameController controller;

  const SectStoreScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final sect = state.sectId == null ? null : Sect.byId(state.sectId!);
        return BackdropScaffold(
          asset: BackdropCatalog.forScreen('sect'),

          appBar: AppBar(
            title: const Text('Sect Armory'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              VoiceLine.screen('sect_store'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: Text(
                    sect == null
                        ? 'No sect'
                        : '${sect.name} storeroom',
                  ),
                  subtitle: Text(
                    'Your rank: ${SectEngine.rankName(state.contribution)} '
                    '\u00b7 ${formatNumber(state.spiritStones.toDouble())} '
                    'spirit stones',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Armory \u00b7 spirit stones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Forged by sect hands for sect hands. Gear is made for the '
                'realm you stand in; costs rise with it.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final item in SectStoreCatalog.items)
                _SectItemCard(
                  state: state,
                  item: item,
                  blocker: controller.sectItemBlocker(item.id),
                  cost: controller.sectItemCost(item.id),
                  onBuy: () => _buy(context, item),
                ),
              const SizedBox(height: 16),
              Text(
                'Forge \u00b7 gamble the flames',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Feed the sect forge stones, herbs, and cores. Success is '
                'never certain \u2014 a failed forging salvages only part of '
                'the stones.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final recipe in ForgeCatalog.recipes)
                _ForgeCard(
                  state: state,
                  recipe: recipe,
                  onForge: () => _forge(context, recipe),
                ),
              const SizedBox(height: 16),
              Text(
                'Offerings \u00b7 real coin',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Ancestral heirlooms and hours of stillness, bought at the '
                'Temple of Support and delivered here as well.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final product in MonetizationCatalog.products)
                if (product.kind == 'gear' || product.kind == 'offline')
                  ProductCard(
                    state: state,
                    product: product,
                    busy: false,
                    onPurchase: () => _purchase(context, product),
                    onSelectTheme: () => controller.chooseTheme(product.id),
                  ),
            ],
          ),
        );
      },
    );
  }

  void _buy(BuildContext context, SectStoreItem item) {
    final blocker = controller.sectItemBlocker(item.id);
    if (blocker != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(blocker)),
      );
      return;
    }
    final ok = controller.buySectItem(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${item.name} is issued to you by the storeroom.'
              : 'The storeroom refuses the trade.',
        ),
      ),
    );
  }

  void _forge(BuildContext context, ForgeRecipe recipe) {
    final outcome = controller.attemptForge(recipe.id);
    final voice = NarrationCatalog.caseLine(
      outcome?.success ?? false ? 'forge_success' : 'forge_failure',
      seed: outcome?.message.length ?? 0,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${voice}\n\n'
          '${outcome?.message ?? 'The forge does not accept the offering.'}',
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, StoreProduct product) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await controller.purchaseProduct(product.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${product.title} is yours. The sect bows.'
              : 'That offering could not be completed.',
        ),
      ),
    );
  }
}

class _SectItemCard extends StatelessWidget {
  final GameState state;
  final SectStoreItem item;
  final String? blocker;
  final double cost;
  final VoidCallback onBuy;

  const _SectItemCard({
    required this.state,
    required this.item,
    required this.blocker,
    required this.cost,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          item.slot == EquipmentSlot.weapon
              ? Icons.colorize
              : item.slot == EquipmentSlot.armor
                  ? Icons.shield
                  : Icons.auto_awesome,
        ),
        isThreeLine: true,
        title: Text(item.name),
        subtitle: Text(
          '${item.description}\n'
          '${item.grade == 1 ? 'Spirit' : 'Earth'} grade '
          '\u00b7 needs ${SectEngine.rankNames[item.minRank]}',
        ),
        trailing: FilledButton.tonal(
          onPressed: blocker == null ? onBuy : null,
          child: Text('${formatNumber(cost)} stones'),
        ),
      ),
    );
  }
}

class _ForgeCard extends StatelessWidget {
  final GameState state;
  final ForgeRecipe recipe;
  final VoidCallback onForge;

  const _ForgeCard({
    required this.state,
    required this.recipe,
    required this.onForge,
  });

  @override
  Widget build(BuildContext context) {
    final stones = recipe.stoneCostFor(state.realmIndex);
    final blocker = ForgeEngine.blocker(state, recipe);
    final gradeLabel =
        recipe.grade == 2 ? 'Earth' : recipe.grade == 3 ? 'Heaven' : 'Immortal';
    final slotLabel = recipe.slot == EquipmentSlot.weapon
        ? 'Weapon'
        : recipe.slot == EquipmentSlot.armor
            ? 'Armor'
            : 'Amulet';
    return Card(
      child: ListTile(
        leading: Icon(
          recipe.slot == EquipmentSlot.weapon
              ? Icons.colorize
              : recipe.slot == EquipmentSlot.armor
                  ? Icons.shield
                  : Icons.auto_awesome,
        ),
        isThreeLine: true,
        title: Text('Forge $slotLabel \u00b7 $gradeLabel'),
        subtitle: Text(
          'Needs ${formatNumber(stones.toDouble())} stones, '
          '${recipe.herbCost} herbs, ${recipe.coreCost} cores \u00b7 '
          '${(recipe.successChance * 100).toStringAsFixed(0)}% success',
        ),
        trailing: blocker == null
            ? FilledButton(onPressed: onForge, child: const Text('Forge'))
            : FilledButton.tonal(
                onPressed: null,
                child: Text('Missing materials')),
      ),
    );
  }
}
