import 'dart:math';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

class EncounterChoice {
  final String label;
  final String successText;
  final String failText;
  final double damageMultiplier;
  final double selfDamageFraction;
  final double baseChance;
  final bool isFlee;

  const EncounterChoice({
    required this.label,
    required this.successText,
    required this.failText,
    this.damageMultiplier = 0,
    this.selfDamageFraction = 0,
    this.baseChance = 1,
    this.isFlee = false,
  });
}

class EncounterMoment {
  final String title;
  final String text;
  final List<EncounterChoice> choices;

  const EncounterMoment({
    required this.title,
    required this.text,
    required this.choices,
  });
}

class EncounterState {
  final Beast beast;
  final double foeHp;
  final double foeMaxHp;
  final double playerHp;
  final double playerMaxHp;
  final int round;
  final List<String> log;
  final bool finished;
  final bool victory;
  final bool fled;
  final EncounterMoment? pendingMoment;

  const EncounterState({
    required this.beast,
    required this.foeHp,
    required this.foeMaxHp,
    required this.playerHp,
    required this.playerMaxHp,
    required this.round,
    required this.log,
    this.finished = false,
    this.victory = false,
    this.fled = false,
    this.pendingMoment,
  });

  double get foeHpFraction => foeMaxHp <= 0 ? 0 : (foeHp / foeMaxHp).clamp(0, 1);
  double get playerHpFraction =>
      playerMaxHp <= 0 ? 0 : (playerHp / playerMaxHp).clamp(0, 1);
}

class EncounterEngine {
  static const int maxRounds = 100;
  static const double momentChance = 0.35;
  static const double desperateHpFraction = 0.4;
  static const double finishingFoeHpFraction = 0.3;

  static const List<String> _strikeVerbs = [
    'You close the distance and strike',
    'Your palm splits the air as you strike',
    'Qi coils around your fist as you strike',
    'You weave through its guard and strike',
  ];

  static const List<String> _foeVerbs = [
    'rakes at you',
    'lunges at you',
    'smashes toward you',
    'slashes at you',
  ];

  static EncounterState begin(
    GameState state,
    Beast beast, {
    EncounterMoment? opening,
    List<String> introLines = const [],
  }) {
    final playerMaxHp = CombatEngine.playerMaxHp(state);
    final log = introLines.isEmpty
        ? [
            'You are deep in the wilds when the ${beast.name} marks you as '
                'prey.',
            'The ${beast.name} attacks!',
          ]
        : List<String>.from(introLines);
    return EncounterState(
      beast: beast,
      foeHp: beast.hp,
      foeMaxHp: beast.hp,
      playerHp: playerMaxHp,
      playerMaxHp: playerMaxHp,
      round: 0,
      log: log,
      pendingMoment: opening ?? _openingMoment(beast),
    );
  }

  static EncounterMoment _openingMoment(Beast beast) {
    return EncounterMoment(
      title: 'First Contact',
      text:
          'The ${beast.name} lowers its body, muscles coiling. You have '
          'the space of a heartbeat to decide how this fight begins.',
      choices: const [
        EncounterChoice(
          label: 'Stand your ground',
          successText:
              'You plant your feet and meet its charge head-on, turning '
              'its momentum into an opening.',
          failText:
              'Its charge crashes through your guard and sends you '
              'skidding back.',
          damageMultiplier: 1.2,
          selfDamageFraction: 0.1,
          baseChance: 0.7,
        ),
        EncounterChoice(
          label: 'Strike first',
          successText:
              'You explode forward before it can move, your blow landing '
              'clean between its ribs.',
          failText:
              'It readies the strike \u2014 your rush meets a swipe that '
              'hurls you aside.',
          damageMultiplier: 1.8,
          selfDamageFraction: 0.2,
          baseChance: 0.5,
        ),
        EncounterChoice(
          label: 'Circle cautiously',
          successText:
              'You give ground smoothly, reading its rhythm and picking '
              'your moment.',
          failText:
              'You give ground too slowly \u2014 a glancing blow still '
              'finds you.',
          damageMultiplier: 0.6,
          selfDamageFraction: 0.05,
          baseChance: 0.85,
        ),
      ],
    );
  }

