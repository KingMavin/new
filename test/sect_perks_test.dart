import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/forge_engine.dart';
import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/tribulation_engine.dart';
import 'package:immortal_path/game/engine/tournament_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/forge.dart';
import 'package:immortal_path/game/models/sect.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

GameState seated(String sectId, {int realmIndex = 3}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    stageIndex: 0,
    sectId: sectId,
    contribution: 100,
  );
}

void main() {
  group('sect perks are unique and labeled', () {
    test('every sect carries exactly one distinct perk line', () {
      final perks = Sect.catalog.map((sect) => sect.perkLabel).toSet();
      expect(perks.length, Sect.catalog.length);
      for (final sect in Sect.catalog) {
        expect(sect.perkLabel, isNotEmpty);
      }
    });
  });

  group('Blade Doctrine \u2014 sword sect', () {
    test('tournament contribution is multiplied for sword sect only', () {
      final plain = GameState.initial().copyWith(realmIndex: 3);
      final sword = plain.copyWith(sectId: 'sword_sect');
      expect(TournamentEngine.prizeContribution(plain), 60);
      expect(TournamentEngine.prizeContribution(sword), 90);
    });
  });

  group('Array Warding \u2014 formation hall', () {
    test('tribulations begin one wave fewer, never below two', () {
      final plain = TribulationEngine.begin(
        GameState.initial().copyWith(realmIndex: 0, qi: 10),
      );
      final warded = TribulationEngine.begin(
        GameState.initial()
            .copyWith(realmIndex: 0, qi: 10)
            .copyWith(sectId: 'formation_hall'),
      );
      expect(plain.tribulationWavesTotal, 3);
      expect(warded.tribulationWavesTotal, 2);
      expect(
        SectEngine.tribulationWaveRelief(seated('nightveil_bureau')),
        0,
      );
    });
  });

  group('Physician\u2019s Grace \u2014 imperial herbal court', () {
    test('brew double chance applies to the herbal court only', () {
      expect(SectEngine.brewDoubleChance(seated('imperial_herbal_court')), 0.30);
      expect(SectEngine.brewDoubleChance(seated('pill_valley')), 0.0);
      expect(SectEngine.brewDoubleChance(GameState.initial()), 0.0);
    });
  });

  group('Furnace Oath \u2014 blood furnace clan', () {
    test('a borderline forge roll succeeds for the clan and fails otherwise', () {
      final recipe = ForgeCatalog.recipeById('forge_earth_weapon')!;
      final mortal = GameState.initial().copyWith(realmIndex: 2);
      final smith = mortal.copyWith(sectId: 'blood_furnace_clan');
      expect(ForgeEngine.attempt(mortal, recipe, roll: 0.65).success, isFalse);
      expect(ForgeEngine.attempt(smith, recipe, roll: 0.65).success, isTrue);
      expect(ForgeEngine.attempt(smith, recipe, roll: 0.75).success, isFalse);
    });
  });

  group('Elixir Refinement \u2014 pill valley', () {
    test('pill potency bonus applies to pill valley only', () {
      expect(SectEngine.pillValueBonus(seated('pill_valley')), 0.25);
      expect(SectEngine.pillValueBonus(seated('sword_sect')), 0.0);
      expect(SectEngine.pillValueBonus(GameState.initial()), 0.0);
    });
  });

  group('Omen Files \u2014 nightveil bureau', () {
    test('discovery scale is 1.5 for the bureau only', () {
      expect(SectEngine.discoveryScale(seated('nightveil_bureau')), 1.5);
      expect(SectEngine.discoveryScale(seated('formation_hall')), 1.0);
    });

    test('the same luck finds at least as many powers with the scale', () {
      final location = WorldCatalog.standardLocations().first;
      final plain = GameState.initial();
      final bureau = plain.copyWith(sectId: 'nightveil_bureau');
      var plainCount = 0;
      var bureauCount = 0;
      for (var i = 0; i < 20000; i++) {
        if (PowerEngine.rollDiscovery(plain, location, Random(i)) != null) {
          plainCount++;
        }
        if (PowerEngine.rollDiscovery(bureau, location, Random(i)) != null) {
          bureauCount++;
        }
      }
      expect(bureauCount, greaterThanOrEqualTo(plainCount));
      expect(plainCount, greaterThan(0));
    });
  });

  group('Pack Bond \u2014 beast court', () {
    test('companion bonuses count double for the beast court', () {
      expect(SectEngine.companionScale(seated('beast_court')), 2.0);
      expect(SectEngine.companionScale(seated('sword_sect')), 1.0);
      final bonded = GameState.initial().copyWith(
        realmIndex: 3,
        companion: const Companion(
          name: 'Cinderpaw',
          bonusType: 'attack',
          level: 4,
        ),
      );
      final plain = CombatEngine.playerAttack(bonded);
      final doubled = CombatEngine.playerAttack(
        bonded.copyWith(sectId: 'beast_court'),
      );
      expect(doubled, greaterThan(plain));

      final qiPlain = CultivationEngine.qiPerSecond(
        bonded.copyWith(
          companion: const Companion(
            name: 'Mistfinch',
            bonusType: 'qi',
            level: 4,
          ),
        ),
      );
      final qiDoubled = CultivationEngine.qiPerSecond(
        bonded.copyWith(
          sectId: 'beast_court',
          companion: const Companion(
            name: 'Mistfinch',
            bonusType: 'qi',
            level: 4,
          ),
        ),
      );
      expect(qiDoubled, greaterThan(qiPlain));
    });
  });

  group('Root Patience \u2014 verdant grove', () {
    test('hunt loot stones gain 20% for the grove only', () {
      expect(SectEngine.lootStonesBonus(seated('verdant_grove')), 0.20);
      expect(SectEngine.lootStonesBonus(seated('pill_valley')), 0.0);
      final location = WorldCatalog.standardLocations().first;
      final beast = const Beast(
        name: 'Test Tusker',
        hp: 100,
        attack: 10,
        defense: 5,
        bonusType: 'attack',
      );
      final plain = CombatEngine.rollLoot(
        GameState.initial().copyWith(realmIndex: 1),
        location,
        beast,
        Random(9),
      ).spiritStones;
      final grove = CombatEngine.rollLoot(
        GameState.initial()
            .copyWith(realmIndex: 1)
            .copyWith(sectId: 'verdant_grove'),
        location,
        beast,
        Random(9),
      ).spiritStones;
      expect(grove, closeTo(plain * 1.2, 0.01));
    });
  });

  group('Storm Grammar \u2014 wind speaker circle', () {
    test('cooldowns run at three quarters length for the circle', () {
      expect(SectEngine.cooldownScale(seated('wind_speaker_circle')), 0.75);
      expect(SectEngine.cooldownScale(seated('sword_sect')), 1.0);
      expect(
        TournamentEngine.cooldown * SectEngine.cooldownScale(
          seated('wind_speaker_circle'),
        ),
        const Duration(minutes: 45),
      );
    });
  });
}
