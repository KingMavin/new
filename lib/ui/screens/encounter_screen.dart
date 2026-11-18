import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/encounter_engine.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/location_theme.dart';

class EncounterScreen extends StatefulWidget {
  final GameController controller;
  final WorldLocation? location;

  const EncounterScreen({
    super.key,
    required this.controller,
    required this.location,
  });

  @override
  State<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends State<EncounterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.encounter == null) {
        widget.controller.startEncounter();
      }
    });
  }

  void _advance() => setState(() => widget.controller.advanceEncounter());

  void _choose(int index) =>
      setState(() => widget.controller.chooseEncounterOption(index));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final encounter = widget.controller.encounter;
        if (encounter == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final kind = widget.controller.encounterKind;
        final theme = themeForEncounter(kind, widget.location);
        final moment = encounter.pendingMoment;
        return Dialog.fullscreen(
          child: Column(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.gradient,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropImage(
                        encounterAsset(kind, widget.location),
                        scrim: const [Color(0x22000000), Color(0x66000000)],
                      ),
                    ),
                    Center(
                      child: Icon(
                        theme.icon,
                        size: 120,
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              onPressed: () {
                                widget.controller.clearEncounter();
                                Navigator.of(context).pop();
                              },
                            ),
                            Expanded(
                              child: Text(
                                encounterTitle(kind, widget.location),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    _HpBar(
                      label: 'You',
                      fraction: encounter.playerHpFraction,
                      color: Theme.of(context).colorScheme.primary,
                      value:
                          '${encounter.playerHp.toStringAsFixed(0)} / '
                          '${encounter.playerMaxHp.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    _HpBar(
                      label: encounter.beast.name,
                      fraction: encounter.foeHpFraction,
                      color: Theme.of(context).colorScheme.error,
                      value:
                          '${encounter.foeHp.toStringAsFixed(0)} / '
                          '${encounter.foeMaxHp.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),
              if (moment != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moment.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(moment.text),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        for (final line in encounter.log)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              line,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ActionArea(
                    encounter: encounter,
                    onAdvance: _advance,
                    onChoose: _choose,
                    onFinish: () {
                      widget.controller.clearEncounter();
                      Navigator.of(context).pop();
                    },
                    summary: widget.controller.lastEncounterSummary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionArea extends StatelessWidget {
  final EncounterState encounter;
  final VoidCallback onAdvance;
  final void Function(int) onChoose;
  final VoidCallback onFinish;
  final String? summary;

  const _ActionArea({
    required this.encounter,
    required this.onAdvance,
    required this.onChoose,
    required this.onFinish,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    if (encounter.finished) {
      final outcome = encounter.victory
          ? 'Victory!'
          : encounter.fled
              ? 'You fled.'
              : 'Defeat.';
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            outcome,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (summary != null) ...[
            const SizedBox(height: 8),
            Text(summary!),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onFinish,
            child: const Text('Leave the field'),
          ),
        ],
      );
    }
    final moment = encounter.pendingMoment;
    if (moment != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < moment.choices.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.tonal(
                onPressed: () => onChoose(i),
                child: Text(moment.choices[i].label),
              ),
            ),
        ],
      );
    }
    return FilledButton.icon(
      onPressed: onAdvance,
      icon: const Icon(Icons.flash_on),
      label: const Text('Continue the fight'),
    );
  }
}

class _HpBar extends StatelessWidget {
  final String label;
  final double fraction;
  final Color color;
  final String value;

  const _HpBar({
    required this.label,
    required this.fraction,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
