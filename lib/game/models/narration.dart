class NarrationCatalog {
  static const Map<String, List<String>> screens = {
    'home': [
      'The courtyard keeps your seat, if not your name. Qi gathers for those who sit long enough.',
      'Stones remember the hands that were laid on them. Lay yours down again.',
      'Another morning in the compound. The tea is cold; the dao is patient.',
      'The basin ripples without wind. Upstream, someone has broken through \u2014 or died trying.',
    ],
    'world': [
      'Every road outside these walls is a rumor with teeth.',
      'The mapmaker only draws what survived the drawing trip.',
      'Where the ink stops, the world begins.',
      'Travelers say the hidden places move. The map disagrees. The map is often wrong.',
    ],
    'alchemy': [
      'The fire reads your temperament through the coal. Do not lie to it.',
      'A pill is a promise. Most furnaces keep them; none forgive haste.',
      'Grind, weigh, breathe, wait. The fourth step is where alchemists die.',
      'The cauldron remembers every botched batch. It holds few grudges, but they burn.',
    ],
    'sect': [
      'Halls rise and halls fall. What a sect keeps is its debt ledger \u2014 read yours.',
    ],
    'dao': [
      'The tablet says: what you cannot release will hold you at the gate.',
      'Cultivation is a stair built of yesterdays. Step carefully on your own.',
      'Ask the mirror who climbed. Ask the mountain who remained.',
      'The dao has no favorites. It only has bills.',
    ],
    'store': [
      'The temple keeps honest books. The prices simply kneel to no one.',
      'Support the path and the path supports you \u2014 that is the whole catechism.',
      'No fate is sold here, only comfort for the road.',
    ],
    'sect_store': [
      'The quartermaster counts stones, not reputations. Bring enough stones.',
      'Everything on these shelves was forged, grown, or inherited by someone who trained harder.',
      'The armory ledger is short for friends and exact for everyone.',
    ],
    'tribulation': [
      'The sky does not hate you. The sky is merely accurate.',
      'Thunder is the heavens checking their ledger. Stand still while the sums are done.',
      'What climbs must be weighed. What is weighed may crack.',
    ],
    'encounter': [
      'Steel settles what discussion cannot.',
    ],
    'settings': [
      'Records do not make a life. They prove you had one.',
      'The registry is dry work, but the registry is forever.',
      'Somewhere in these files is the version of you the world will keep.',
    ],
  };

  static const Map<String, List<String>> cases = {
    'breakthrough_success': [
      'The gate opened because you insisted. The heavens log such insistence.',
      'Older cultivators nod without knowing why. Something crossed a threshold tonight.',
      'The weather cleared at precisely the wrong moment for your enemies.',
    ],
    'breakthrough_failure': [
      'The qi refused in the same way a horse refuses \u2014 completely, then briefly, then completely.',
      'You were not rejected. You were read, and returned for revision.',
      'Bruised meridians mend. Only impatience scars.',
    ],
    'tribulation_survived': [
      'The sky is silent now, and the silence is a signature.',
      'You stood in the arithmetic of heaven and were not subtracted.',
      'Somewhere below, a mortal counted the lightning and was glad it was not aimed at them.',
    ],
    'tribulation_failed': [
      'The storm took what it came for and left you the lesson.',
      'Heaven re-balances all books. Yours will bear this entry a while.',
      'What broke will knit. What panicked will still be curling up when you dream.',
    ],
    'tournament_victory': [
      'The platform remembers its winners loudly and its losers longer.',
      'Your name got heavier today. Sects prefer heavy names.',
      'The bout ended the way doctrine wishes everything ended: cleanly, in front of witnesses.',
    ],
    'tournament_defeat': [
      'The arena is honest, which is why so few cultivators like it.',
      'Losing on the platform costs less than losing in the wild. Pay the cheaper lesson.',
      'A bowed head in daylight weighs less than a broken oath in secret.',
    ],
    'war_victory': [
      'The banners will be counted by survivors, and the survivors count you.',
      'The enemy line learned your sect\u2019s grammar the hard way.',
      'Wars are won by the side that runs out of reasons to leave first. You brought arithmetic.',
    ],
    'war_defeat': [
      'The front keeps everyone\u2019s contribution, even the fallen\u2019s. March again when you can hold a spear.',
      'Defeat is a rumor in some courts. In the clan courts it is a schedule.',
      'You left the field behind you. Leave the loss there too \u2014 but bring the notebook.',
    ],
    'hunt_victory': [
      'The wilds deducted one beast and awarded one anecdote.',
      'Carcasses tell the next beast everything. They never listen.',
      'The road is safer by one monster and two legends.',
    ],
    'hunt_defeat': [
      'The beast wrote nothing down. The wound will do the teaching.',
      'You will live to read about this hunt. Authorship is optional next time.',
      'Some roads collect tolls in blood. You prepaid.',
    ],
    'forge_success': [
      'The furnace exhaled and called it fair. Few offerings earn that.',
      'The metal gave up its objections one by one. So will your enemies.',
      'A blade born honest seldom lies. Mind what you ask it.',
    ],
    'forge_failure': [
      'The furnace kept the materials and mailed back the humility.',
      'Slag teaches patience. Patience forgives slag. The stones do neither.',
      'The forge remembers failed batches the way sects remember traitors \u2014 briefly, then usefully.',
    ],
    'promotion': [
      'Your name moved one row higher on the ledger. Rows are earned here, never bought.',
      'The hall does not get warmer with rank. Only the view changes.',
      'Somewhere a senior disciple loosened their collar without knowing why.',
    ],
    'reincarnation': [
      'The wheel turns whether you watch or blink. You watched. It counts double.',
      'A new name, an old river: the water does not remember, but the stones do.',
      'You died as someone and were born as no one. Both were you. Cultivate accordingly.',
    ],
    'ascension': [
      'The gates were built narrow on purpose. You came through sideways, past the keepers, carrying everything.',
      'What the heavens file under \u2018ascended\u2019, the world files under \u2018unfinished\u2019. Both are correct.',
      'The legend is not that you left. The legend is what you left running.',
    ],
  };

  static bool hasScreen(String screen) => screens.containsKey(screen);

  static bool hasCase(String key) => cases.containsKey(key);

  static String lineFor(Map<String, List<String>> source, String key, int seed) {
    final lines = source[key];
    if (lines == null || lines.isEmpty) return '';
    final index = seed < 0 ? 0 : seed % lines.length;
    return lines[index];
  }

  static String screenLine(String screen, {int? seed}) =>
      lineFor(screens, screen, seed ?? DateTime.now().day);

  static String caseLine(String key, {int? seed}) =>
      lineFor(cases, key, seed ?? DateTime.now().day + key.length);
}
