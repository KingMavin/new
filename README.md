# Immortal Path

A single-player idle cultivation RPG inspired by xianxia mythology, built with Flutter.

## Current MVP (Phase 1)

- Qi accumulation over time (idle) plus an active "Circulate Qi" action
- Nine-realm ladder (Qi Refining → Ascension) with Early/Middle/Late/Peak sub-stages
- Breakthrough attempts with success chances; failures cost 25% of current qi
- Major-realm breakthroughs as tribulation gates
- Offline progress (capped at 24h) with a "While you were in seclusion" report
- Autosave every 30s and on app pause, persisted via shared_preferences
- Lifespan display per realm and an ascension ending

## Getting started

This repository contains the Dart/Flutter sources. Generate the platform
folders once, then run:

```bash
flutter create --project-name immortal_path --platforms=android,ios,web .
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

## Architecture

```
lib/
  game/
    models/       Realm ladder and immutable GameState (JSON-serializable)
    engine/       Pure simulation logic: qi rates, breakthroughs, offline calc
    persistence/  SaveRepository interface + shared_preferences implementation
    util/         Number and duration formatting
  state/          GameController (ChangeNotifier): tick loop, autosave, lifecycle
  ui/             Material 3 interface
```

The simulation is pure Dart with delta-time computation, so all gains derive
from elapsed time. This keeps online ticks, background pauses, and offline
progress consistent and unit-testable.

## Roadmap

1. Phase 2 — combat zones, loot tiers, alchemy/pills, away reports for events
2. Phase 3 — sect, disciples, spirit beast companion, tribulation mini-events
3. Phase 4 — reincarnation/prestige, random encounter events, codex
4. Phase 5 — Flame animations, audio, local notifications, balance pass
