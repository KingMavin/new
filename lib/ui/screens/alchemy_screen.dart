import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/alchemy_engine.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/voice_line.dart';
import 'package:immortal_path/ui/screens/settings_screen.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class AlchemyScreen extends StatefulWidget {
  final GameController controller;

  const AlchemyScreen({super.key, required this.controller});

  @override
  State<AlchemyScreen> createState() => _AlchemyScreenState();
}

class _AlchemyScreenState extends State<AlchemyScreen> {
  void _craft(AlchemyRecipe recipe) {
    final ok = widget.controller.craft(recipe.id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough materials.')),
      );
    }
  }

  void _usePill(String pillId) {
    final ok = switch (pillId) {
      'qi_pill' => widget.controller.useQiPill(),
      'breakthrough_pill' => widget.controller.useBreakthroughPill(),
      'lifespan_pill' => widget.controller.useLifespanPill(),
      _ => false,
    };
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have none of those.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        return BackdropScaffold(
          asset: BackdropCatalog.forScreen('alchemy'),

          appBar: AppBar(
            title: const Text('Alchemy'),
                    actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsScreen(controller: controller),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                VoiceLine.screen('alchemy'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _resource(
                            context, 'Stones', formatNumber(state.spiritStones)),
                        _resource(context, 'Herbs', '${state.spiritHerbs}'),
                        _resource(context, 'Cores', '${state.beastCores}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Recipes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final recipe in AlchemyEngine.recipes)
                  _RecipeCard(
                    recipe: recipe,
                    canCraft: AlchemyEngine.canCraft(state, recipe),
                    onCraft: () => _craft(recipe),
                  ),
                const SizedBox(height: 16),
                Text('Pills', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _PillCard(
                  name: 'Qi Gathering Pill',
                  count: state.qiPills,
                  description: 'Gain 2 minutes of cultivation instantly.',
                  onUse: () => _usePill('qi_pill'),
                ),
                _PillCard(
                  name: 'Foundation Pill',
                  count: state.breakthroughPills,
                  description:
                      '+20% chance on your next breakthrough (max +50%).',
                  onUse: () => _usePill('breakthrough_pill'),
                ),
                _PillCard(
                  name: 'Longevity Pill',
                  count: state.lifespanPills,
                  description: 'Permanently gain 25 years of lifespan.',
                  onUse: () => _usePill('lifespan_pill'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resource(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final AlchemyRecipe recipe;
  final bool canCraft;
  final VoidCallback onCraft;

  const _RecipeCard({
    required this.recipe,
    required this.canCraft,
    required this.onCraft,
  });

  @override
  Widget build(BuildContext context) {
    final costParts = <String>[
      if (recipe.herbCost > 0) '${recipe.herbCost} herbs',
      if (recipe.coreCost > 0) '${recipe.coreCost} cores',
      if (recipe.stoneCost > 0) '${formatNumber(recipe.stoneCost)} stones',
    ];
    return Card(
      child: ListTile(
        title: Text(recipe.name),
        subtitle: Text('${recipe.description}\nCost: ${costParts.join(', ')}'),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: canCraft ? onCraft : null,
          child: const Text('Brew'),
        ),
      ),
    );
  }
}

class _PillCard extends StatelessWidget {
  final String name;
  final int count;
  final String description;
  final VoidCallback onUse;

  const _PillCard({
    required this.name,
    required this.count,
    required this.description,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$name × $count'),
        subtitle: Text(description),
        trailing: FilledButton.tonal(
          onPressed: count > 0 ? onUse : null,
          child: const Text('Use'),
        ),
      ),
    );
  }
}
