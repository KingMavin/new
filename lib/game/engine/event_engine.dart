import 'dart:math';

import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/sect.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/game/util/format.dart';

class EventChoice {
  final String label;
  final double stonesFactor;
  final double stonesCostFactor;
  final int herbs;
  final int herbCost;
  final int cores;
  final int coreCost;
  final int qiMinutes;
  final int lifespanYears;
  final int qiPills;
  final bool gamble;
  final String? flag;
  final double stonesFlatCost;
  final String? raceChangeTo;

  const EventChoice({
    required this.label,
    this.stonesFactor = 0,
    this.stonesCostFactor = 0,
    this.herbs = 0,
    this.herbCost = 0,
    this.cores = 0,
    this.coreCost = 0,
    this.qiMinutes = 0,
    this.lifespanYears = 0,
    this.qiPills = 0,
    this.gamble = false,
    this.flag,
    this.stonesFlatCost = 0,
    this.raceChangeTo,
  });
}

class GameEvent {
  final String id;
  final String title;
  final String description;
  final List<EventChoice> choices;

  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
  });
}

class EventOutcome {
  final GameState state;
  final String message;

  const EventOutcome({required this.state, required this.message});
}

class EventEngine {
  static const double triggerChance = 0.15;
  static const double gambleSuccessChance = 0.5;