  static EncounterMoment? _momentFor(
    EncounterState encounter,
    GameState state,
    Random random,
  ) {
    if (encounter.playerHp <= encounter.playerMaxHp * desperateHpFraction) {
      return const EncounterMoment(
        title: 'Desperate Straits',
        text:
            'Blood sheets your side and your meridians burn. One mistake '
            'now and this wilderness becomes your tomb.',
        choices: [
          EncounterChoice(
            label: 'Burning core burst',
            successText:
                'You ignite your dantian past all safety. The explosion of '
                'qi tears across the battlefield.',
            failText:
                'The burst gutters \u2014 backlash scours your channels as '
                'the beast closes in.',
            damageMultiplier: 2.5,
            selfDamageFraction: 0.25,
            baseChance: 0.45,
          ),
          EncounterChoice(
            label: 'Turtle stance',
            successText:
                'You fold into pure defense, weathering the storm until '
                'your qi settles.',
            failText:
                'Even your guard is battered loose by the beast\u2019s '
                'frenzy.',
            damageMultiplier: 0.4,
            selfDamageFraction: 0.03,
            baseChance: 0.85,
          ),
          EncounterChoice(
            label: 'Flee with your life',
            successText:
                'You burn qi in a single burst of speed and vanish into '
                'the terrain, alive but empty-handed.',
            failText:
                'It cuts off your retreat \u2014 you must turn and fight '
                'after all.',
            isFlee: true,
            baseChance: 0.6,
          ),
        ],
      );
    }
    if (encounter.foeHp <= encounter.foeMaxHp * finishingFoeHpFraction) {
      return EncounterMoment(
        title: 'Blood in the Air',
        text:
            'The ${encounter.beast.name} staggers, breath ragged, its '
            'aura flickering. It is beaten \u2014 but a wounded beast is '
            'the most dangerous thing in the world.',
        choices: const [
          EncounterChoice(
            label: 'All-out finish',
            successText:
                'You abandon all defense and pour everything into one '
                'decisive blow.',
            failText:
                'Your lunge overcommits \u2014 its last flare of strength '
                'catches you fully.',
            damageMultiplier: 2.2,
            selfDamageFraction: 0.15,
            baseChance: 0.6,
          ),
          EncounterChoice(
            label: 'Cautious press',
            successText:
                'You advance step by measured step, denying it room to '
                'recover.',
            failText:
                'It lashes out with dying fury and clips you as you '
                'close in.',
            damageMultiplier: 0.9,
            selfDamageFraction: 0.05,
            baseChance: 0.85,
          ),
        ],
      );
    }
    if (encounter.round >= 2 && random.nextDouble() < momentChance) {
      return _techniqueMoment(state, encounter.beast);
    }
    return null;
  }

