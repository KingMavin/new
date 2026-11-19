import 'package:flutter/material.dart';

import 'package:immortal_path/game/models/narration.dart';

class VoiceLine extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final EdgeInsets padding;

  const VoiceLine(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  factory VoiceLine.screen(String screen, {int? seed}) =>
      VoiceLine(NarrationCatalog.screenLine(screen, seed: seed));

  factory VoiceLine.caseOf(String key, {int? seed}) =>
      VoiceLine(NarrationCatalog.caseLine(key, seed: seed));

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
