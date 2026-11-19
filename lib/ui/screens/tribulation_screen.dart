import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/tribulation_engine.dart';
import 'package:immortal_path/game/models/narration.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/ui/theme/voice_line.dart';
import 'package:immortal_path/state/game_controller.dart';

class TribulationDialog extends StatelessWidget {
  final GameController controller;

  const TribulationDialog({super.key, required this.controller});

  void _face(BuildContext context, TribulationAction action) {
    final outcome = controller.faceTribulation(action);
    if (outcome == null) return;
    if (outcome.finished && context.mounted) {
      Navigator.of(context).pop();
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            outcome.success ? 'Tribulation Survived' : 'Tribulation Failed',
          ),
          content: Text(
            '${NarrationCatalog.caseLine(
              outcome.success ? 'tribulation_survived' : 'tribulation_failed',
              seed: controller.state.tribulationWavesCleared,
            )}\n\n${outcome.message}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final hpProgress =
            (state.tribulationHp / state.tribulationMaxHp)
                .clamp(0.0, 1.0)
                .toDouble();
        final channelCost = state.qi * 0.1;
        final deflectChance =
            ((0.5 + state.tribulationDeflectBonus).clamp(0.0, 0.9) * 100)
                .toStringAsFixed(0);
        return AlertDialog(
          title: const Text('Heavenly Tribulation'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 110,
                    width: double.maxFinite,
                    child: BackdropImage(
                      'assets/images/screen_tribulation.png',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                VoiceLine.screen('tribulation'),
                Text(
                  'Wave ${state.tribulationWavesCleared + 1} of '
                  '${state.tribulationWavesTotal}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: hpProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatNumber(state.tribulationHp)} / '
                  '${formatNumber(state.tribulationMaxHp)} tribulation health',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your qi: ${formatNumber(state.qi)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    child: Text(
                      state.tribulationLog.join('\n'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _face(context, TribulationAction.channel),
              child: Text('Channel (${formatNumber(channelCost)} qi)'),
            ),
            TextButton(
              onPressed: () => _face(context, TribulationAction.deflect),
              child: Text('Deflect ($deflectChance%)'),
            ),
            FilledButton(
              onPressed: () => _face(context, TribulationAction.withstand),
              child: const Text('Withstand'),
            ),
          ],
        );
      },
    );
  }
}