  static EncounterMoment? _techniqueMoment(GameState state, Beast beast) {
    switch (state.techniqueId) {
      case 'flame':
        return EncounterMoment(
          title: 'Opening: Flame Meridian Art',
          text:
              'Fire qi floods your meridians. The ${beast.name} flinches '
              'at the heat rolling off your skin \u2014 now or never.',
          choices: const [
            EncounterChoice(
              label: 'Erupt in flame',
              successText:
                  'A river of fire leaves your palms and washes over the '
                  'beast.',
              failText:
                  'The flame sputters; its pounce drives you back through '
                  'a copse of trees.',
              damageMultiplier: 2.0,
              selfDamageFraction: 0.15,
              baseChance: 0.55,
            ),
            EncounterChoice(
              label: 'Hold the fire in reserve',
              successText:
                  'You bank the flame into your core, letting its warmth '
                  'mend your bruises.',
              failText:
                  'The unruly qi scatters uselessly into the air.',
              damageMultiplier: 0.2,
              selfDamageFraction: 0.0,
              baseChance: 0.9,
            ),
          ],
        );
      case 'iron':
        return EncounterMoment(
          title: 'Opening: Iron Body Sutra',
          text:
              'Your flesh hardens like quenched steel. The '
              '${beast.name}\u2019s claws screech off you \u2014 it is '
              'starting to fear you.',
          choices: const [
            EncounterChoice(
              label: 'Unmovable mountain',
              successText:
                  'You let the beast break itself against your body, '
                  'then answer with a hammering counter.',
              failText:
                  'The impact still rings through your hardened frame and '
                  'numbs your limbs.',
              damageMultiplier: 1.4,
              selfDamageFraction: 0.03,
              baseChance: 0.8,
            ),
            EncounterChoice(
              label: 'Grinding advance',
              successText:
                  'Step by step you herd it against the terrain, '
                  'grinding down its strength.',
              failText:
                  'It slips your pressure and circles behind you.',
              damageMultiplier: 0.7,
              selfDamageFraction: 0.05,
              baseChance: 0.9,
            ),
          ],
        );
      case 'sword':
        return EncounterMoment(
          title: 'Opening: Sword Heart Sutra',
          text:
              'The world narrows to a single line \u2014 your blade\u2019s '
              'path to the ${beast.name}\u2019s throat.',
          choices: const [
            EncounterChoice(
              label: 'Sword heart slash',
              successText:
                  'One breath, one cut. The stroke lands before sound '
                  'itself can follow it.',
              failText:
                  'The beast reads the draw and twists aside, claws '
                  'opening your shoulder.',
              damageMultiplier: 2.4,
              selfDamageFraction: 0.2,
              baseChance: 0.5,
            ),
            EncounterChoice(
              label: 'Blade wheel defense',
              successText:
                  'Your sword becomes a circle of steel that no claw '
                  'can pass.',
              failText:
                  'A feint slips through your wheel and bites your hip.',
              damageMultiplier: 0.5,
              selfDamageFraction: 0.04,
              baseChance: 0.85,
            ),
          ],
        );
      case 'formation':
        return EncounterMoment(
          title: 'Opening: Mystic Formation Art',
          text:
              'Your fingers blur through seals. Threads of light stitch '
              'themselves into the air around the ${beast.name}.',
          choices: const [
            EncounterChoice(
              label: 'Bind it in formation',
              successText:
                  'The array snaps shut like a cage of light \u2014 for a '
                  'few precious breaths, the beast cannot move.',
              failText:
                  'The beast shatters the half-formed array, and the '
                  'rebound scorches your meridians.',
              damageMultiplier: 1.6,
              selfDamageFraction: 0.1,
              baseChance: 0.65,
            ),
            EncounterChoice(
              label: 'Drain its qi',
              successText:
                  'The formation leaches its strength into your own '
                  'meridians.',
              failText:
                  'It tears free before the drain takes hold.',
              damageMultiplier: 0.9,
              selfDamageFraction: 0.04,
              baseChance: 0.8,
            ),
          ],
        );
      case 'thunder':
        return EncounterMoment(
          title: 'Opening: Thunder Refining Sutra',
          text:
              'Static crawls across your skin. Above the canopy, clouds '
              'answer your call with a low growl.',
          choices: const [
            EncounterChoice(
              label: 'Call down lightning',
              successText:
                  'Heaven answers. A pillar of lightning drops through '
                  'the beast and the world goes white.',
              failText:
                  'The bolt scatters wide \u2014 the recoil numbs your '
                  'sword arm.',
              damageMultiplier: 2.6,
              selfDamageFraction: 0.22,
              baseChance: 0.5,
            ),
            EncounterChoice(
              label: 'Cloak yourself in thunder',
              successText:
                  'Lightning sheathes your body, and your next movement '
                  'cracks like a whip.',
              failText:
                  'The thunder disperses harmlessly into the ground.',
              damageMultiplier: 1.0,
              selfDamageFraction: 0.05,
              baseChance: 0.8,
            ),
          ],
        );
      default:
        return EncounterMoment(
          title: 'Exchange of Blows',
          text:
              'You and the ${beast.name} circle one another, each '
              'hunting for an opening in the other\u2019s guard.',
          choices: const [
            EncounterChoice(
              label: 'Feint and strike',
              successText:
                  'Your feint pulls its guard wide and your true strike '
                  'lands deep.',
              failText:
                  'It ignores the feint and punishes your exposed flank.',
              damageMultiplier: 1.5,
              selfDamageFraction: 0.12,
              baseChance: 0.6,
            ),
            EncounterChoice(
              label: 'Measured defense',
              successText:
                  'You refuse the bait, conserving strength and letting '
                  'it tire first.',
              failText:
                  'Its patience matches yours, and its claws find a gap.',
              damageMultiplier: 0.5,
              selfDamageFraction: 0.05,
              baseChance: 0.85,
            ),
          ],
        );
    }
  }

