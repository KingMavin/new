# Immortal Path

A single-player idle cultivation RPG inspired by xianxia mythology, built with Flutter.

## Phase 1 — Cultivation core

- Qi accumulation over time (idle) plus an active "Circulate Qi" action
- Nine-realm ladder (Qi Refining → Ascension) with Early/Middle/Late/Peak sub-stages
- Breakthrough attempts with success chances; failures cost 25% of current qi
- Major-realm breakthroughs as tribulation gates
- Offline progress (capped at 24h) with a "While you were in seclusion" report
- Autosave every 30s and on app pause, persisted via shared_preferences
- Lifespan display per realm and an ascension ending

## Phase 3 — Tribulations, techniques & companions

- Major-realm breakthroughs are now interactive heavenly tribulations: 3–9 lightning waves with three tactics — Withstand (full damage), Deflect (chance-based, boosted by breakthrough pills), Channel (spend qi for 60% damage reduction)
- Failing a tribulation scatters your qi; surviving advances the realm, and the final realm's tribulation grants ascension
- Six cultivation techniques with real tradeoffs (Flame Meridian Art, Iron Body Sutra, Sword Heart Sutra, Mystic Formation Art, Thunder Refining Sutra) — found as rare scrolls in zones
- Spirit beast companions: 8% tame chance on victories, qi- or attack-type bonuses, fed with beast cores up to level 10

## Phase 2 — Combat & alchemy

- Nine adventure zones gated by cultivation realm, each with themed beasts
- Auto-battle simulation with round-by-round combat log (seeded, deterministic in tests)
- Loot: spirit stones, spirit herbs, beast cores, and equipment drops
- Five equipment grades (Mortal → Immortal) for weapon and armor slots; stronger drops auto-equip, weaker ones sell for spirit stones
- Alchemy: brew Qi Gathering, Foundation (+breakthrough chance), and Longevity pills from herbs, cores, and stones
- Three-tab interface: Cultivate, Adventure, Alchemy

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

1. Phase 4 — reincarnation/prestige, sects and disciples, random encounter events, codex
2. Phase 5 — Flame animations, audio, local notifications, balance pass