  static const List<GameEvent> catalog = [
    GameEvent(
      id: 'ancient_tomb',
      title: 'A Crumbling Tomb',
      description:
          'You stumble upon a tomb half-swallowed by the earth. Ancient '
          'wards still flicker over its entrance.',
      choices: [
        EventChoice(
          label: 'Brave the wards',
          stonesFactor: 3,
          gamble: true,
        ),
        EventChoice(label: 'Salvage the outer shrine', stonesFactor: 0.5),
      ],
    ),
    GameEvent(
      id: 'spirit_spring',
      title: 'Hidden Spirit Spring',
      description:
          'Silver water bubbles up from a spring humming with spiritual '
          'energy.',
      choices: [
        EventChoice(label: 'Drink deeply', qiMinutes: 30),
        EventChoice(label: 'Bottle the water', herbs: 2),
      ],
    ),
    GameEvent(
      id: 'wandering_merchant',
      title: 'Wandering Merchant',
      description:
          'A masked merchant spreads out a mat of curiosities, eyes '
          'gleaming above a knowing smile.',
      choices: [
        EventChoice(
          label: 'Buy a case of herbs',
          stonesCostFactor: 1,
          herbs: 5,
        ),
        EventChoice(label: 'Sell a beast core', cores: -1, stonesFactor: 1.5),
        EventChoice(label: 'Trade words, not wares', qiMinutes: 5),
      ],
    ),
    GameEvent(
      id: 'beggar_sage',
      title: 'The Beggar Sage',
      description:
          'A ragged old man blocks the road, palm outstretched. His eyes '
          'hold a startling depth.',
      choices: [
        EventChoice(
          label: 'Offer spirit stones',
          stonesCostFactor: 0.5,
          qiPills: 1,
        ),
        EventChoice(label: 'Bow and pass by', qiMinutes: 5),
      ],
    ),
    GameEvent(
      id: 'bandit_ambush',
      title: 'Bandit Ambush',
      description:
          'Rough men drop from the trees, blades bared. "Your pouch or '
          'your life, cultivator."',
      choices: [
        EventChoice(
          label: 'Cut them down',
          stonesFactor: 2,
          gamble: true,
        ),
        EventChoice(label: 'Pay the toll', stonesCostFactor: 1),
      ],
    ),
    GameEvent(
      id: 'fallen_cultivator',
      title: 'Fallen Cultivator',
      description:
          'A corpse in scorched robes lies in a crater, storage pouch '
          'still intact.',
      choices: [
        EventChoice(
          label: 'Take the pouch',
          stonesFactor: 1.5,
          cores: 1,
          gamble: true,
        ),
        EventChoice(label: 'Bury the body', qiMinutes: 10),
      ],
    ),
    GameEvent(
      id: 'wild_garden',
      title: 'Wild Herb Garden',
      description:
          'A terraced garden of spirit herbs grows wild on the cliffside, '
          'clearly tended by no one for years.',
      choices: [
        EventChoice(label: 'Harvest freely', herbs: 3),
        EventChoice(label: 'Tend the garden', herbs: 1, qiMinutes: 10),
      ],
    ),
    GameEvent(
      id: 'dragon_bones',
      title: 'Dragon Bones',
      description:
          'A colossal skeleton arches over the valley, each scale the '
          'size of a shield. Qi pools in its hollows.',
      choices: [
        EventChoice(label: 'Meditate among the bones', qiMinutes: 60),
        EventChoice(
          label: 'Pry loose a scale',
          cores: 2,
          gamble: true,
        ),
      ],
    ),
    GameEvent(
      id: 'lost_child',
      title: 'Lost Child',
      description:
          'A village child weeps by the trail, lost since dawn. Beast '
          'growls echo nearby.',
      choices: [
        EventChoice(
          label: 'Escort them home',
          stonesCostFactor: 0.5,
          lifespanYears: 5,
        ),
        EventChoice(label: 'Point the way', qiMinutes: 5),
      ],
    ),
    GameEvent(
      id: 'secret_auction',
      title: 'Secret Auction',
      description:
          'Behind a tavern, bidders in cloaks raise jade tokens. A pill '
          'that "rewinds age" sits on the block.',
      choices: [
        EventChoice(
          label: 'Bid everything',
          stonesCostFactor: 2,
          qiPills: 2,
          gamble: true,
        ),
        EventChoice(label: 'Listen and learn', qiMinutes: 15),
      ],
    ),
    GameEvent(
      id: 'thunder_cave',
      title: 'Thunder Cave',
      description:
          'Lightning arcs inside a cave mouth, striking a pool of '
          'magnetized stone. A perfect training ground — or an early grave.',
      choices: [
        EventChoice(
          label: 'Train in the lightning',
          qiMinutes: 45,
          stonesFactor: 1,
          gamble: true,
        ),
        EventChoice(label: 'Rest at the entrance', qiMinutes: 15),
      ],
    ),
    GameEvent(
      id: 'old_monk',
      title: 'The Old Monk',
      description:
          'A monk sweeps a mountain step, though no temple stands above. '
          'He gestures for you to sit.',
      choices: [
        EventChoice(
          label: 'Hear his sutra',
          qiMinutes: 20,
          lifespanYears: 10,
        ),
        EventChoice(label: 'Share your provisions', herbCost: 1, qiMinutes: 30),
      ],
    ),
    GameEvent(
      id: 'the_beggar',
      title: 'The Beggar at the Shrine',
      description:
          'At a crumbling roadside shrine you find a beggar with eyes '
          'like old coins. He asks not for charity but for everything: '
          '\u201cEmpty your purse into my bowl, cultivator, and heaven '
          'will owe you a kindness. Keep your stones, and we speak of '
          'this never.\u201d',
      choices: [
        EventChoice(
          label: 'Empty your purse into his bowl',
          stonesCostFactor: 1.0,
          flag: 'gave_everything',
        ),
        EventChoice(
          label: 'Turn away and keep walking',
        ),
      ],
    ),
    GameEvent(
      id: 'faceless_messenger',
      title: 'The Faceless Messenger',
      description:
          'A masked alchemist waits at your gate with a cauldron of '
          'moon-pale reagent. \u201cFlesh is a polymer, blood is an ink '
          'that can be rewritten. I can reforge you into any of the '
          'three peoples \u2014 for five thousand spirit stones, the '
          'burn of a lifetime, and one certainty: the people you leave '
          'will hate you for it.\u201d',
      choices: [
        EventChoice(
          label: 'Reforge as Human',
          stonesFlatCost: 5000,
          raceChangeTo: 'human',
        ),
        EventChoice(
          label: 'Reforge as Demon',
          stonesFlatCost: 5000,
          raceChangeTo: 'demon',
        ),
        EventChoice(
          label: 'Reforge as Demi-human',
          stonesFlatCost: 5000,
          raceChangeTo: 'demi_human',
        ),
        EventChoice(
          label: 'Refuse — your blood is your own',
        ),
      ],
    ),
  ];

  static GameEvent? byId(String id) {
    for (final event in catalog) {
      if (event.id == id) return event;
    }
    return null;
  }

  static String? maybeTrigger(GameState state, {Random? rng}) {
    if (state.pendingEventId != null) return null;
    final random = rng ?? Random();
    if (random.nextDouble() >= triggerChance) return null;
    return catalog[random.nextInt(catalog.length)].id;
  }