  static double _choiceChance(
    EncounterChoice choice,
    GameState state,
    Beast beast,
  ) {
    if (choice.isFlee) {
      final defense = CombatEngine.playerDefense(state);
      final chance =
          choice.baseChance + 0.1 * (defense / beast.attack - 1.0);
      return chance.clamp(0.2, 0.9).toDouble();
    }
    final attack = CombatEngine.playerAttack(state);
    final chance =
        choice.baseChance + 0.1 * (attack / beast.attack - 1.0);
    return chance.clamp(0.15, 0.9).toDouble();
  }

  static EncounterState choose(
    EncounterState encounter,
    GameState state,
    int choiceIndex, {
    Random? rng,
    double? roll,
  }) {
    final moment = encounter.pendingMoment;
    if (moment == null || encounter.finished) return encounter;
    if (choiceIndex < 0 || choiceIndex >= moment.choices.length) {
      return encounter;
    }
    final choice = moment.choices[choiceIndex];
    final random = rng ?? Random();
    final success =
        (roll ?? random.nextDouble()) < _choiceChance(choice, state, encounter.beast);
    final log = List<String>.from(encounter.log);

    if (choice.isFlee) {
      if (success) {
        log.add(choice.successText);
        return EncounterState(
          beast: encounter.beast,
          foeHp: encounter.foeHp,
          foeMaxHp: encounter.foeMaxHp,
          playerHp: encounter.playerHp,
          playerMaxHp: encounter.playerMaxHp,
          round: encounter.round,
          log: log,
          finished: true,
          fled: true,
        );
      }
      log.add(choice.failText);
      return _afterPlayerAction(
        encounter,
        log: log,
      );
    }

    if (success) {
      final damage =
          choice.damageMultiplier * CombatEngine.playerAttack(state);
      final foeHp = encounter.foeHp - damage;
      log.add('${choice.successText} (-${damage.toStringAsFixed(1)} to the '
          '${encounter.beast.name})');
      if (foeHp <= 0) {
        log.add('The ${encounter.beast.name} collapses at your feet.');
        return EncounterState(
          beast: encounter.beast,
          foeHp: 0,
          foeMaxHp: encounter.foeMaxHp,
          playerHp: encounter.playerHp,
          playerMaxHp: encounter.playerMaxHp,
          round: encounter.round,
          log: log,
          finished: true,
          victory: true,
        );
      }
      return _afterPlayerAction(
        encounter,
        log: log,
        foeHp: foeHp,
      );
    }

    final selfDamage =
        choice.selfDamageFraction * encounter.playerMaxHp;
    final playerHp = encounter.playerHp - selfDamage;
    log.add('${choice.failText} (-${selfDamage.toStringAsFixed(1)} to you)');
    if (playerHp <= 0) {
      log.add('Your legs give out. Everything goes dark.');
      return EncounterState(
        beast: encounter.beast,
        foeHp: encounter.foeHp,
        foeMaxHp: encounter.foeMaxHp,
        playerHp: 0,
        playerMaxHp: encounter.playerMaxHp,
        round: encounter.round,
        log: log,
        finished: true,
      );
    }
    return _afterPlayerAction(
      encounter,
      log: log,
      playerHp: playerHp,
    );
  }

