class StoryPathInfo {
  final String id;
  final String name;
  final String description;
  final String bonusLabel;

  const StoryPathInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.bonusLabel,
  });

  static const List<StoryPathInfo> catalog = [
    StoryPathInfo(
      id: 'heaven',
      name: 'Path of Heaven',
      description:
          'Order, orthodoxy, the long stair of the celestial way. Heaven '
          'rewards those who climb it as it demands.',
      bonusLabel: '+3% breakthrough chance',
    ),
    StoryPathInfo(
      id: 'sovereignty',
      name: 'Path of Sovereignty',
      description:
          'Power seized, not granted. The strong write the laws the weak '
          'obey \u2014 why should heaven be exempt?',
      bonusLabel: '+5% attack',
    ),
    StoryPathInfo(
      id: 'wild',
      name: 'Path of the Wild',
      description:
          'The dao of root and river, of beast-blood and untamed qi. The '
          'wild does not kneel, and neither will you.',
      bonusLabel: '+5% spirit stones',
    ),
  ];

  static StoryPathInfo byId(String id) => catalog.firstWhere(
        (path) => path.id == id,
        orElse: () => catalog.first,
      );
}

class StoryChoice {
  final String label;
  final String narration;
  final String pathId;
  final int pathWeight;
  final String? flag;

  const StoryChoice({
    required this.label,
    required this.narration,
    required this.pathId,
    this.pathWeight = 2,
    this.flag,
  });
}

class StoryChapter {
  final String id;
  final String raceId;
  final int index;
  final int requiredRealm;
  final String title;
  final String narration;
  final List<StoryChoice> choices;

  const StoryChapter({
    required this.id,
    required this.raceId,
    required this.index,
    required this.requiredRealm,
    required this.title,
    required this.narration,
    required this.choices,
  });
}

