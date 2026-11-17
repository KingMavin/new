# Immortal Path

A single-player idle cultivation RPG inspired by xianxia mythology, built with Flutter.

All combat, places, and events are told through text — narrated encounters,
choice moments, and location descriptions — brought to life with static themed
backdrops (gradient art per location) rather than animations.

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

## Phase 4 — Reincarnation, sects & the wider world

- Reincarnation prestige: after ascending, crystallize your life into soul power and start over
- Soul shop with five permanent upgrades (qi, attack, hp/defense, spirit stone gains, breakthrough chance) that survive every rebirth
- Rebirth keeps half your spirit stones, all discovered techniques, your companion, your bestiary, and all soul upgrades
- Three joinable sects (Heavenly Sword Sect, Myriad Pill Valley, Mystic Formation Hall) with four contribution ranks (Outer Disciple → Elder) and escalating bonuses
- Disciples: recruit up to three, dispatch them on timed idle missions (herbs, stones, cores) that grant contribution and level them up; missions complete even while the app is closed
- Random encounter events: 12 choice-based vignettes (tombs, merchants, sages, gambles) that can trigger after battle victories
- Codex/bestiary tracking every beast species you have slain
- Five-tab interface: Cultivate, Adventure, Alchemy, Sect, Dao

## Phase 5 — World map & narrated encounters

- Text-driven combat: fights unfold as narrated exchanges you step through, with live HP bars for you and the beast
- Choice moments mid-fight: at the opening clash, when you are wounded, when the beast falters, and at random exchanges, the battle pauses for decisions — stand ground, strike first, burn your core, flee
- Technique-gated moments: your equipped technique unlocks unique battle choices (flame eruptions, sword heart slashes, binding formations, lightning calls)
- Choice odds scale with your stats: attack advantage raises success chances, defense helps escapes
- World map with 15 locations across the nine realms: wilderness regions, raid locations (fallen cities and forbidden grounds with elite foes), and hidden realms that show as "??? " until discovered
- Hidden locations are found through exploration (8% on victory) and teased through rumor hints
- Travel between locations; raids (Sunken City of Zhao, The Bone Pits, Fallen Capital of Yan, The Void Rift) pit you against elite bosses for richer rewards
- Static themed art: every location has a gradient backdrop and sigil used on the map and during encounters

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

1. Multi-wave raids and sect wars (extended narrative battles)
2. Audio, local notifications, balance pass, optional background art packs