  static EventOutcome? resolve(
    GameState state,
    String eventId,
    int choiceIndex,
    WorldLocation location, {
    Random? rng,
    double? roll,
  }) {
    final event = byId(eventId);
    if (event == null) return null;
    if (choiceIndex < 0 || choiceIndex >= event.choices.length) return null;
    final choice = event.choices[choiceIndex];
    final random = rng ?? Random();

    final stoneCost = location.spiritStoneReward * choice.stonesCostFactor +
        choice.stonesFlatCost;
    if (stoneCost > 0 && state.spiritStones < stoneCost) {
      return EventOutcome(
        state: state,
        message: 'You lack the spirit stones for that.',
      );
    }
    if (choice.herbCost > 0 && state.spiritHerbs < choice.herbCost) {
      return EventOutcome(
        state: state,
        message: 'You lack the spirit herbs for that.',
      );
    }
    final coresSpent = choice.coreCost + (choice.cores < 0 ? -choice.cores : 0);
    if (coresSpent > 0 && state.beastCores < coresSpent) {
      return EventOutcome(
        state: state,
        message: 'You lack the beast cores for that.',
      );
    }

    final success = !choice.gamble || (roll ?? random.nextDouble()) < gambleSuccessChance;

    var stones = state.spiritStones - stoneCost;
    var herbs = state.spiritHerbs - choice.herbCost;
    var cores = state.beastCores - coresSpent;
    var qiPills = state.qiPills;
    var qi = state.qi;
    var lifespan = state.lifespanBonusYears;
    final parts = <String>[];

    if (success) {
      final stoneGain = location.spiritStoneReward * choice.stonesFactor;
      if (stoneGain > 0) {
        stones += stoneGain;
        parts.add('+${formatNumber(stoneGain)} spirit stones');
      }
      if (choice.herbs > 0) {
        herbs += choice.herbs;
        parts.add('+${choice.herbs} spirit herb(s)');
      }
      if (choice.cores > 0) {
        cores += choice.cores;
        parts.add('+${choice.cores} beast core(s)');
      }
      if (choice.cores < 0) {
        parts.add('sold a beast core');
      }
      if (choice.qiMinutes > 0) {
        final gain = CultivationEngine.qiPerSecond(state) * choice.qiMinutes * 60;
        qi += gain;
        parts.add('+${formatNumber(gain)} qi');
      }
      if (choice.lifespanYears > 0) {
        lifespan += choice.lifespanYears;
        parts.add('+${choice.lifespanYears} years of life');
      }
      if (choice.qiPills > 0) {
        qiPills += choice.qiPills;
        parts.add('+${choice.qiPills} qi pill(s)');
      }
    } else {
      parts.add('Fortune abandoned you this time');
    }

    var updated = state.copyWith(
      spiritStones: stones,
      spiritHerbs: herbs,
      beastCores: cores,
      qiPills: qiPills,
      qi: qi,
      totalQiGained: state.totalQiGained + (qi - state.qi),
      lifespanBonusYears: lifespan,
      lastSaved: DateTime.now(),
    );
    if (success &&
        choice.flag != null &&
        !updated.storyFlags.contains(choice.flag)) {
      updated = updated.copyWith(
        storyFlags: [...updated.storyFlags, choice.flag!],
      );
    }
    if (success &&
        choice.raceChangeTo != null &&
        choice.raceChangeTo != updated.raceId) {
      final oldRace = updated.raceId;
      final reputation = {...updated.reputation};
      if (oldRace != null) reputation[oldRace] = -200;
      updated = updated.copyWith(
        raceId: choice.raceChangeTo,
        reputation: reputation,
        storyChapter: 0,
      );
      if (oldRace != null && updated.sectId != null) {
        final sect = Sect.byId(updated.sectId!);
        if (sect.factionId == oldRace) {
          reputation[oldRace] = (reputation[oldRace] ?? 0) - 60;
          updated = updated.copyWith(
            sectId: null,
            contribution: 0,
            disciples: const [],
            missionLog: const [],
            sectBetrayed: [...updated.sectBetrayed, sect.id],
            sectRankAchieved: 0,
            sectTasks: const [],
            reputation: reputation,
          );
          parts.add(
            'the ${sect.name} strike your name from the rolls '
            'of their own people',
          );
        }
      }
      parts.add(
        'your flesh is reforged — you are now '
        '${choice.raceChangeTo == 'human'
            ? 'Human'
            : choice.raceChangeTo == 'demon'
                ? 'Demon'
                : 'Demi-human'}; your old people brand you a traitor',
      );
    }

    final prefix = success
        ? (choice.gamble ? 'Fortune smiled on you! ' : '')
        : 'It went poorly. ';
    return EventOutcome(
      state: updated,
      message: '$prefix${parts.isEmpty ? 'Nothing came of it.' : parts.join(', ')}.',
    );
  }
}
