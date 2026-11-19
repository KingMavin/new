import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/store_screen.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class SettingsScreen extends StatefulWidget {
  final GameController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      asset: BackdropCatalog.forScreen('settings'),

      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Save Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Copy your save to move it to another device, or paste a save '
            'over this one. Importing replaces your current progress \u2014 '
            'the game cannot undo it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Export save'),
              subtitle: const Text(
                'Copy the raw save as text to clipboard or view it.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _exportSave,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import save'),
              subtitle: const Text(
                'Paste a previously exported save to restore it.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _importSave,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sound',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) => Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.music_note),
                title: const Text('Sound'),
                subtitle: const Text(
                  'Ambient music follows your journey \u2014 quiet '
                  'cultivation, windswept exploration, tournament drums, '
                  'war horns. Effects mark breakthroughs, battles and '
                  'blessings.',
                ),
                value: widget.controller.state.audioOn,
                onChanged: (_) => widget.controller.toggleAudio(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Temple of Support',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text('Blessings & Patron themes'),
              subtitle: const Text(
                'Opt-in ads that grant timed boons, and cosmetic themes '
                'that never touch the ladder.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoreScreen(controller: widget.controller),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Erase and restart'),
              subtitle: const Text(
                'Wipe everything: realms, reputation, powers and legend. '
                'No tribulation can bring this back.',
              ),
              onTap: _confirmReset,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.self_improvement),
              title: Text('Immortal Path'),
              subtitle: Text(
                'A single-player idle cultivation RPG. Nine realms, three '
                'peoples, three paths, six endings. The wheel turns.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Version 0.16.1 \u2014 the mortal becomes immortal',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _exportSave() {
    final json = widget.controller.exportSaveJson();
    final exportController = TextEditingController(text: json);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your save'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  controller: exportController,
                  readOnly: true,
                  maxLines: null,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Save copied to clipboard.')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _importSave() {
    final importController = TextEditingController();
    String? error;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Import save'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: importController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Paste your exported save here',
                  border: OutlineInputBorder(),
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final ok = widget.controller
                    .importSaveJson(importController.text);
                if (ok) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Save imported.')),
                  );
                } else {
                  setDialogState(() => error = 'That is not a valid save.');
                }
              },
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Erase everything?'),
        content: const Text(
          'Your cultivation, reputation, powers, legend and every ending '
          'will be wiped. The mortal world will not remember you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep my path'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              widget.controller.resetGame();
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Erase'),
          ),
        ],
      ),
    );
  }
}
