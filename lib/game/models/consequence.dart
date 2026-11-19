/// Lasting marks the world leaves on a cultivator — earned or scarred on by
/// the choices made in tournaments, wars, hunts and roadside events. Marks
/// bound to a life are washed away only by the wheel of reincarnation.
class GameConsequence {
  final String id;
  final String title;
  final String description;
  final bool boon;
  final double attackMul;
  final double defenseMul;
  final double hpMul;
  final double qiMul;
  final double stonesMul;

  const GameConsequence({
    required this.id,
    required this.title,
    required this.description,
    required this.boon,
    this.attackMul = 1.0,
    this.defenseMul = 1.0,
    this.hpMul = 1.0,
    this.qiMul = 1.0,
    this.stonesMul = 1.0,
  });
}

class ConsequenceCatalog {
  static const iron_will = GameConsequence(
    id: 'iron_will',
    title: 'Iron Will',
    description:
        'You struck back from the edge of death, and something in you set '
        'like tempered steel. The crowd tells of it still.',
    boon: true,
    attackMul: 1.05,
    defenseMul: 1.05,
  );

  static const stormtouched = GameConsequence(
    id: 'stormtouched',
    title: 'Stormtouched',
    description:
        'You trained where the bolts fall, and your meridians took the '
        'thunder into their grain. Rain means practice now.',
    boon: true,
    qiMul: 1.08,
  );

  static const dragons_blood = GameConsequence(
    id: 'dragons_blood',
    title: 'Dragon\u2019s Blood',
    description:
        'The scale you pried loose drinks itself into your marrow. Your '
        'body remembers being something enormous.',
    boon: true,
    hpMul: 1.05,
    attackMul: 1.05,
  );

  static const scarred = GameConsequence(
    id: 'scarred',
    title: 'Scarred',
    description:
        'The beast that beat you left its signature in your flesh. Your '
        'lung holds less storm than it did.',
    boon: false,
    hpMul: 0.90,
  );

  static const humiliated = GameConsequence(
    id: 'humiliated',
    title: 'Humiliated',
    description:
        'A whole arena watched them put you down, and the whispers follow '
        'you through the market stalls.',
    boon: false,
    qiMul: 0.97,
  );

  static const cursed_wounds = GameConsequence(
    id: 'cursed_wounds',
    title: 'Cursed Wounds',
    description:
        'War-born injuries refuse to close cleanly; old spears remember '
        'where to find you.',
    boon: false,
    defenseMul: 0.92,
  );

  static const frightened = GameConsequence(
    id: 'frightened',
    title: 'Thunder-Shy',
    description:
        'The lightning caught you once and your qi flinches at the sound '
        'of distant thunder ever since.',
    boon: false,
    qiMul: 0.94,
  );

  static const withered_palm = GameConsequence(
    id: 'withered_palm',
    title: 'Withered Palm',
    description:
        'The dragon scale bit back through your palm, and one hand never '
        'fully closes again.',
    boon: false,
    attackMul: 0.94,
  );

  static const List<GameConsequence> all = [
    iron_will,
    stormtouched,
    dragons_blood,
    scarred,
    humiliated,
    cursed_wounds,
    frightened,
    withered_palm,
  ];

  static GameConsequence? byId(String id) {
    for (final consequence in all) {
      if (consequence.id == id) return consequence;
    }
    return null;
  }
}