class StoryCatalog {
  static const List<StoryChapter> chapters = [
    StoryChapter(
      id: 'human_1',
      raceId: 'human',
      index: 0,
      requiredRealm: 0,
      title: 'The Stairs of the Sect',
      narration:
          'The Verdant Sword Sect opens its mountain gates once a year. '
          'Ten thousand children climb the nine thousand stairs; three are '
          'chosen. You reach the final flight as the sun sets \u2014 and '
          'find an elder\u2019s jade slip dropped on the steps, holding a '
          'technique no disciple should see.',
      choices: [
        StoryChoice(
          label: 'Return the slip and bow to the elders',
          narration:
              'The elder\u2019s eyes narrow, then soften. Honesty is its '
              'own recommendation \u2014 your name enters the sect registry '
              'in fair ink.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Memorize it, then claim the credit',
          narration:
              'You burn the technique into memory and present yourself as '
              'its rightful heir. The elders doubt \u2014 but the qi in '
              'your meridians does not lie.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Slip away and learn it alone in the wilds',
          narration:
              'You leave the stairs before the gong sounds. The forest '
              'takes you in, and the jade slip teaches you under the '
              'stars.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'human_2',
      raceId: 'human',
      index: 1,
      requiredRealm: 1,
      title: 'The Magistrate\u2019s Grain',
      narration:
          'A imperial magistrate has taxed your home county into famine, '
          'and cultivator law forbids meddling in mortal rule \u2014 yet '
          'his granaries overflow while children gnaw bark. A crowd '
          'gathers outside your sect\u2019s gate, and they know your face.',
      choices: [
        StoryChoice(
          label: 'Petition the provincial sect council',
          narration:
              'You file the grievance through proper channels. Justice '
              'arrives \u2014 slowly, partially, but legitimately.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Break his granary locks at night',
          narration:
              'One strike of your blade opens what a thousand petitions '
              'could not. The county eats. The magistrate never speaks of '
              'why.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Teach the villagers to hunt spirit beasts',
          narration:
              'You spend a season teaching farmers to face the bamboo '
              'vipers themselves. They will never be cultivators \u2014 '
              'they will never need to beg, either.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'human_3',
      raceId: 'human',
      index: 2,
      requiredRealm: 3,
      title: 'The Conscription Edict',
      narration:
          'War drums sound along the Ash Wastes border, and the empire '
          'calls every cultivator above Foundation Establishment to the '
          'colors. The sect master hands you your marching orders '
          'personally \u2014 and quietly, a second letter: the emperor\u2019s '
          'spymaster offers a different post.',
      choices: [
        StoryChoice(
          label: 'March with the imperial army',
          narration:
              'You take your place in the legion of cultivators. The line '
              'holds because you hold it.',
          pathId: 'heaven',
          flag: 'served_in_war',
        ),
        StoryChoice(
          label: 'Accept the spymaster\u2019s shadow post',
          narration:
              'You vanish from the rosters. In the wars to come, enemy '
              'formations will fail in ways no one can prove.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Refuse and guard the mountain refugees instead',
          narration:
              'The sect marks you a deserter. The refugees you shepherd '
              'through the beast forests mark you something else.',
          pathId: 'wild',
          flag: 'shielded_refugees',
        ),
      ],
    ),
    StoryChapter(
      id: 'human_4',
      raceId: 'human',
      index: 3,
      requiredRealm: 5,
      title: 'The Emperor\u2019s Offer',
      narration:
          'The Son of Heaven summons you to the Forbidden Pagoda. He is '
          'dying \u2014 mortal despite the empire\u2019s elixirs \u2014 and '
          'he offers you the Imperial Seal: become the empire\u2019s first '
          'cultivating regent, its shield and its sword, until a heir '
          'comes of age.',
      choices: [
        StoryChoice(
          label: 'Kneel and accept the regency',
          narration:
              'You accept the seal with both hands. For a hundred years, '
              'the empire\u2019s word and yours are the same word.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Take the seal \u2014 and the throne',
          narration:
              'You accept the seal. The emperor\u2019s heart stops that '
              'night; the physicians find nothing wrong. The empire has a '
              'new kind of ruler.',
          pathId: 'sovereignty',
          flag: 'claimed_throne',
        ),
        StoryChoice(
          label: 'Decline and return to the mountains',
          narration:
              'You leave the seal on the throne room floor. The emperor '
              'calls you a fool; the mountains call you home.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'human_5',
      raceId: 'human',
      index: 4,
      requiredRealm: 7,
      title: 'The Gate Decree',
      narration:
          'At the Heavenly Gate Ruins, the celestial court\u2019s decree '
          'burns itself into the sky: the gate will close for ten '
          'thousand years, and only those who kneel at the threshold '
          'will be carried up. You have grown strong enough that your '
          'answer will decide what thousands of lesser cultivators are '
          'allowed to become.',
      choices: [
        StoryChoice(
          label: 'Proclaim the decree and organize the kneelers',
          narration:
              'You spend your remaining mortal years teaching the '
              'orthodox posture of surrender-that-is-salvation. The '
              'celestial court notes your name in gold.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Rally the cultivators to shatter the gate\u2019s lock',
          narration:
              'If heaven closes the door, you will show the world the '
              'door was never theirs. The gate cracks \u2014 and does not '
              'close.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Lead those who refuse into the deep wilds',
          narration:
              'You guide ten thousand refusers beyond the empire\u2019s '
              'maps, where heaven\u2019s decree is just weather. A new '
              'people begins.',
          pathId: 'wild',
          flag: 'led_the_refusers',
        ),
      ],
    ),
    StoryChapter(
      id: 'demon_1',
      raceId: 'demon',
      index: 0,
      requiredRealm: 0,
      title: 'The Branding Rite',
      narration:
          'In the ash-stone camps, coming of age means the branding '
          'iron: your clan\u2019s sigil burned into the forearm, fed by '
          'your own qi. Your elder holds the iron and speaks the old '
          'warning \u2014 the brand binds you to the clan, dead or free.',
      choices: [
        StoryChoice(
          label: 'Take the brand with a steady arm',
          narration:
              'The iron hisses; you do not. The clan\u2019s fire now '
              'recognizes its own.',
          pathId: 'heaven',
          flag: 'branded_loyal',
        ),
        StoryChoice(
          label: 'Seize the iron and brand your own sigil',
          narration:
              'You press the iron to your own arm and carve a sigil no '
              'clan has ever worn. The elders are silent. The children '
              'will remember.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Walk into the wastes unbranded',
          narration:
              'You leave the camp before dawn. The wastes test you, and '
              'the ash accepts no master \u2014 including you.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'demon_2',
      raceId: 'demon',
      index: 1,
      requiredRealm: 1,
      title: 'The Clan Feud',
      narration:
          'Your clan\u2019s water vein has been poisoned upstream \u2014 '
          'the Iron Tusk clan\u2019s work, everyone knows, though none can '
          'prove it. The old blood demands blood in return, and your '
          'clan\u2019s war horn already echoes off the ash cliffs.',
      choices: [
        StoryChoice(
          label: 'Invoke the trial-by-combat rite instead',
          narration:
              'You demand the old forms: one champion, one duel, one '
              'verdict. The elders approve. You win, and the feud ends '
              'with law instead of slaughter.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Lead the raid on the Iron Tusk camps',
          narration:
              'By dawn the Iron Tusk banner burns and their vein runs '
              'clear again. The wastes understand exactly what you are.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Track the true poisoner through the wastes alone',
          narration:
              'You follow the poison\u2019s trail for nine days and find '
              'the truth: a hired beast-venom dealer, paid in imperial '
              'coin. The feud was a purchase.',
          pathId: 'wild',
          flag: 'found_the_poisoner',
        ),
      ],
    ),
    StoryChapter(
      id: 'demon_3',
      raceId: 'demon',
      index: 2,
      requiredRealm: 3,
      title: 'The Purge',
      narration:
          'The Verdant Empire has declared the Border Purge: imperial '
          'cultivator legions will burn the ash-stone camps tribe by '
          'tribe. A messenger offers you terms \u2014 your clan survives '
          'as branded servants of the empire, kneeling at the border '
          'shrines.',
      choices: [
        StoryChoice(
          label: 'Kneel to save your clan',
          narration:
              'You kneel so your people do not burn. The brand of '
              'servitude sits beside your clan sigil, and your clan '
              'lives.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Unite the clans for war',
          narration:
              'You spend a season dueling every clan champion who '
              'disagrees with you. At winter\u2019s end, the wastes march '
              'as one \u2014 behind you.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Lead the clans into the deep wastes',
          narration:
              'You take your people where imperial maps end, into '
              'dragonfire country. The legions do not follow. The wastes '
              'keep what is wild.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'demon_4',
      raceId: 'demon',
      index: 3,
      requiredRealm: 5,
      title: 'The Council of Ash',
      narration:
          'The demon lords gather in the Ash Sanctum to choose a War '
          'Sovereign for the coming age \u2014 a single voice to lead all '
          'clans. The seat is offered to you, and every lord watches how '
          'you answer.',
      choices: [
        StoryChoice(
          label: 'Refuse the seat; counsel unity without a tyrant',
          narration:
              'You speak for the old councils, where no one voice '
              'outranked the fire. The lords grumble \u2014 and agree.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Take the seat and the iron crown',
          narration:
              'You sit before they can reconsider. The iron crown is '
              'heavier than it looks; you wear it like it was forged for '
              'you. It was.',
          pathId: 'sovereignty',
          flag: 'war_sovereign',
        ),
        StoryChoice(
          label: 'Give the seat to the strongest clan you defeated',
          narration:
              'You name another lord and kneel to them first. The hall '
              'does not understand \u2014 until they see how completely '
              'the strong now trust you.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'demon_5',
      raceId: 'demon',
      index: 4,
      requiredRealm: 7,
      title: 'The Ash Prophecy',
      narration:
          'The Sanctum\u2019s oldest flame speaks a prophecy at last: the '
          'old blood will either be extinguished by heaven\u2019s final '
          'light, or become the forge on which a new heaven is hammered. '
          'The clans turn to you \u2014 the flame spoke while looking at '
          'you.',
      choices: [
        StoryChoice(
          label: 'Seek heaven\u2019s pardon for all the old blood',
          narration:
              'You begin the long, humiliating work of treaty: the '
              'wastes\u2019 terms written in ink heaven must read.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Begin forging the new heaven',
          narration:
              'You gather the flame-masters and begin the Great Forge: a '
              'heaven built by demon hands, for demon hands.',
          pathId: 'sovereignty',
          flag: 'began_the_forge',
        ),
        StoryChoice(
          label: 'Let the prophecy burn unread',
          narration:
              'You scatter the prophecy-flame to the winds. Whatever the '
              'old blood becomes, it will not be what a fire told it to '
              'be.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'demi_1',
      raceId: 'demi_human',
      index: 0,
      requiredRealm: 0,
      title: 'The Forest\u2019s Call',
      narration:
          'On your twelfth birthday, the border forest does something it '
          'does for few demi-humans: it calls you. A moonveil stag steps '
          'from the treeline, waits to see if you follow, and walks back '
          'in. The village elders say the marked ones either become '
          'wardens or are never seen again.',
      choices: [
        StoryChoice(
          label: 'Ask the elders to teach you the warden rites',
          narration:
              'You learn the old rites properly \u2014 which roots to '
              'honor, which shadows to avoid. The forest notices your '
              'manners.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Hunt the stag\u2019s trail your own way',
          narration:
              'You chase the moonveil stag through three valleys on '
              'sheer stubbornness. It lets you catch up, finally, out of '
              'what might be respect.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Follow into the deep forest at once',
          narration:
              'You step past the treeline with nothing but the clothes '
              'you wear. The forest closes behind you like a door \u2014 '
              'and opens ahead like a road.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'demi_2',
      raceId: 'demi_human',
      index: 1,
      requiredRealm: 1,
      title: 'The Poachers',
      narration:
          'Imperial beast-poachers have struck the border forests, '
          'skinning moonveil stags for the emperor\u2019s winter hunt. '
          'They left a wounded stag-calf alive as bait \u2014 for you, '
          'the warden\u2019s apprentice, because your name was in their '
          'ledger.',
      choices: [
        StoryChoice(
          label: 'Report to the warden and set an ambush by the book',
          narration:
              'The warden\u2019s trap closes exactly as the rites '
              'describe. The poachers face border justice, properly '
              'spoken.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Walk into their camp wearing your beast-blood openly',
          narration:
              'You let them see the eyes, the claws, the temper. They '
              'flee the forest entire, and the ledger burns.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Free the calf and track the herd to safety',
          narration:
              'You carry the calf three days through the deep forest to '
              'the hidden glade. The herd\u2019s matriarch memorizes your '
              'scent. That will matter.',
          pathId: 'wild',
          flag: 'saved_the_calf',
        ),
      ],
    ),
    StoryChapter(
      id: 'demi_3',
      raceId: 'demi_human',
      index: 2,
      requiredRealm: 3,
      title: 'The Tribe\u2019s Hunger',
      narration:
          'A blight has taken the border villages\u2019 crops, and the '
          'empire\u2019s relief granaries are \u2014 as always \u2014 '
          '\u201ccoming.\u201d Your tribe looks to you, the strongest of '
          'the beast-blooded, and the forest\u2019s deep stores are '
          'guarded by things older than tribes.',
      choices: [
        StoryChoice(
          label: 'Bargain with the imperial prefect for grain',
          narration:
              'You negotiate like a warden: precise, patient, '
              'inescapable. The grain arrives, and the debt is written '
              'down honestly.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Take the grain from the prefect\u2019s stores',
          narration:
              'The prefect\u2019s guards never even see you. The tribe '
              'eats, and the empire learns that its ledgers are not the '
              'only law in the border forests.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Lead the tribe into the forest\u2019s deep stores',
          narration:
              'You walk the tribe past the old boundaries and speak the '
              'old courtesies at the deep stores. The forest feeds its '
              'own.',
          pathId: 'wild',
        ),
      ],
    ),
    StoryChapter(
      id: 'demi_4',
      raceId: 'demi_human',
      index: 3,
      requiredRealm: 5,
      title: 'The Beast King\u2019s Test',
      narration:
          'The Beast King of the Myriad Wasteland \u2014 a golden ape '
          'older than the empire \u2014 summons all beast-blooded who '
          'have reached your realm. His test is simple: he will speak '
          'one true thing and one false thing about your future, and you '
          'must choose which to accept.',
      choices: [
        StoryChoice(
          label: 'Accept the true thing: a life of service',
          narration:
              'You accept the truth: service, long and unglamorous, to '
              'every creature that cannot defend itself. The Beast '
              'King\u2019s eyes crinkle.',
          pathId: 'heaven',
        ),
        StoryChoice(
          label: 'Accept the false thing and make it true: a crown',
          narration:
              'You choose the lie \u2014 that you will wear a crown of '
              'beast-iron \u2014 and begin making it true on the spot. '
              'The Beast King laughs for the first time in a century.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Refuse both: the future is not his to speak',
          narration:
              'You tell the oldest king in the world that your future '
              'belongs to no one\u2019s mouth, not even his. The silence '
              'lasts a long time. Then he bows \u2014 slightly.',
          pathId: 'wild',
          flag: 'refused_the_king',
        ),
      ],
    ),
    StoryChapter(
      id: 'demi_5',
      raceId: 'demi_human',
      index: 4,
      requiredRealm: 7,
      title: 'The Moonveil Pact',
      narration:
          'At the Moonveil Glade, under the permanent silver moon, the '
          'forest offers its oldest pact to its chosen: become the '
          'warden of every wild place \u2014 bound, honored, and never '
          'free \u2014 or refuse and remain only yourself. The moon '
          'waits on your word.',
      choices: [
        StoryChoice(
          label: 'Accept the pact and bind yourself to the wild',
          narration:
              'You speak the binding words. Silver light sinks into '
              'your bones; every wild place in the world now knows your '
              'name as a warden\u2019s name.',
          pathId: 'heaven',
          flag: 'took_the_pact',
        ),
        StoryChoice(
          label: 'Counter-offer: the wild kneels to no one \u2014 including you',
          narration:
              'You offer the forest a partnership instead of a '
              'hierarchy. The moon flickers \u2014 then, impossibly, '
              'brightens.',
          pathId: 'sovereignty',
        ),
        StoryChoice(
          label: 'Refuse gently and remain only yourself',
          narration:
              'You thank the moon and decline. The forest does not '
              'withdraw its regard; it simply lets you walk free among '
              'it, which is rarer.',
          pathId: 'wild',
        ),
      ],
    ),
  ];

  static List<StoryChapter> arcFor(String raceId) => chapters
      .where((chapter) => chapter.raceId == raceId)
      .toList(growable: false);

  static StoryChapter? chapterById(String id) {
    for (final chapter in chapters) {
      if (chapter.id == id) return chapter;
    }
    return null;
  }
}
