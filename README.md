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
  monetization/   MonetizationGateway abstraction + AdMob/billing stub
  state/          GameController (ChangeNotifier): tick loop, autosave, lifecycle
  ui/             Material 3 interface
```

The simulation is pure Dart with delta-time computation, so all gains derive
from elapsed time. This keeps online ticks, background pauses, and offline
progress consistent and unit-testable.

## Roadmap

1. More content inside existing systems: extra story chapters, events, regions, and hidden locations
2. Local notifications, audio, optional background art packs
3. Real store integration: swap `StubMonetizationGateway` for AdMob rewarded ads and `in_app_purchase` behind the existing gateway interface while keeping the shop honest
4. Expand the stores: seasonal heirloom sets, sect-liveried gear skins, offline cap bundles as gifts
