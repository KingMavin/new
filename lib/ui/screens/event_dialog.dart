import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class EventDialog extends StatelessWidget {
  final GameController controller;
  final String eventId;

  const EventDialog({
    super.key,
    required this.controller,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final event = EventEngine.byId(eventId);
    if (event == null) return const SizedBox.shrink();
    return Dialog.fullscreen(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: BackdropImage(
                  BackdropCatalog.forEvent(event.id),
                  scrim: const [Color(0x22000000), Color(0xAA000000)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(event.description),
                const SizedBox(height: 8),
                Text(
                  'What do you do?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < event.choices.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => _choose(context, i),
                      child: Text(event.choices[i].label),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _choose(BuildContext context, int index) {
    final outcome = controller.resolvePendingEvent(index);
    final message = outcome?.message;
    Navigator.of(context).pop();
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
