# Immortal Path

*A xianxia idle cultivation RPG for Flutter.*

Immortal Path is a single-player, text-first idle RPG built on Asian
mythology. You wake a mortal in the shadow of the Verdant Empire, circulate
qi, break through nine realms and four stages each, survive the heavens'
lightning, swear into one of nine sects (three per faction) or walk the
errant road alone, hunt beasts, duel in sect tournaments, fight faction
wars, and gamble on story events whose choices carve lasting marks into
your flesh. Across multiple lifetimes, seven endings wait. Strength is
always the answer — but how you answer defines the life you lived.

Current version: **0.20.2** (see `pubspec.yaml` at any commit).

---

## At a glance

- **Idle cultivation core** — qi accumulates over real time; requirements scale 1.6× per global stage; offline gains settle up to an 8/12/24-hour cap
- **9 realms × 4 stages** (Qi Refining to Ascension) with breakthrough ceremonies and heavenly tribulations of 3–9 waves and three tactics
- **3 races / factions** — human, demon, demi-human — each with an empire on the map and five reputation tiers
- **9 sects, 9 equal doctrines** — isometrically balanced, no ranking above the other; joinable at realm 2, with ranks, tasks, promotions, consequences, and the errant (unaffiliated) road
- **Narrated encounter combat** with 2–3 stat-gated choice moments per fight — hunts, tournaments (1h cooldown), wars (4h cooldown, realm 3+)
- **Marks of the Path** — 8 lasting boon/bane marks from your choices, wired into combat, qi, loot and endings
- **15 random events** with painted artwork, informed choices (costs and risks shown, dead ends prevented) and consequences
- **Alchemy, forge, sect armory, stores** — pills, 9 forge recipes with success odds, gear for spirit stones and coin
- **6 techniques, companions, 9 discoverable powers, 5 soul upgrades, longevity** — depth without new axes
- **Story paths & 7 endings** — 3 main endings by dominant path, 4 hidden ones by deeds and scars
- **Polish layer** — onboarding, chronicle journal, daily ledger, 27 achievements, technique mastery, breakthrough ceremonies, narration for every screen and case, real looping audio
- **Clean monetization philosophy** — ads are opt-in boons only; purchases are identity, comfort and support, never power

## Table of contents

