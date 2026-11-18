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

## Phase 6 — Races, tournaments & faction wars

- Choose your origin at the start of a new life: Human (+10% qi gain), Demon (+15% attack, +10% health), or Demi-human (+15% defense, +10% spirit stones) — each with its own mortal-world introduction
- Race bonuses flow through every stat: cultivation rate, combat power, and loot
- Sect tournaments: duel a ranked disciple of your sect (1 hour cooldown) with an Opening Salute choice moment; victory earns spirit stones and sect contribution
- Faction wars (Golden Core realm and above, 4 hour cooldown): your side’s strength — combat power, disciple levels, sect rank — is weighed against the enemy’s before a champion duel begins, and the war front narration tells you which side the ranks believe in
- Tournaments and wars use the same narrated encounter system with their own backdrops (tournament ring, war front) and opening choice moments
- Tournament and war results are recorded in your records

## Phase 8 — Paths, endings & the immortalized legend

- Your name is asked at character creation — the name the world will remember
- Story arcs: five choice-driven chapters per race (The Verdant Empire, The Old Blood, The Beast-Blooded), unlocked as you climb the realm ladder (chapters at realms 0, 1, 3, 5, 7)
- Every story choice pushes you along one of three paths — Path of Heaven (+3% breakthrough), Path of Sovereignty (+5% attack), Path of the Wild (+5% spirit stones) — and the dominant path shapes how your tale ends
- Six endings, evaluated when you survive the final tribulation at the ascension gate: three main endings (The Gate of Heaven, The Ash Throne, The Verdant Return) decided by your dominant path, and three hidden endings earned by condition — The Ninth Lightning (survive after failing three tribulations), The Nameless Grave (give everything to the beggar at the shrine), The Wheel Unbound (reach ascension after three rebirths without losing a battle)
- Endings are epilogue milestones, not game-overs: they are recorded in your legend, the game continues, and reincarnation starts a New Game+ with a fresh story arc
- Immortalization: reach the highest reputation tier or achieve any ending and the world remembers you — statues, heralds crying your name at tournaments, enemy soldiers whispering it on war fronts; your name survives every reincarnation
- Race-gated combat moments: demons get Bloodline Frenzy, demi-humans get Beast Senses, humans get Formation Tactics as mid-fight choices
- A new random event (The Beggar at the Shrine) feeds the hidden endings; some story choices leave permanent flags

## Phase 9 — Powers, sect arts & changing blood

- Special powers hidden in the wilds: six legendary powers (Ember of the Fallen Phoenix, Dragon-Scale Heart, Thunder Marrow, Void Insight, Moonveil Blessing, The Sage's Last Word) that can surface after any battle — far more often in raids, fallen cities, and faction halls
- Powers stack with everything else and are soul-deep: they follow you through reincarnation
- Sect arts, taught only to serving members: Sword Intent (Heavenly Sword Sect, +8% attack), Merged Pill Scripture (Myriad Pill Valley, +8% qi), Grand Formation Insight (Mystic Formation Hall, +2% breakthrough) — each bought with 150 contribution and Inner Disciple rank
- The Special Powers codex on the Dao screen tracks found powers, unfound legends, and sect arts you can buy
- The Faceless Messenger: a rare wandering event will reforge your flesh into another race for 5,000 spirit stones — you change race, restart that race's story arc, and the faction you abandoned brands you Hated (−200 reputation, no standing bonus) on the map
- Faction Standing now shows every faction's true opinion of you, including Hated

## Phase 7 — Faction reputation & race halls

- Faction reputation: every hunt, tournament, and war earns reputation with your people’s faction (Verdant Empire, Ash Wastes Clans, or Border Forest Tribes); wars and tournaments earn far more than hunts
- Five standing tiers: Stranger → Acknowledged → Sworn Ally → Champion → Beloved of the Heavens; each tier grants +3% qi and spirit stones
- Faction Standing card on the world map shows all three factions, your tier, progress to the next, and your standing bonus
- Race-specific faction halls on the map, open only to their race and only at sufficient standing: Verdant Palace of the Empire (human), Ash Sanctum of the Clans (demon), Moonveil Glade (demi-human)
- Each hall is an elite-hunting ground with better rewards than wild regions of the same realm, with its own gradient backdrop and sigil
- Reputation survives reincarnation — your deeds echo across lives

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

1. Balance simulation and pass over the stacked multipliers; settings with save export/import
2. More content inside existing systems: extra story chapters, events, regions, and hidden locations
3. Local notifications, audio, optional background art packs; monetization scaffolding (opt-in rewarded ads, support/cosmetic purchases — never stat power)
