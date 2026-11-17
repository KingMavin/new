import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/encounter_engine.dart';
import 'package:immortal_path/game/models/world_location.dart';

class LocationTheme {
  final List<Color> gradient;
  final IconData icon;

  const LocationTheme({required this.gradient, required this.icon});
}

const _regionThemes = <String, LocationTheme>{
  'bamboo_forest': LocationTheme(
    gradient: [Color(0xFF1B5E20), Color(0xFF81C784)],
    icon: Icons.park,
  ),
  'misty_mountains': LocationTheme(
    gradient: [Color(0xFF37474F), Color(0xFF90A4AE)],
    icon: Icons.landscape,
  ),
  'lotus_lake': LocationTheme(
    gradient: [Color(0xFF01579B), Color(0xFF4FC3F7)],
    icon: Icons.water,
  ),
  'ember_valley': LocationTheme(
    gradient: [Color(0xFFBF360C), Color(0xFFFF8A65)],
    icon: Icons.local_fire_department,
  ),
  'serpent_peak': LocationTheme(
    gradient: [Color(0xFF263238), Color(0xFFB3E5FC)],
    icon: Icons.ac_unit,
  ),
  'beast_wasteland': LocationTheme(
    gradient: [Color(0xFF5D4037), Color(0xFFFFD54F)],
    icon: Icons.terrain,
  ),
  'sword_tomb': LocationTheme(
    gradient: [Color(0xFF263238), Color(0xFF78909C)],
    icon: Icons.colorize,
  ),
  'hells_gorge': LocationTheme(
    gradient: [Color(0xFF4A148C), Color(0xFFFF5252)],
    icon: Icons.bolt,
  ),
  'heavenly_gate': LocationTheme(
    gradient: [Color(0xFFB8860B), Color(0xFFFFF59D)],
    icon: Icons.auto_awesome,
  ),
  'fallen_zhao': LocationTheme(
    gradient: [Color(0xFF3E2723), Color(0xFF8D6E63)],
    icon: Icons.location_city,
  ),
  'fallen_yan': LocationTheme(
    gradient: [Color(0xFF212121), Color(0xFFA1887F)],
    icon: Icons.location_city,
  ),
  'bone_pits': LocationTheme(
    gradient: [Color(0xFF1A1A1A), Color(0xFFB71C1C)],
    icon: Icons.dangerous,
  ),
  'void_rift': LocationTheme(
    gradient: [Color(0xFF0D0D26), Color(0xFF7C4DFF)],
    icon: Icons.dangerous,
  ),
  'sword_vault': LocationTheme(
    gradient: [Color(0xFF004D40), Color(0xFF64FFDA)],
    icon: Icons.visibility_off,
  ),
  'immortal_grotto': LocationTheme(
    gradient: [Color(0xFF33691E), Color(0xFFFFB74D)],
    icon: Icons.visibility_off,
  ),
};

const _fallbackTheme = LocationTheme(
  gradient: [Color(0xFF311B92), Color(0xFF7C4DFF)],
  icon: Icons.map,
);

LocationTheme themeFor(WorldLocation location) =>
    _regionThemes[location.id] ?? _fallbackTheme;

const _tournamentTheme = LocationTheme(
  gradient: [Color(0xFF4E342E), Color(0xFFFFD54F)],
  icon: Icons.emoji_events,
);

const _warTheme = LocationTheme(
  gradient: [Color(0xFF7F1D1D), Color(0xFFFF8A80)],
  icon: Icons.local_fire_department,
);

LocationTheme themeForEncounter(EncounterKind kind, WorldLocation? location) {
  switch (kind) {
    case EncounterKind.tournament:
      return _tournamentTheme;
    case EncounterKind.war:
      return _warTheme;
    case EncounterKind.hunt:
      return location == null ? _fallbackTheme : themeFor(location);
  }
}

String encounterTitle(EncounterKind kind, WorldLocation? location) {
  switch (kind) {
    case EncounterKind.tournament:
      return 'Sect Tournament';
    case EncounterKind.war:
      return 'War Front';
    case EncounterKind.hunt:
      return location?.name ?? 'The Wilds';
  }
}