- [The core loop](#the-core-loop)
- [Systems reference](#systems-reference)
  - [Realms & breakthroughs](#realms--breakthroughs)
  - [Races & factions](#races--factions)
  - [Reputation](#reputation)
  - [Marks of the Path](#marks-of-the-path)
  - [Sects](#sects)
  - [Combat encounters](#combat-encounters)
  - [Cultivation depth](#cultivation-depth)
  - [Alchemy, forge & armories](#alchemy-forge--armories)
  - [World map](#world-map)
  - [Story, paths & endings](#story-paths--endings)
  - [Events, deeds & the chronicle](#events-deeds--the-chronicle)
  - [Audio](#audio)
  - [Offline progress & saves](#offline-progress--saves)
  - [Monetization policy](#monetization-policy)
- [Getting started](#getting-started)
- [Testing](#testing)
- [Tooling](#tooling)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Roadmap](#roadmap)
- [What hasn't been added yet](#what-hasnt-been-added-yet)
- [Development history](#development-history)

## The core loop

1. **Circulate** — qi flows at a rate set by realm, stage, technique, companion, soul, sect, race, reputation, boosts, marks and lifespan.
2. **Break through** — spend full-requirement qi to climb Early → Peak, then face a tribulation (3–9 lightning waves, three tactics; the Mystic Formation Hall's warding takes one wave off).
3. **Strengthen** — hunt beasts for loot and stones, brew pills, forge weapons, feed your companion, discover powers, story-chapter by story-chapter.
4. **Answer the world** — random events (15) appear with painted art and 2–3 choices; sect tasks, tournaments and wars pay contribution, reputation and stones; some choices bind permanent marks.
5. **Ascend or return** — at Ascension, an ending is weighed. Rebirth (prestige) converts progress into soul power, keeps half your stones, techniques, companion and bestiary, clears marks, and starts a new life.
6. **Repeat, deeper** — soul upgrades, legacy names, new sects, new endings.

## Systems reference

### Realms & breakthroughs

9 realms (Qi Refining → Ascension), 4 stages each (Early/Middle/Late/Peak), 36 global stages. Requirements scale `100 × 1.6^globalStage`. Failed breakthroughs cost 25% of stored qi. Beast HP, player attack/defense/HP all rebase on `2^realm` (audited by the balance simulator).

### Races & factions

| Race | Bonuses | Faction |
|---|---|---|
| Human | +10% qi rate | Verdant Empire |
| Demon | +15% attack, +10% HP | Ash Wastes Clans |
| Demi-human | +15% defense, +10% stones | Border Forest Tribes |

Faction can be changed once via the faceless messenger event — your race (and bloodline) reforges, and the faction you left hates you for it.

### Reputation

Five tiers at 0 / 100 / 300 / 700 / 1500 points: **Stranger → Acknowledged → Sworn Ally → Champion → Beloved of the Heavens**. Each tier grants +3% qi and +3% stone loot. Gains: hunts (+5, +3×difficulty), tournament wins (+20, +10×difficulty; losses still +3), war wins (+60, +20×difficulty; losses +10). The errant path (no sect) earns ×2.5 on tasks and ×1.25 on combat reputation. Hidden places on the map and immortalization at the top tier are gated by reputation. Leaving a sect costs 60 reputation with your faction.

### Marks of the Path

Choices have consequences — mild or severe, lasting for the whole life (cleared only by reincarnation). Marks change combat math, qi rate, stone loot, gate a hidden ending, and feed the **Marked Soul** deed.

| Mark | Type | Effect | How it is earned |
|---|---|---|---|
| Iron Will | Boon | +5% attack & defense | Win any fight with ≤25% HP left |
| Stormtouched | Boon | +8% qi | Survive the thunder cave gamble |
| Dragon's Blood | Boon | +5% HP & attack | Pry a scale from the dragon bones |
| Frightened | Bane | −6% qi | Fail the thunder cave gamble |
| Withered Palm | Bane | −6% attack | Fail the dragon bones gamble |
| Scarred | Bane | −10% HP | Lose a hunt (50% chance) |
| Humiliated | Bane | −3% qi | Lose a tournament |
| Cursed Wounds | Bane | −8% defense | Lose a war |

### Sects

Joinable from realm 2 (index 1), one sect, your faction only. Three bonus axes per rank: +12% attack, +10% qi, +3% breakthrough success. Ranks at 0 / 100 / 300 / 800 contribution: **Outer → Inner → Core Disciple → Elder**, each promotion a small ceremony. Nine sects, deliberately equal in worth:

| Sect | Faction | Doctrine |
|---|---|---|
| Heavenly Sword Sect | Human | Blade Doctrine — tournament duels award +50% contribution |
| Mystic Formation Hall | Human | Array Warding — tribulations begin one wave weaker |
| Imperial Herbal Court | Human | Physician's Grace — brewing can yield an extra pill |
| Blood Furnace Clan | Demon | Furnace Oath — forging success chance +10% |
| Myriad Pill Valley | Demon | Elixir Refinement — qi and breakthrough pills are 25% more potent |
| Nightveil Bureau | Demon | Omen Files — power discovery chance ×1.5 |
| Spirit Beast Court | Demi-human | Pack Bond — companion bonuses are doubled |
| Verdant Whisper Grove | Demi-human | Root Patience — hunt loot stones +20% |
| Wind-Speaker Circle | Demi-human | Storm Grammar — tournament and war cooldowns −25% |

Halls are alive: named NPCs with stance-dependent dialogue, clickable lines, and visible rosters. Five task types rotate on the board:

| Task | Target | Contribution | Reputation | Stones |
|---|---|---|---|---|
| Cull the Beasts | 4 hunts | 25 | 10 | 50 |
| Serve the Banner | 1 war | 80 | 40 | 120 |
| Wear the Sect Colors | 2 tournaments | 40 | 20 | 70 |
| Feed the Furnace | 2 brews | 30 | 8 | 55 |
| Walk the Wilds | 2 new places | 25 | 10 | 45 |

Leaving has consequences: −60 faction reputation, `sectBetrayed` bars rejoining that sect, sect arts lapse, disciples scatter. The errant road trades sect axes for freedom — and for doubled task reputation, because the sectless must be twice as loud. As the number 1 rule: *strength is always the answer*.

### Combat encounters

Hunts, tournaments and wars are narrated encounters, not auto-battles. Each has 2–3 choice moments gated by your stats (attack, defense, HP) plus race- and technique-specific moments, with costs and risks shown up front and options you cannot afford visibly locked. Defeats are fully handled: rewards, cooldowns, task progress, reputation, dead-counter accounting and their marks — losing a war is a wound, not a dead end. Fleeing is always an escape hatch.

### Cultivation depth

- **Techniques (6)** — Basic (×1.0), Flame Meridian Art (×1.5), Iron Body Sutra (×0.75, defense-flavored), Sword Heart Sutra (×0.9, attack-flavored), Mystic Formation Art (×0.85), Thunder Refining Sutra (×1.1); each brings its own combat choice moments
- **Technique mastery** — each victory deepens your current technique: +1% attack per level, capped +15%
- **Companions** — 8% tame chance from hunts; spirit beasts level to 10 (qi +4%/level, attack +5%/level), fed with 2 beast cores
- **Powers (9)** — 6 found in the world (6% elite / 1% normal discovery) + 3 purchasable sect arts; Nightveil Bureau members store omens that boost discovery ×1.5
- **Soul prestige (5 upgrades)** — Qi Attunement, Battle Instinct, Iron Soul (max 10 each), Fortune's Favor, Heavenly Insight (max 5 each); bought with soul power across lifetimes
- **Longevity** — realms extend lifespan up to 100,000 years; Longevity Pills add 25 years each; live culture: +1% qi rate per full century gained, capped +10%

### Alchemy, forge & armories

- **Alchemy (3 recipes)** — Qi Gathering Pill (2 herbs, 10 stones), Foundation Pill (3 herbs, 25 stones), Longevity Pill (0 herbs, 40 stones, permanent lifespan)
- **Forge (9 recipes)** — Earth grade (×2 gear, 60%), Heaven grade (×3, 35%), Immortal grade (×4, 15%) for blade/vestment/talisman; powered with herbs + beast cores + spirit stones; failures refund 40% of the stones; the Blood Furnace Clan's oath adds +10% success
- **Sect armory** — 6 gear pieces (Spirit and Earth grades) for contribution-scaled spirit stones
- **General store** — heirloom gear, offline scrolls (12h/24h), individual themes, The Immortal Pack

### World map

18 places: the 9 beast-hunting zones (Bamboo Forest → Heavenly Gate Ruins), 3 faction halls (Verdant Palace, Ash Sanctum, Moonveil Glade — race-gated), plus 6 hidden and fallen places (Sunken City of Zhao, Bone Pits, Sword Vault, Fallen Capital of Yan, Void Rift, Hidden Immortal Grotto) discovered through reputation, luck and story.

### Story, paths & endings

Five chapters per race (gates at realms 0/1/3/5/7) — the human's imperial bargain, the demon clans' survival, the demi-human tribes' forest law. Every choice feeds three hidden path scores: **Heaven**, **Sovereignty**, **Wild**.

| Ending | Kind | Condition |
|---|---|---|
| The Gate of Heaven | Main (Heaven) | Dominant heaven path at ascension |
| The Ash Throne | Main (Sovereignty) | Dominant sovereignty path |
| The Verdant Return | Main (Wild) | Dominant wild path |
| The Ninth Lightning | Hidden | Survive 3 failed tribulations' price |
| The Nameless Grave | Hidden | Give everything away in the right moments |
| The Unbowed | Hidden | Ascend carrying ≥3 lasting marks |
| The Wheel Unbound | Hidden | Reincarnate ≥3 times without ever losing a battle |

Endings do not end the game — ascension immortalizes your legend, the ledger of deeds records it, and the idle engine (and next life) continues.

### Events, deeds & the chronicle

- **15 random events** with painted art, informed choices, and both success and failure consequences (including marks, faction switches, and gifts)
- **27 achievements** — from First Blood to Marked Soul — recorded in the codex with acquisition journal entries
- **Chronicle journal** — the last 60 happenings of this life, readable on the Dao screen
- **Daily sect ledger** — one signature per day: stones scaled to realm, 2 pills, and a deterministic omen
- **Narration catalog** — 10 screen contexts and 15 case contexts (3–4 lines each) so every screen, act and case speaks
- **Breakthrough ceremonies** — full-screen recognition for the milestones; onboarding (5 art slides) for first lives

### Audio

Real looping audio built on `audioplayers`: 4 context music tracks (cultivation, exploration, tournament, war) and 7 sound effects (breakthrough, tribulation cleared, battle won, forge struck, event chime, acquisition, ledger signed), all generated by `tool/generate_audio.py`, all behind the `AudioGateway` abstraction with a music director that swaps tracks by screen context and never restarts the same track. Full toggle in settings.

### Offline progress & saves

Gains settle from elapsed real time on return, capped at **8h** by default, **12h** with the offline scroll, **24h** with the deep scroll or The Immortal Pack. Saves are versioned JSON in `shared_preferences` (schema v14, back-compatible to v1), autosaved every 30s and on app pause, with manual text export/import in settings.

### Monetization policy

- **Rewarded ads are opt-in only**: an explicit button → ad → timed boon (qi incense, stone favor, cooldown pigeon). Never forced, never ambient.
- **Purchases never sell power**: they are identity (3 themes + the celestial gold pack theme), comfort (offline caps, The Immortal Pack) and support (one-time patron tiers). Heirloom gear is realm-minted at purchase and is outgrown by normal drops — a convenience, not a ladder.
- The entire layer sits behind `MonetizationGateway`; this build ships a stub, and the swap-in guide is in the Phase 11 history below.

---

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

## Testing

```bash
flutter test
```

34 test files, 325 tests: engine invariants, save round-trips (including back-compat with old schema versions), perk wiring, narration, forge odds, consequences, and ending conditions.

[dart run tool/balance_sim.dart](#tooling) replays seeded lifetimes and asserts the scaling invariants (pacing, combat ratios) that the balance pass established.

## Tooling

- `tool/generate_images.py` — pure-stdlib painter; regenerates all 43 PNG backdrops (9 screens, 14 events, 17 locations, 3 story cards)
- `tool/generate_audio.py` — writes the 11 WAVs (4 music loops + 7 effects)
- `tool/generate_icon.py` — paints the 3 launcher icons
- `tool/balance_sim.dart` — seeded balance simulator for the scaling audit

## Architecture

```
lib/
  game/
    models/        20+ immutable data classes: realm ladder, GameState (v14,
                   JSON-serializable), equipment, sect, sect tasks/NPCs,
                   narration, consequences, story, forge, world locations...
    engine/        30 pure-Dart engines: cultivation, combat, encounters,
                   events, sects, reputation, consequences, endings,
                   achievements, mastery, forge, boosts, audio cadence
    persistence/   SaveRepository interface + shared_preferences implementation
    util/          Number and duration formatting
  audio/           AudioGateway abstraction, music director, audioplayers
                   implementation with a failure circuit-breaker
  monetization/    MonetizationGateway abstraction + stub implementation
  state/           GameController (ChangeNotifier): tick loop, autosave,
                   voice/dialog routing, monetization and encounter flows
  ui/              Material 3 shell, 12+ screens, narration and backdrop
                   widgets (Theme/)
```

The simulation is pure Dart with delta-time computation, so all gains derive
from elapsed time. This keeps online ticks, background pauses, and offline
progress consistent and unit-testable.

## Documentation

- [PRIVACY_POLICY.md](PRIVACY_POLICY.md) — no account, no analytics, no ad SDKs; the save never leaves the device
- [STORE_LISTING.md](STORE_LISTING.md) — paste-ready store listing and data-safety answers
- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) — the ordered path from `flutter pub get` to a store upload
- [LICENSE](LICENSE) — MIT

## Roadmap

1. More content inside existing systems: extra story chapters, events, regions, and hidden locations (Phase 17 already deepened the sects: nine halls, NPC rosters, task boards, promotions and the errant path)
2. Local notifications and optional background art / commissioned audio packs (the audio system itself is live since Phase 15)
3. Real store integration: swap `StubMonetizationGateway` for AdMob rewarded ads and `in_app_purchase` behind the existing gateway interface while keeping the shop honest
4. Expand the stores: seasonal heirloom sets, sect-liveried gear skins, offline cap bundles as gifts
5. Platform shells, icon stamping, store consoles: see RELEASE_CHECKLIST.md — it is the ordered path to a public build

## What hasn't been added yet

Honest gaps, in rough priority order:

- **Real ads and real billing** — the Temple of Support still runs on the stub gateway; wiring AdMob and Google Play billing needs ad-unit IDs and a store listing, which only you can provide from your consoles. The game is fully playable (and fully generous) without them
- **Commissioned audio and art** — all music, effects, images and backdrops are procedurally generated placeholders: quiet, license-free, and swappable 1:1 by filename, but not the equal of a composed soundtrack or painted art pack
- **Local notifications** — no reminder when a tournament window opens or the daily ledger is waiting for a signature
- **Cloud save & sync, leaderboards** — the save lives on-device with manual text export/import; no account, no cloud slot, no ranking against other immortals
- **Localization** — the whole game is English-only strings
- **Deliberately out of scope** (Phase 9 ceiling): more races, more realms, or additional hard currencies — the depth goes into existing systems instead

## Development history

The phases below are kept verbatim as they shipped, now sorted into
numerical order for reference.

## Phase 1 — Cultivation core

- Qi accumulation over time (idle) plus an active "Circulate Qi" action
- Nine-realm ladder (Qi Refining → Ascension) with Early/Middle/Late/Peak sub-stages
- Breakthrough attempts with success chances; failures cost 25% of current qi
- Major-realm breakthroughs as tribulation gates
- Offline progress (capped at 24h) with a "While you were in seclusion" report
- Autosave every 30s and on app pause, persisted via shared_preferences
- Lifespan display per realm and an ascension ending
## Phase 2 — Combat & alchemy

- Nine adventure zones gated by cultivation realm, each with themed beasts
- Auto-battle simulation with round-by-round combat log (seeded, deterministic in tests)
- Loot: spirit stones, spirit herbs, beast cores, and equipment drops
- Five equipment grades (Mortal → Immortal) for weapon and armor slots; stronger drops auto-equip, weaker ones sell for spirit stones
- Alchemy: brew Qi Gathering, Foundation (+breakthrough chance), and Longevity pills from herbs, cores, and stones
- Three-tab interface: Cultivate, Adventure, Alchemy
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
## Phase 7 — Faction reputation & race halls

- Faction reputation: every hunt, tournament, and war earns reputation with your people’s faction (Verdant Empire, Ash Wastes Clans, or Border Forest Tribes); wars and tournaments earn far more than hunts
- Five standing tiers: Stranger → Acknowledged → Sworn Ally → Champion → Beloved of the Heavens; each tier grants +3% qi and spirit stones
- Faction Standing card on the world map shows all three factions, your tier, progress to the next, and your standing bonus
- Race-specific faction halls on the map, open only to their race and only at sufficient standing: Verdant Palace of the Empire (human), Ash Sanctum of the Clans (demon), Moonveil Glade (demi-human)
- Each hall is an elite-hunting ground with better rewards than wild regions of the same realm, with its own gradient backdrop and sigil
- Reputation survives reincarnation — your deeds echo across lives
## Phase 8 — Paths, endings & the immortalized legend

- Your name is asked at character creation — the name the world will remember
- Story arcs: five choice-driven chapters per race (The Verdant Empire, The Old Blood, The Beast-Blooded), unlocked as you climb the realm ladder (chapters at realms 0, 1, 3, 5, 7)
- Every story choice pushes you along one of three paths — Path of Heaven (+3% breakthrough), Path of Sovereignty (+5% attack), Path of the Wild (+5% spirit stones) — and the dominant path shapes how your tale ends
- Seven endings, evaluated when you survive the final tribulation at the ascension gate: three main endings (The Gate of Heaven, The Ash Throne, The Verdant Return) decided by your dominant path, and four hidden endings earned by condition — The Ninth Lightning (survive after failing three tribulations), The Nameless Grave (give everything to the beggar at the shrine), The Wheel Unbound (reach ascension after three rebirths without losing a battle), The Unbowed (ascend carrying three or more lasting marks of the path)
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
## Phase 10 — Balance pass, simulator & settings

- New balance simulator (lib/game/engine/balance_simulator.dart) that audits the whole game: multiplier stacks layer by layer, time-to-ascension curves for fresh and fully-stacked builds, and win/die round math for every beast at three player profiles
- Run it with `dart run tool/balance_sim.dart` for the full report; test/balance_simulator_test.dart enforces the invariants in CI
- Combat scaling rebuilt: beasts previously grew at 2.2x per realm while player base stats grew at 2x, leaving late-realm zones mathematically unwinnable (defense above attack) until three stages in. Beasts are now difficulty-tuned per zone (0.9 to 1.55) on a 2x realm base, so every zone is winnable the moment you enter it, elite grounds demand in-realm progress, and a maxed build clears everything
- Qi realm growth raised from 2x to 3.8x per realm: a fresh unbuffed climb to ascension drops from ~2,400 hours (100 days of pure idle) to ~23 hours with a smooth ramp where each realm takes ~1.7x the previous one; legacy multipliers then compress rebirth climbs fourteen-fold
- Combat fundamentals unchanged (2x per realm) so the fight-by-fight difficulty bands above stay valid
- Settings screen (gear icon on every tab): export your save as text (copy to clipboard), import a save by pasting it back, and an erase-and-restart danger zone
## Phase 11 — Temple of Support: opt-in ads & purchases

- The Temple of Support (entry card on the settings screen) keeps monetization honest with one rule: **ads are optional timed boons, purchases are identity and comfort — nothing ever sells stats**
- Three opt-in ad blessings: Incense of the Ancestors (2x qi for 8h), Fortune Teller's Favor (+50% spirit stones for 4h), and The Duel Pigeon (clears tournament and war cooldowns); each has its own cooldown and every one is replaceable by play — boosts multiply qi/stone rates only, and the whole ladder remains winnable without ever touching them
- Four store products: Immortal Patron (support tier with the Celestial Gold theme and a Patron mark on your legend) plus three cosmetic themes — Phoenix Ember, Ashen Clans, Moonveil Glade — which re-tint the entire Material 3 app instantly
- All purchases and ad rewards persist through reincarnation, survive save export/import, and load from version 9 saves with clean defaults (GameState v10)
- Real AdMob and billing are not wired in this build; the whole layer sits behind a `MonetizationGateway` abstraction (lib/monetization/monetization_gateway.dart) with a `StubMonetizationGateway` that simulates a successful watch/purchase after a short delay, so any real gateway can be dropped in without touching game logic

### Wiring in real ads and billing

The game talks to the store only through the gateway, so the swap is one class:

1. Add `google_mobile_ads` and `in_app_purchase` to `pubspec.yaml` (store accounts and test unit IDs are set up in the AdMob and Play/App Store consoles — this cannot be done from a dev sandbox, and price labels like `\$4.99` in `MonetizationCatalog` are placeholders meant to be replaced by real store-dynamic prices).
2. Write a `RealMonetizationGateway implements MonetizationGateway`: `showRewardedAd` loads and presents a rewarded ad for the placement id (reward on `RewardedAdEvent.earnedReward`), `purchase` runs the `in_app_purchase` flow (restore purchases on startup for non-consumables like themes and patron), and `isConfigured` returns true once AdMob unit IDs are present.
3. Pass the gateway in: `GameController(gateway: RealMonetizationGateway())`.

Everything else (cooldowns, boost expiry, persistence, the store UI) already works and is covered by `test/boost_engine_test.dart`, which also pins the anti-pay-to-win guarantees: ad multipliers cap at 2.0 with 8h max duration, cooldowns are always non-zero, and the store only ever sells `support` and `theme` kinds.
## Phase 12 — Stores: offline stillness, heirlooms & the sect armory

- Offline progress becomes a shop reward: free cultivators bank up to 8 hours; Hours of Stillness II ($2.99) raises the cap to 12; Hours of Stillness III ($4.99) to 24; The Immortal Pack already includes the full 24
- Amulets join weapons and armor as a third equipment slot (an amulet lends half its power to attack and half to defense); they come from stores, not beast drops
- The Temple of Support grows: The Immortal Pack ($24.99, one payment for patron + every theme + 24h offline + the full Ancestral Heirloom set), the Heirloom Armory (Ancestral Fang / Mantle / Seal, $3.99 each), and the Hours of Stillness scrolls
- The Sect Armory opens from the sect screen — a second store deliberately separate from the Temple: sect-forged weapons, armor, and talismans bought with spirit stones (costs scale 1.8x per realm alongside item power), gated by sect rank, plus an Offerings section that lists the same real-coin heirlooms and offline hours
- Paid gear cannot break the ladder: heirlooms mint at Immortal-grade power for the realm you buy at, store gear auto-equips only when strictly better than what you carry, drops in later realms always outgrow them, and the sect sells nearly-as-good gear for earned stones
- GameState v11: the amulet slot persists in saves; version 10 saves load with a null amulet, and all store grants survive reincarnation
## Phase 13 — Art pass & the forge

- Original still art for the whole game: 43 license-free painted backdrops (tool/generate_images.py, pure Dart-free Python, swappable 1:1 by keeping filenames) covering every screen (cultivation cave, misty world map, pill furnace, sect at dawn, star-lit Dao, storm tribulation, golden temple, bamboo settings, battlefield), every one of the 14 random events, all 17 world locations, and one entrance image per race's story arc
- Each screen paints its image behind the cards under a dark scrim so text stays readable; the encounter screen and event dialogs use their location/event image as full header art
- Random events are now actually playable: the event that triggers after a hunt opens as a full-screen narrated card with its own art and its 2–3 choices - until now events fired but had no UI to show them
- The Forge arrives in the Sect Armory: 9 recipes (weapon/armor/amulet at Earth/Heaven/Immortal grade), paid in spirit stones (scaled 1.8x per realm) plus spirit herbs and beast cores
- Forging is a gamble: 60%/35%/15% success by grade - failure shatters the materials and salvages only 40% of the stones; success mints gear 8% above the loot band of your realm and auto-equips only when strictly better
- Real-coin heirlooms (Phase 12) remain the guaranteed high-end shortcut; the forge is the earned-stones gamble under them
## Phase 14 — Polish pass

- Onboarding journey: five illustrated slides (mortal world, qi loop, wilds, sects & forge, Temple of Support) shown on first launch before origin selection; Skippable once, never shown again (`introSeen` in the save)
- Chronicle journal: every meaningful beat — hunts, breakthroughs, tribulation outcomes, event results, forge attempts, sect oaths, purchases, acquisitions of power and hidden realms, offline cultivation while away — is written to a 60-entry per-life chronicle; newest eight shown in the Chronicle card on the Dao screen with a full-chronicle dialog
- Daily Sect Ledger: sign once per day for one of eight deterministic omens, spirit stones scaled by realm (150 × 1.8^realm) and 2 qi pills; the ledger card appears on home whenever today's signature is missing
- Codex of Deeds: 27 achievements checked automatically after hunts, breakthroughs, tribulations, events, tournaments, wars, forges and purchases; earned deeds announce themselves in the chronicle, are browsable from the Deeds card on the Dao screen, and are purely cosmetic badges
- Technique mastery: each battle victory with an equipped technique deepens its mastery (+1% attack per victory, capped at +15% at level 15); shown on the equipped technique's card, resets with each new life
- Breakthrough ceremony: successful stage breakthroughs now get a full-screen still backdrop and heralding text instead of a snackbar; failures stay as snackbars
- Boost chips: active Temple blessings show as live-countdown chips atop the home screen
- Audio gateway: `AudioGateway` abstraction with a sound toggle; the real player (Phase 15) sits behind it — no gameplay code changes needed
## Phase 15 — Sound of the path & full accounting

- Real looping audio through `audioplayers`, behind the same `AudioGateway` abstraction as everything else: the game never crashes over audio — any playback failure silently disables the player and play continues
- Four seamless ambient loops, one per context (procedurally generated WAVs, `tool/generate_audio.py`): **Cultivation** (24s, temple bells over a low drone — home, dao, sect, alchemy and store screens), **Exploration** (16s, koto plucks with wind — the world map and hunt encounters), **Tournament** (12s, taiko drums and gongs for sect tournaments), **War** (12s, war drums and horns for sect wars); the music director picks the track from active encounter + current tab every frame, so music follows you into combat and back
- Seven sound effects mark the milestones: breakthrough arpeggio, tribulation thunder, battle drum, forge clang, event chime, acquisition sparkle, ledger stamp
- All 11 WAVs are seamless loops with deterministic seeds and are regenerable by running `python3 tool/generate_audio.py`; swap any file 1:1 to change the sound without touching code
- The Sound switch in settings now truly mutes: toggling off stops the music immediately; toggling on starts the cultivation theme
- Event system audited end-to-end: tournament and war completions now also roll for random events (previously only hunts could trigger them), a latent herb double-grant in event resolution was fixed (herbs are granted only through the success block), and failed gambles are verified to keep their costs paid but grant nothing
- Everything is properly recorded and stored: every event, gambled roll, tournament and war result is journaled in the chronicle and persisted — the save holds it all in GameState v12 (journal, deeds, mastery, ledger day, intro flag, sound preference) with export/import in settings and backward compatibility back to version 1 saves
## Phase 16 — Ship-ready packaging

- **Original app icon** painted by `tool/generate_icon.py` (pure stdlib, same visual language as the backdrops): a 1024x1024 full-bleed icon, a 512 store icon, and an adaptive-icon foreground with the motif inset in the safe zone — a moon, layered ridges and a tiered pagoda against a dawn horizon. The `flutter_launcher_icons` dependency and config are already in `pubspec.yaml`; after `flutter create`, `dart run flutter_launcher_icons` stamps every platform density
- **PRIVACY_POLICY.md** — the store-mandated policy, and an easy one: no account, no analytics, no ad SDKs in this build, and the save never leaves the device
- **STORE_LISTING.md** — paste-ready Google Play / App Store listing: short and full descriptions, a screenshot checklist, content-rating notes, and the data-safety answers (no data collected)
- **RELEASE_CHECKLIST.md** — the complete ordered path from `flutter pub get` to a store upload: platform-shell generation, icon stamping, keystores, the WAV-to-OGG size trim, AdMob/billing go-live, and internal testing
- **LICENSE** — MIT; all art and audio is original, procedurally generated, license-free content
- Portrait orientation lock and a version line in the settings About section
## Phase 17 — Living sects: halls with faces, tasks, promotions & the errant road

The Sect tab is no longer a bare gate list. Nine sects — three per faction —
each staffed with named NPCs, a three-slot task board, and rank promotions read
out by the hall master. Leaving has teeth, and the unsworn life is a real path
where strength is always the answer.

- **Nine sects across three factions** — the Verdant Empire keeps the Heavenly
  Sword Sect, the Mystic Formation Hall and the Imperial Herbal Court; the Ash
  Wastes Clans raise the Blood Furnace Clan, Myriad Pill Valley and the
  Nightveil Bureau; the Border Forest Tribes walk with the Spirit Beast Court,
  the Verdant Whisper Grove and the Wind-Speaker Circle. Every sect shares the
  same three bonus axes (attack +12%/rank, qi +10%/rank, breakthrough +3%/rank)
  so no hall is a trap, only a flavor
- **NPC halls** — each sect seats a Master, a Steward and a Quartermaster with
  hand-written, in-voice dialogue lines (70+ lines total) that rotate with your
  rank and chronicle; a hall panel on the Sect tab gives the bare building faces
- **Task boards** — three slots, five task types (Cull the Beasts, Serve the
  Banner, Wear the Sect Colors, Feed the Furnace, Walk the Wilds). Progress
  flows in automatically from hunts/raids, tournament fights, wars, alchemy
  brewing and travel; targets scale with realm and stone rewards scale at
  ×1.8/realm. Claiming records contribution, faction reputation and stones,
  then the steward posts a fresh task in the vacated slot
- **Rank promotions** — crossing a contribution threshold (Outer Disciple →
  Inner Disciple → Core Disciple → Elder) raises a full-screen ceremony with
  the sect backdrop and the hall master's congratulations; it is journaled and
  chimed
- **Consequences for leaving** — breaking an oath costs all contribution and
  rank, −60 faction reputation, and a lifetime ban from that sect (the
  oathbreaker list lives in the save); sect arts you learned there lapse until
  you rejoin their hall. The leave dialog states every price before you sign
- **The errant path** — refusing all sects and factions is a designed road: a
  standing card tracks reputation with your faction, faction gatekeepers speak
  to the unsworn, hall tasks pay reputation ×2.5 (no contribution), and
  combat deeds earn +25% reputation — strength, counted. Sect-banner tasks
  (wars, tournaments in sect colors) never appear on an unsworn board
- **GameState v13** — adds the task board, the oathbreaker list and the
  highest sect rank achieved; version 12 saves load cleanly with defaults, and
  reincarnation strokes all three back to a fresh mortal slate
## Phase 18 — Nine sects, nine different doctrines

Phase 17 gave every sect the same three bonus axes; Phase 18 makes each hall
genuinely its own. Every sect keeps its rank-scaled axis bonus and adds **one
unique perk** of comparable value — different in kind, none ranked above
another:

- **Heavenly Sword Sect** — Blade Doctrine: tournament duels award +50% contribution
- **Mystic Formation Hall** — Array Warding: tribulations begin one wave weaker (never below two)
- **Imperial Herbal Court** — Physician's Grace: brewing pills has a 30% chance of an extra pill
- **Blood Furnace Clan** — Furnace Oath: forging success chance +10%
- **Myriad Pill Valley** — Elixir Refinement: qi and breakthrough pills are 25% more potent
- **Nightveil Bureau** — Omen Files: power discovery chance ×1.5
- **Spirit Beast Court** — Pack Bond: companion bonuses are doubled
- **Verdant Whisper Grove** — Root Patience: hunt loot stones +20%
- **Wind-Speaker Circle** — Storm Grammar: tournament and war cooldowns −25%

Perks live in `SectEngine` as pure helpers, are wired into the tournament,
tribulation, forge, power-discovery, combat, cultivation and cooldown paths,
are shown on every join card and the sect status card, and are covered by
`test/sect_perks_test.dart`. A sect's perk and axis align with its doctrine, so
choosing a hall is choosing a playstyle, not a math ranking.
## Phase 19 — A dialogue for every screen, case and act

The world now has a narrator. `NarrationCatalog` holds a cast of in-world
voices — hand-written xianxia-flavored lines — surfaced by a small
`VoiceLine` widget, so no screen or outcome moment is wordless:

- **Every screen speaks** — the home courtyard, the world map, the furnace
  hall, the dao tablet, the tribulation sky, the Temple of Support, the sect
  armory and even the settings registry each carry 3–4 rotating lines picked
  deterministically for the day, so they change daily but never flicker
  between rebuilds
- **Every case has a line** — breakthrough success and failure, tribulation
  survived and failed, tournament victory and defeat, war victory and defeat,
  hunt victory and defeat, forge success and failure, rank promotions, the
  reincarnation confirm dialog, and the ascension ending all open with a
  narrator line tailored to what just happened (15 contexts × 3 lines)
- **Acts stay as they were** — the nine story chapters per race already
  carry full narration plus choice moments, so the narrator layer covers the
  space between acts, not instead of them
- **Deterministic, testable, data-only** — lines are pure static data with
  a seeded picker; `test/narration_test.dart` guarantees every screen key and
  case key exists, every context has its lines, nothing is empty or duplicated,
  and unknown keys fall back to silence instead of crashing
## Phase 20 — Full-game audit: every path traced, every breakage healed

A whole-game integrity pass over the controller, engines, models, UI and
saves — verdict: three real breakages found and healed, everything else
verified clean.

- **Tournament & war defeats now pay out** — the loss branches of
  competing were unreachable: a finished encounter without victory was never
  routed back into the tournament/war completers, so a lost bout gave no
  contribution, no reputation, no cooldown timestamp (you could walk straight
  back onto the platform) and no task progress. All encounter endings are now
  routed by kind: victories and defeats both flow through their completers,
  hunts' flights settle cleanly, and only true hunt defeat settles bare
- **Losses are recorded** — `battlesLost` had been a dead counter since
  narrated combat replaced auto-battle, which silently made the Wheel Unbound
  hidden ending too easy. Tournament, war and hunt defeats now all count
- **Reforging no longer leaves you sworn** — the faceless messenger's
  flesh-reforging used to keep you enrolled in a sect of the very people you
  just betrayed; that sect now strikes your name from the rolls (old faction
  −60, contribution, rank, tasks and disciples reset), matching the
  leave-oath consequences
- **Recurring events show on their return** — the event dialog's
  already-shown guard never reset between triggers, so the same event firing
  again in one session was silently swallowed; the guard now clears once the
  event resolves
- **Verified clean everywhere else** — all 77 GameState fields roundtrip
  through constructor, copyWith, toJson and fromJson (save schema v13); every
  controller action notifies, saves and settles through the shared settle
  helper; (Phase 21 later raised this to 27 achievements and 7 endings) — 15 story
  chapters, hidden-realm discovery, the nine sect perks, the music director's
  four-context tracks and the audio gates were traced end to end; the errant
  path's reputation bonus is applied at every combat reputation site; old
  saves in any schema from v1 still load
- Version 0.19.1; syntax scanner clean across all 101 Dart files
## Phase 21 — Marks of the Path: every choice pays, now and later

Choices no longer resolve into a one-line reward. A lasting consequence
system — the **Marks of the Path** — lets any decisive moment bind a
boon or a bane to the cultivator that holds until the wheel of
reincarnation washes the slate:

- **Earned in the field** — win any tournament, war or hunt while fighting
  on under a quarter of your health and the crowd's roar forges
  **Iron Will** (+5% attack & defense this life). Fall in a hunt and the
  beast may leave you **Scarred** (−10% max hp). Lose a tournament and the
  arena's whispers cost you **Humiliated** (−3% qi rate); lose a war and
  **Cursed Wounds** slow every parry (−8% defense)
- **Gambles now have weight** — training in the Thunder Cave binds
  **Stormtouched** (+8% qi rate) on success or **Thunder-Shy** (−6% qi
  rate) on failure; prying a dragon scale grants **Dragon's Blood** (+5% hp
  & attack) or a **Withered Palm** (−6% attack). Event choice cards show
  the stakes — 'success marks you forever' / 'failure scars you forever'
- **Marks display on the Dao screen** in a Marks of the Path card with each
  mark's story and stat line, and every grant is journaled to the chronicle
- **A seventh ending** — **The Unbowed** (hidden): ascend while carrying
  three or more marks and heaven welcomes the scarred climber as the first
  of a new register. The 'Marked Soul' achievement celebrates the same
- **Balance rule preserved** — marks are never account-breaking: the worst
  bane (−10% hp) is milder than one realm's growth, and the wheel cleanses
  all marks on reincarnation, so a scarred legacy only shapes this life
- Save schema v14 (marks serialized, old saves load clean); 104 Dart files,
  scanner clean; new `consequence_engine_test.dart` plus mark coverage in
  the ending, event and game-state suites. Version 0.20.0
## Phase 22 — Second full-game audit: what the sweeps caught

A follow-up whole-game review after the marks system landed:

- **Fixed** — stale counts: README and store listing still said six
  endings / 26 achievements; now seven endings (with The Unbowed aliased in
  the ending list) and 27 deeds everywhere
- **Fixed** — unused consequence import in the save model
- **Records card now keeps score honestly** — battles won and lost were
  tracked but never displayed at a glance; both rows are on the home Records
  card, and your current marks of the path are listed there too
- **Onboarding teaches the stakes** — slide three now warns that choices
  bind lasting marks, boons and banes, until the wheel washes them
- **Verified safe** — beast loot only ever drops weapons and armor (the
  equip-on-drop path predates the amulet slot and is not affected), tamed
  beasts only appear when you walk companionless, docs counts now match the
  engines, and the marks system's factors leave every pre-existing balance
  untouched for players unmarked
- Version 0.20.1; scanner clean across 104 Dart files
## Phase 23 — Loose ends tied: lifespan matters, dead code gone

A third targeted pass over every engine and controller hook:

- **Lifespan now cultivates for you** — lifespan was earned (alchemy
  pills, event outcomes) and displayed, but never did anything. Long lives
  now deepen the dao: +1% qi rate per full century of hard-won lifespan,
  capitalized up to +10% — 'The mountain rewards those who linger.' The
  alchemy recipe explains the rule; tests pin the boundary
- **Audio lifecycle sealed** — the audio gateway (music + effects
  players) is now disposed with the controller instead of leaking players
- **Dead code excised** — three never-reachable members removed after a
  zero-reference audit: `CombatEngine.describeLoot` (superseded by the hunt
  summary builder), `StoreEngine.equipmentSlotField` (equip-if-better
  switches directly), and `controller.adCooldownRemaining` (the store
  computes cooldowns from BoostEngine itself); the now-orphaned format
  import left the combat engine with them
- **Verified clean** — every remaining engine constant and helper has at
  least one live call site (checked mechanically across lib, tool and
  tests); scanner clean across 104 Dart files
- Version 0.20.2

