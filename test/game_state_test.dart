import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/disciple.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/journal.dart';
import 'package:immortal_path/game/models/monetization.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/sect_task.dart';

void main() {
  group('RealmLadder', () {
    test('has nine realms', () {
      expect(RealmLadder.realmNames.length, 9);
    });

    test('has four stages per realm', () {
      expect(RealmLadder.stagesPerRealm, 4);
      expect(RealmLadder.totalStages, 36);
    });

    test('lifespan increases with realm', () {
      for (var i = 1; i < RealmLadder.realmNames.length; i++) {
        expect(
          RealmLadder.lifespanYears(i),
          greaterThan(RealmLadder.lifespanYears(i - 1)),
        );
      }
    });
  });

  group('GameState', () {
    test('json roundtrip preserves all fields', () {
      final state = GameState.initial().copyWith(
        realmIndex: 2,
        stageIndex: 1,
        qi: 123.45,
        totalQiGained: 9876.5,
        breakthroughsSucceeded: 3,
        breakthroughsFailed: 1,
        lastSaved: DateTime.utc(2024, 5, 5, 12, 30),
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.realmIndex, state.realmIndex);
      expect(parsed.stageIndex, state.stageIndex);
      expect(parsed.qi, closeTo(state.qi, 1e-9));
      expect(parsed.totalQiGained, closeTo(state.totalQiGained, 1e-9));
      expect(parsed.breakthroughsSucceeded, state.breakthroughsSucceeded);
      expect(parsed.breakthroughsFailed, state.breakthroughsFailed);
      expect(parsed.ascended, state.ascended);
      expect(parsed.lastSaved, state.lastSaved);
    });

    test('globalStageIndex combines realm and stage', () {
      final state = GameState.initial().copyWith(
        realmIndex: 2,
        stageIndex: 3,
      );
      expect(state.globalStageIndex, 11);
    });

    test('missing optional json fields fall back to defaults', () {
      final minimal = GameState.initial().toJson()..remove('ascended');
      final parsed = GameState.fromJson(minimal);
      expect(parsed.ascended, isFalse);
    });

    test('json roundtrip preserves equipment', () {
      final state = GameState.initial().copyWith(
        weapon: const Equipment(
          name: 'Spirit Blade',
          slot: EquipmentSlot.weapon,
          grade: 1,
          power: 123.5,
        ),
        armor: const Equipment(
          name: 'Earth Guard',
          slot: EquipmentSlot.armor,
          grade: 2,
          power: 88,
        ),
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.weapon?.name, 'Spirit Blade');
      expect(parsed.weapon?.power, 123.5);
      expect(parsed.armor?.gradeName, 'Earth');
    });

    test('version 1 saves without new fields load with defaults', () {
      final v1 = GameState.initial().toJson()
        ..['version'] = 1
        ..remove('spiritStones')
        ..remove('weapon')
        ..remove('armor')
        ..remove('breakthroughBonus')
        ..remove('lifespanBonusYears')
        ..remove('selectedZoneIndex')
        ..remove('battlesWon')
        ..remove('battlesLost')
        ..remove('equipmentSold')
        ..remove('spiritHerbs')
        ..remove('beastCores')
        ..remove('qiPills')
        ..remove('breakthroughPills')
        ..remove('lifespanPills');
      final parsed = GameState.fromJson(v1);
      expect(parsed.spiritStones, 0);
      expect(parsed.weapon, isNull);
      expect(parsed.armor, isNull);
      expect(parsed.breakthroughBonus, 0);
      expect(parsed.selectedZoneIndex, 0);
    });

    test('lifespan includes pill bonus', () {
      final state = GameState.initial().copyWith(lifespanBonusYears: 50);
      expect(state.lifespanYears, 130);
    });

    test('json roundtrip preserves technique and companion', () {
      final state = GameState.initial().copyWith(
        techniqueId: 'flame',
        discoveredTechniques: const ['basic', 'flame', 'thunder'],
        companion: const Companion(
          name: 'Ice Crow',
          bonusType: 'qi',
          level: 3,
        ),
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.techniqueId, 'flame');
      expect(parsed.discoveredTechniques, ['basic', 'flame', 'thunder']);
      expect(parsed.companion?.name, 'Ice Crow');
      expect(parsed.companion?.level, 3);
      expect(parsed.companion?.qiBonus, closeTo(0.12, 1e-9));
    });

    test('json roundtrip preserves tribulation state', () {
      final state = GameState.initial().copyWith(
        tribulationActive: true,
        tribulationWavesTotal: 5,
        tribulationWavesCleared: 2,
        tribulationHp: 300,
        tribulationMaxHp: 500,
        tribulationTargetRealm: 2,
        tribulationDeflectBonus: 0.2,
        tribulationLog: const ['Dark clouds gather.', 'Wave 1 survived.'],
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.tribulationActive, isTrue);
      expect(parsed.tribulationWavesTotal, 5);
      expect(parsed.tribulationWavesCleared, 2);
      expect(parsed.tribulationHp, 300);
      expect(parsed.tribulationTargetRealm, 2);
      expect(parsed.tribulationLog, ['Dark clouds gather.', 'Wave 1 survived.']);
    });

    test('json roundtrip preserves soul, sect, and disciples', () {
      final state = GameState.initial().copyWith(
        soulPower: 320,
        reincarnations: 2,
        soulUpgrades: const {'qi_attunement': 3, 'iron_soul': 1},
        sectId: 'pill_valley',
        contribution: 450,
        disciples: const [
          Disciple(name: 'Lin Xiao', level: 3),
          Disciple(
            name: 'Bai Xue',
            level: 2,
            missionType: 'hunt',
            missionHours: 2,
          ),
        ],
        missionLog: const ['Lin Xiao returned.'],
        bestiary: const ['Ironhide Boar'],
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.soulPower, 320);
      expect(parsed.reincarnations, 2);
      expect(parsed.soulUpgrades, {'qi_attunement': 3, 'iron_soul': 1});
      expect(parsed.sectId, 'pill_valley');
      expect(parsed.contribution, 450);
      expect(parsed.disciples.length, 2);
      expect(parsed.disciples[1].missionType, 'hunt');
      expect(parsed.missionLog, ['Lin Xiao returned.']);
      expect(parsed.bestiary, ['Ironhide Boar']);
    });

    test('pending event can be set and cleared through copyWith', () {
      final state = GameState.initial().copyWith(
        pendingEventId: 'ancient_tomb',
      );
      expect(state.pendingEventId, 'ancient_tomb');
      final cleared = state.copyWith(pendingEventId: null);
      expect(cleared.pendingEventId, isNull);
      final kept = state.copyWith(qi: 10);
      expect(kept.pendingEventId, 'ancient_tomb');
    });

    test('json roundtrip preserves world discovery', () {
      final state = GameState.initial().copyWith(
        discoveredLocations: const ['sword_vault', 'immortal_grotto'],
        activeLocationId: 'sword_vault',
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.discoveredLocations, ['sword_vault', 'immortal_grotto']);
      expect(parsed.activeLocationId, 'sword_vault');
    });

    test('version 4 saves load with phase 5 defaults', () {
      final v4 = GameState.initial().toJson()
        ..['version'] = 4
        ..remove('discoveredLocations')
        ..remove('activeLocationId');
      final parsed = GameState.fromJson(v4);
      expect(parsed.discoveredLocations, isEmpty);
      expect(parsed.activeLocationId, isNull);
    });

    test('version 5 saves load with phase 6 defaults', () {
      final v5 = GameState.initial().toJson()
        ..['version'] = 5
        ..remove('raceId')
        ..remove('tournamentsWon')
        ..remove('warsWon')
        ..remove('lastTournamentAt')
        ..remove('lastWarAt');
      final parsed = GameState.fromJson(v5);
      expect(parsed.raceId, isNull);
      expect(parsed.tournamentsWon, 0);
      expect(parsed.warsWon, 0);
      expect(parsed.lastTournamentAt, isNull);
      expect(parsed.lastWarAt, isNull);
    });

    test('json roundtrip preserves race and event records', () {
      final state = GameState.initial().copyWith(
        raceId: 'demon',
        tournamentsWon: 4,
        warsWon: 2,
        lastTournamentAt: DateTime.utc(2024, 5, 5, 12),
        lastWarAt: DateTime.utc(2024, 5, 6, 8, 30),
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.raceId, 'demon');
      expect(parsed.tournamentsWon, 4);
      expect(parsed.warsWon, 2);
      expect(parsed.lastTournamentAt, state.lastTournamentAt);
      expect(parsed.lastWarAt, state.lastWarAt);
    });

    test('copyWith keeps raceId unless explicitly changed', () {
      final state = GameState.initial().copyWith(raceId: 'human');
      expect(state.copyWith(qi: 10).raceId, 'human');
      expect(state.copyWith(raceId: 'demon').raceId, 'demon');
      expect(state.copyWith(raceId: null).raceId, isNull);
    });

    test('version 6 saves load with phase 7 defaults', () {
      final v6 = GameState.initial().toJson()
        ..['version'] = 6
        ..remove('reputation');
      final parsed = GameState.fromJson(v6);
      expect(parsed.reputation, isEmpty);
    });

    test('json roundtrip preserves faction reputation', () {
      final state = GameState.initial().copyWith(
        raceId: 'demi_human',
        reputation: const {'demi_human': 720, 'human': 5},
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.reputation['demi_human'], 720);
      expect(parsed.reputation['human'], 5);
    });

    test('version 7 saves load with phase 8 defaults', () {
      final v7 = GameState.initial().toJson()
        ..['version'] = 7
        ..remove('legacyName')
        ..remove('pathPoints')
        ..remove('storyChapter')
        ..remove('storyFlags')
        ..remove('immortalized')
        ..remove('legendSeen')
        ..remove('achievedEndings')
        ..remove('pendingEndingId');
      final parsed = GameState.fromJson(v7);
      expect(parsed.legacyName, isNull);
      expect(parsed.pathPoints, isEmpty);
      expect(parsed.storyChapter, 0);
      expect(parsed.storyFlags, isEmpty);
      expect(parsed.immortalized, isFalse);
      expect(parsed.legendSeen, isFalse);
      expect(parsed.achievedEndings, isEmpty);
      expect(parsed.pendingEndingId, isNull);
    });

    test('json roundtrip preserves story and legacy', () {
      final state = GameState.initial().copyWith(
        legacyName: 'Li Wuxin',
        pathPoints: const {'heaven': 6, 'wild': 2},
        storyChapter: 3,
        storyFlags: const ['served_in_war'],
        immortalized: true,
        legendSeen: true,
        achievedEndings: const ['main_heaven'],
        pendingEndingId: 'hidden_wheel',
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.legacyName, 'Li Wuxin');
      expect(parsed.pathPoints, {'heaven': 6, 'wild': 2});
      expect(parsed.storyChapter, 3);
      expect(parsed.storyFlags, ['served_in_war']);
      expect(parsed.immortalized, isTrue);
      expect(parsed.legendSeen, isTrue);
      expect(parsed.achievedEndings, ['main_heaven']);
      expect(parsed.pendingEndingId, 'hidden_wheel');
    });

    test('version 8 saves load with phase 9 defaults', () {
      final v8 = GameState.initial().toJson()
        ..['version'] = 8
        ..remove('discoveredPowers');
      final parsed = GameState.fromJson(v8);
      expect(parsed.discoveredPowers, isEmpty);
      expect(parsed.legacyName, isNull);
      expect(parsed.immortalized, isFalse);
    });

    test('json roundtrip preserves discovered powers', () {
      final state = GameState.initial().copyWith(
        discoveredPowers: const ['phoenix_ember', 'sword_intent'],
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.discoveredPowers, ['phoenix_ember', 'sword_intent']);
    });

    test('copyWith keeps discovered powers unless replaced', () {
      final state = GameState.initial().copyWith(
        discoveredPowers: const ['void_insight'],
      );
      final kept = state.copyWith(qi: 100);
      expect(kept.discoveredPowers, ['void_insight']);
    });

    test('version 9 saves load with phase 11 defaults', () {
      final v9 = GameState.initial().toJson()
        ..['version'] = 9
        ..remove('boosts')
        ..remove('supportTier')
        ..remove('ownedCosmetics')
        ..remove('activeThemeId')
        ..remove('lastAdWatch');
      final parsed = GameState.fromJson(v9);
      expect(parsed.boosts, isEmpty);
      expect(parsed.supportTier, isFalse);
      expect(parsed.ownedCosmetics, isEmpty);
      expect(parsed.activeThemeId, isNull);
      expect(parsed.lastAdWatch, isEmpty);
    });

    test('json roundtrip preserves monetization', () {
      final state = GameState.initial().copyWith(
        boosts: [
          ActiveBoost(
            id: 'qi_incense',
            kind: 'qi',
            multiplier: 2.0,
            expiresAt: DateTime(2025, 1, 1, 20),
          ),
        ],
        supportTier: true,
        ownedCosmetics: const ['theme_ember', 'immortal_patron'],
        activeThemeId: 'theme_ember',
        lastAdWatch: {'qi_incense': DateTime(2025, 1, 1, 12).toIso8601String()},
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.boosts.length, 1);
      expect(parsed.boosts.single.id, 'qi_incense');
      expect(parsed.boosts.single.multiplier, 2.0);
      expect(parsed.boosts.single.expiresAt, DateTime(2025, 1, 1, 20));
      expect(parsed.supportTier, isTrue);
      expect(parsed.ownedCosmetics, ['theme_ember', 'immortal_patron']);
      expect(parsed.activeThemeId, 'theme_ember');
      expect(parsed.lastAdWatch['qi_incense'], DateTime(2025, 1, 1, 12).toIso8601String());
    });

    test('version 10 saves load with phase 12 defaults', () {
      final v10 = GameState.initial().toJson()
        ..['version'] = 10
        ..remove('amulet');
      final parsed = GameState.fromJson(v10);
      expect(parsed.amulet, isNull);
      expect(parsed.weapon, isNull);
      expect(parsed.armor, isNull);
    });

    test('json roundtrip preserves amulet', () {
      final state = GameState.initial().copyWith(
        amulet: Equipment.create(EquipmentSlot.amulet, 2, 123.4),
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.amulet, isNotNull);
      expect(parsed.amulet!.name, 'Earth Sigil');
      expect(parsed.amulet!.slot, EquipmentSlot.amulet);
      expect(parsed.amulet!.power, 123.4);
    });

    test('version 3 saves load with phase 4 defaults', () {
      final v3 = GameState.initial().toJson()
        ..['version'] = 3
        ..remove('soulPower')
        ..remove('reincarnations')
        ..remove('soulUpgrades')
        ..remove('sectId')
        ..remove('contribution')
        ..remove('disciples')
        ..remove('missionLog')
        ..remove('bestiary')
        ..remove('pendingEventId');
      final parsed = GameState.fromJson(v3);
      expect(parsed.soulPower, 0);
      expect(parsed.reincarnations, 0);
      expect(parsed.soulUpgrades, isEmpty);
      expect(parsed.sectId, isNull);
      expect(parsed.disciples, isEmpty);
      expect(parsed.bestiary, isEmpty);
      expect(parsed.pendingEventId, isNull);
    });

    test('version 2 saves load with phase 3 defaults', () {
      final v2 = GameState.initial().toJson()
        ..['version'] = 2
        ..remove('techniqueId')
        ..remove('discoveredTechniques')
        ..remove('companion')
        ..remove('tribulationActive')
        ..remove('tribulationLog')
        ..remove('tribulationsSurvived')
        ..remove('tribulationsFailed');
      final parsed = GameState.fromJson(v2);
      expect(parsed.techniqueId, 'basic');
      expect(parsed.discoveredTechniques, ['basic']);
      expect(parsed.companion, isNull);
      expect(parsed.tribulationActive, isFalse);
      expect(parsed.tribulationsSurvived, 0);
    });
  });

  group('phase 14 polish state', () {
    test('version 11 saves load with polish defaults', () {
      final v11 = GameState.initial().toJson()
        ..['version'] = 11
        ..remove('introSeen')
        ..remove('journal')
        ..remove('dailyLedgerClaimedOn')
        ..remove('achievements')
        ..remove('techniqueMastery')
        ..remove('audioOn');
      final parsed = GameState.fromJson(v11);
      expect(parsed.introSeen, isTrue);
      expect(parsed.journal, isEmpty);
      expect(parsed.dailyLedgerClaimedOn, -1);
      expect(parsed.achievements, isEmpty);
      expect(parsed.techniqueMastery, isEmpty);
      expect(parsed.audioOn, isTrue);
    });

    test('a fresh save asks for the intro, old saves do not', () {
      expect(GameState.initial().introSeen, isFalse);
      final returning = GameState.fromJson(
        GameState.initial().toJson()..remove('introSeen'),
      );
      expect(returning.introSeen, isTrue);
    });

    test('json roundtrip preserves the chronicle and deeds', () {
      final entryTime = DateTime(2026, 3, 10, 15, 30);
      final state = GameState.initial().copyWith(
        introSeen: false,
        audioOn: false,
        dailyLedgerClaimedOn: 20261,
        achievements: const ['first_blood', 'hunter'],
        techniqueMastery: const {'basic': 7},
        journal: [
          JournalEntry(
            time: entryTime,
            text: 'Hunt: Iron Tusk slain in Bamboo Wilds.',
          ),
          JournalEntry(
            time: entryTime,
            text: 'Deed recognized: First Blood',
          ),
        ],
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.introSeen, isFalse);
      expect(parsed.audioOn, isFalse);
      expect(parsed.dailyLedgerClaimedOn, 20261);
      expect(parsed.achievements, ['first_blood', 'hunter']);
      expect(parsed.techniqueMastery, {'basic': 7});
      expect(parsed.journal, hasLength(2));
      expect(
        parsed.journal.first.text,
        'Hunt: Iron Tusk slain in Bamboo Wilds.',
      );
      expect(parsed.journal.first.time, entryTime);
    });

    test('version marker is 13', () {
      expect(GameState.initial().toJson()['version'], 13);
    });
  });

  group('phase 17 living sects state', () {
    test('version 12 saves load with phase 17 defaults', () {
      final v12 = GameState.initial().toJson()
        ..['version'] = 12
        ..remove('sectTasks')
        ..remove('sectBetrayed')
        ..remove('sectRankAchieved');
      final parsed = GameState.fromJson(v12);
      expect(parsed.sectTasks, isEmpty);
      expect(parsed.sectBetrayed, isEmpty);
      expect(parsed.sectRankAchieved, 0);
    });

    test('json roundtrip preserves sect tasks and betrayer marks', () {
      final state = GameState.initial().copyWith(
        sectId: 'sword_sect',
        sectRankAchieved: 2,
        sectBetrayed: const ['pill_valley'],
        sectTasks: [
          const ActiveTask(
            typeId: 'beast_hunt',
            target: 5,
            progress: 3,
            contribution: 25,
            reputation: 10,
            stones: 50,
          ),
        ],
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.sectId, 'sword_sect');
      expect(parsed.sectRankAchieved, 2);
      expect(parsed.sectBetrayed, ['pill_valley']);
      expect(parsed.sectTasks, hasLength(1));
      expect(parsed.sectTasks.first.typeId, 'beast_hunt');
      expect(parsed.sectTasks.first.progress, 3);
      expect(parsed.sectTasks.first.complete, isFalse);
    });
  });
}
