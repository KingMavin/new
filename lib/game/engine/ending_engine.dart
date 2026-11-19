import 'package:immortal_path/game/models/game_state.dart';

class GameEnding {
  final String id;
  final String title;
  final String epilogue;
  final bool hidden;

  const GameEnding({
    required this.id,
    required this.title,
    required this.epilogue,
    this.hidden = false,
  });
}

class EndingEngine {
  static const List<GameEnding> endings = [
    GameEnding(
      id: 'main_heaven',
      title: 'The Gate of Heaven',
      epilogue:
          'The final tribulation parts, and the Heavenly Gate opens as it '
          'has for ten thousand years \u2014 for the orthodox, the loyal, '
          'the ones who climbed as heaven demanded. You ascend in white '
          'light, and the celestial court enters your name in the rolls '
          'of immortals. Somewhere below, a thousand sects tell your '
          'story as instruction: this is what a proper life earns.',
    ),
    GameEnding(
      id: 'main_sovereignty',
      title: 'The Ash Throne',
      epilogue:
          'The final tribulation parts \u2014 and you refuse the gate. You '
          'shatter its threshold with your last strike and stand on the '
          'broken pieces as heaven\u2019s lightning bends around your '
          'will. You do not ascend; you take. What you build from the '
          'spoils will outlast the celestial court\u2019s rolls, because '
          'you will write those instead.',
    ),
    GameEnding(
      id: 'main_wild',
      title: 'The Verdant Return',
      epilogue:
          'The final tribulation parts \u2014 and you step past the gate '
          'without entering it, down into the living world, breathing '
          'unbounded. Your qi sinks into root and river and ridge; every '
          'wild place grows a little stronger where you walked. The '
          'sect-masters will call it a waste of a cultivation. The '
          'forest will call it coming home.',
    ),
    GameEnding(
      id: 'hidden_ninth',
      title: 'The Ninth Lightning',
      hidden: true,
      epilogue:
          'Three times the heavens struck you down, and three times you '
          'climbed back to the tribulation platform with your bones '
          'knitted and your will unbroken. At the final gate, heaven '
          'does something it has never done: it hesitates. The ninth '
          'lightning falls \u2014 and you catch it. The celestial court, '
          'convinced at last of what stubbornness can forge, offers you '
          'a seat among the thunder-wielders. You accept it as an equal.',
    ),
    GameEnding(
      id: 'hidden_nameless',
      title: 'The Nameless Grave',
      hidden: true,
      epilogue:
          'At the gate of heaven, a beggar stands where no beggar should '
          'be \u2014 the one you fed when you had almost nothing, the one '
          'the heavens use as their ledger-keeper. \u201cThe price of '
          'ascension is your name,\u201d he says. \u201cYou gave generously '
          'once. I return the favor.\u201d You erase your name from '
          'heaven\u2019s ledger yourself and walk back into the mortal '
          'world, unrecorded and utterly free, to live out your '
          'unmeasured centuries in an ordinary valley that will never '
          'know what chose to stay.',
    ),
    GameEnding(
      id: 'hidden_scars',
      title: 'The Unbowed',
      hidden: true,
      epilogue:
          'You came to the gate carrying every mark the road gave you \u2014 '
          'the scars, the whispers, the withered palm folded into your '
          'sleeve. Heaven looks at the ledger of your life and finds it '
          'stained and glorious all the way down. You are not admitted to '
          'the celestial rolls; they are not clean enough. You are welcomed '
          'beyond them instead, as the first of a new register: the unbowed, '
          'who climbed exactly as wounded as they were.',
    ),
    GameEnding(
      id: 'hidden_wheel',
      title: 'The Wheel Unbound',
      hidden: true,
      epilogue:
          'You have lived before. You remember the wheel\u2019s turning '
          '\u2014 and this time, unbroken through every battle, you '
          'arrive at the gate with the wheel\u2019s root caught in your '
          'teeth. You bite through. The cycle of reincarnation releases '
          'you not into heaven and not back into the world, but into '
          'the wide dark between, where nothing has ever cultivated '
          'before. You go willingly. No one has ever been more free.',
    ),
  ];

  static GameEnding? byId(String id) {
    for (final ending in endings) {
      if (ending.id == id) return ending;
    }
    return null;
  }

  static String? evaluate({
    required bool ascended,
    required int tribulationsFailed,
    required int reincarnations,
    required int battlesLost,
    required List<String> storyFlags,
    required Map<String, int> pathPoints,
    required int lastingMarks,
  }) {
    if (!ascended) return null;
    if (tribulationsFailed >= 3) return 'hidden_ninth';
    if (storyFlags.contains('gave_everything')) return 'hidden_nameless';
    if (reincarnations >= 3 && battlesLost == 0) return 'hidden_wheel';
    if (lastingMarks >= 3) return 'hidden_scars';
    String? best;
    var bestValue = 0;
    for (final entry in pathPoints.entries) {
      if (entry.value > bestValue) {
        bestValue = entry.value;
        best = entry.key;
      }
    }
    return 'main_${best ?? 'heaven'}';
  }

  static String? evaluateState(GameState state) => evaluate(
        ascended: state.ascended,
        tribulationsFailed: state.tribulationsFailed,
        reincarnations: state.reincarnations,
        battlesLost: state.battlesLost,
        storyFlags: state.storyFlags,
        pathPoints: state.pathPoints,
        lastingMarks: state.consequences.length,
      );
}