  static EncounterState advance(
    EncounterState encounter,
    GameState state, {
    Random? rng,
  }) {
    if (encounter.finished || encounter.pendingMoment != null) {
      return encounter;
    }
    final random = rng ?? Random();
    final attack = CombatEngine.playerAttack(state);
    final defense = CombatEngine.playerDefense(state);
    var foeHp = encounter.foeHp;
    var playerHp = encounter.playerHp;
    final log = List<String>.from(encounter.log);

    final verb = _strikeVerbs[random.nextInt(_strikeVerbs.length)];
    final playerDamage =
        max(1.0, attack - encounter.beast.defense) *
            (0.85 + random.nextDouble() * 0.3);
    foeHp -= playerDamage;
    log.add(
      '$verb the ${encounter.beast.name} for '
      '${playerDamage.toStringAsFixed(1)} damage.',
    );
    if (foeHp <= 0) {
      log.add('The ${encounter.beast.name} collapses, its qi dispersing '
          'into the air.');
      return EncounterState(
        beast: encounter.beast,
        foeHp: 0,
        foeMaxHp: encounter.foeMaxHp,
        playerHp: playerHp,
        playerMaxHp: encounter.playerMaxHp,
        round: encounter.round + 1,
        log: log,
        finished: true,
        victory: true,
      );
    }

    final foeVerb = _foeVerbs[random.nextInt(_foeVerbs.length)];
    final foeDamage =
        max(1.0, encounter.beast.attack - defense) *
            (0.85 + random.nextDouble() * 0.3);
    playerHp -= foeDamage;
    log.add(
      'The ${encounter.beast.name} $foeVerb for '
      '${foeDamage.toStringAsFixed(1)} damage.',
    );
    if (playerHp <= 0) {
      log.add('You fall to one knee. Only pride gets you back up.');
      return EncounterState(
        beast: encounter.beast,
        foeHp: foeHp,
        foeMaxHp: encounter.foeMaxHp,
        playerHp: 0,
        playerMaxHp: encounter.playerMaxHp,
        round: encounter.round + 1,
        log: log,
        finished: true,
      );
    }

    final nextRound = encounter.round + 1;
    if (nextRound >= maxRounds) {
      log.add('The battle drags on until you can no longer lift your '
          'arms. You withdraw.');
      return EncounterState(
        beast: encounter.beast,
        foeHp: foeHp,
        foeMaxHp: encounter.foeMaxHp,
        playerHp: playerHp,
        playerMaxHp: encounter.playerMaxHp,
        round: nextRound,
        log: log,
        finished: true,
      );
    }

    final current = EncounterState(
      beast: encounter.beast,
      foeHp: foeHp,
      foeMaxHp: encounter.foeMaxHp,
      playerHp: playerHp,
      playerMaxHp: encounter.playerMaxHp,
      round: nextRound,
      log: log,
    );
    return current.copyWith(pendingMoment: _momentFor(current, state, random));
  }

  static EncounterState _afterPlayerAction(
    EncounterState encounter, {
    required List<String> log,
    double? foeHp,
    double? playerHp,
  }) {
    return EncounterState(
      beast: encounter.beast,
      foeHp: foeHp ?? encounter.foeHp,
      foeMaxHp: encounter.foeMaxHp,
      playerHp: playerHp ?? encounter.playerHp,
      playerMaxHp: encounter.playerMaxHp,
      round: encounter.round + 1,
      log: log,
    );
  }
}

extension _EncounterCopy on EncounterState {
  EncounterState copyWith({EncounterMoment? pendingMoment}) {
    return EncounterState(
      beast: beast,
      foeHp: foeHp,
      foeMaxHp: foeMaxHp,
      playerHp: playerHp,
      playerMaxHp: playerMaxHp,
      round: round,
      log: log,
      finished: finished,
      victory: victory,
      fled: fled,
      pendingMoment: pendingMoment ?? this.pendingMoment,
    );
  }
}

enum EncounterKind { hunt, tournament, war }
