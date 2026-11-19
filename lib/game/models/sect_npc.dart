import 'dart:math';

class SectNpc {
  final String name;
  final String title;
  final List<String> lines;

  const SectNpc({
    required this.name,
    required this.title,
    required this.lines,
  });

  String lineFor({int seed = 0}) {
    if (lines.isEmpty) return '';
    return lines[Random(seed).nextInt(lines.length)];
  }
}

class SectHall {
  final String sectId;
  final SectNpc master;
  final SectNpc steward;
  final SectNpc quartermaster;

  const SectHall({
    required this.sectId,
    required this.master,
    required this.steward,
    required this.quartermaster,
  });

  static const List<SectHall> catalog = [
    SectHall(
      sectId: 'sword_sect',
      master: SectNpc(
        name: 'Iron Sovereign Yan Zheng',
        title: 'Sword Hall Master',
        lines: [
          'The sword knows one mercy: it makes the weak honest.',
          'You came here to climb. Good. The mountain was made to be '
              'climbed \u2014 by whoever survives the weather.',
          'My generation sharpened itself on nine-thumb-thick trials. Yours '
              'gets sharpened on me. Consider that an honor.',
          'Rank here is earned in light. No back-room bows, no gold-stamped '
              'certificates \u2014 the blade either sings or it doesn\u2019t.',
        ],
      ),
      steward: SectNpc(
        name: 'Steward Bai Ling',
        title: 'Keeper of the Deed Ledger',
        lines: [
          'The sect remembers debts. Sign here \u2014 your deeds and my ink '
              'will do the rest.',
          'Another task, another tally. The roads are thick with beasts '
              'lately; the trade caravans are howling.',
          'Contribution points are the sect\u2019s memory of you. Don\u2019t '
              'die before you\u2019re unforgettable.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Quartermaster Gao Shen',
        title: 'Warden of the Armory',
        lines: [
          'Blades are like disciples \u2014 most are forged poorly. Mine are '
              'not.',
          'Contributions first. Sentiment doesn\u2019t sharpen steel, '
              'runes do.',
        ],
      ),
    ),
    SectHall(
      sectId: 'formation_hall',
      master: SectNpc(
        name: 'Arrayweaver Mu Qingshu',
        title: 'Hall Master of Formations',
        lines: [
          'Fate is a pattern. Patterns can be rewritten. That is the whole '
              'of our doctrine \u2014 the rest is chalk dust.',
          'The heaven-seeking array hums whenever a tribulation nears. '
              'When it hums for you, you\u2019ll know.',
          'Strength without a formation is a bonfire in a monastery: loud, '
              'then gone. Learn the lattice.',
          'We measure a cultivator not by talismans burned but by the '
              'arrays they leave standing.',
        ],
      ),
      steward: SectNpc(
        name: 'Steward Xiao Wen',
        title: 'Registrar of Arrays',
        lines: [
          'Each task you finish feeds a node in the great array. Yours is '
              'burning brighter this week.',
          'The formation hall honors precision, not promises. Do the work; '
              'let the array testify.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Inscriber Dong Huai',
        title: 'Master of Array Stocks',
        lines: [
          'Formation plates, ward flags, severance chalk \u2014 all priced '
              'in contribution, all worth it.',
        ],
      ),
    ),
    SectHall(
      sectId: 'imperial_herbal_court',
      master: SectNpc(
        name: 'Grand Physician Cai Ruxin',
        title: 'Matriarch of the Herbal Court',
        lines: [
          'Qi is a river; the body is its bed. The bed cracks, the river '
              'drowns the valley. We mend the bed.',
          'The empire calls us healers. Empires lie politely \u2014 we are '
              'arbiters of who cultivates another century.',
          'A pill brewed in haste is a debt owed to your own liver. Nobody '
              'escapes a debt to the liver.',
          'Rise in rank, and the court\u2019s deeper gardens open. The '
              'seventh garden grows things with opinions.',
        ],
      ),
      steward: SectNpc(
        name: 'Steward Han Yuze',
        title: 'Clerk of Tithes',
        lines: [
          'Pills to the infirmary, herbs to the vaults, your name to the '
              'ledger. Order matters.',
          'The court pays in stones for chores others find menial. Menial '
              'work builds patient cultivators.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Vaultkeeper Ma Suling',
        title: 'Keeper of the Cold Cellars',
        lines: [
          'Hazmat for spirit herbs, jade cases for pills, silk for your '
              'fragile ego \u2014 all available.',
        ],
      ),
    ),
    SectHall(
      sectId: 'blood_furnace_clan',
      master: SectNpc(
        name: 'Furnace Lord Hei Mang',
        title: 'Blood Furnace Patriarch',
        lines: [
          'The old blood doesn\u2019t ask permission of the heavens. It '
              'asks the furnace, and the furnace says yes.',
          'Empires carve stairs to heaven. We burn stairs \u2014 we were '
              'never meant for gates built by our jailers.',
          'Rank smells like hot iron and lasts like it. Contribute, and '
              'the furnace shows you its warm side.',
          'They called us monsters when we were strong and suspicious when '
              'we were quiet. We prefer monsters.',
        ],
      ),
      steward: SectNpc(
        name: 'Stewardess Ru Yan',
        title: 'Tally-Singer of the Clan',
        lines: [
          'Deeds feed the furnace\u2019s ledger-songs. Sing well and the '
              'clan hears you.',
          'The clan keeps no delicate scrolls \u2014 your deeds are cast '
              'into iron plates. Heavy, like you.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Ironbreaker Zhou Kun',
        title: 'Master of the Forge Stores',
        lines: [
          'War-gear for war-blood. Contribution buys; weakness doesn\u2019t.',
        ],
      ),
    ),
    SectHall(
      sectId: 'pill_valley',
      master: SectNpc(
        name: 'Valley Mistress Qin Fengwu',
        title: 'Matriarch of Myriad Pills',
        lines: [
          'People say alchemy is patience. Alchemy is appetite with '
              'patience \u2014 the patience to want rightly.',
          'The valley never closes its gates to a suffering cultivator. '
              'We close our ledgers to freeloaders.',
          'Each cauldron in the valley has a temperament. Yours will soon, '
              'too \u2014 the cauldron always outlives the grudge.',
          'Our rank system is simple: the furnaces you tend are counted, '
              'and so are the burn scars you took tending them.',
        ],
      ),
      steward: SectNpc(
        name: 'Steward Mo Chen',
        title: 'Ledger-Keeper of Caules',
        lines: [
          'Sign the requisition, brew the quota, return the cauldron '
              'unscathed. In that order.',
          'The valley\u2019s memory is long and its herbs are patient. '
              'Match either and thrive.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Cauldron-Master Pi Hong',
        title: 'Warden of Furnaces',
        lines: [
          'Contribution points open the furnace shrines. Shattered cauldron '
              'deposits open nothing.',
        ],
      ),
    ),
    SectHall(
      sectId: 'nightveil_bureau',
      master: SectNpc(
        name: 'Director Wu Shenye',
        title: 'Master of the Nightveil Bureau',
        lines: [
          'The clans rule the day fires. The Bureau files the paperwork of '
              'night \u2014 omens, wards, and the quiet part of vengeance.',
          'You seek power over fate. Fate keeps excellent records. So do we.',
          'Bureau rank is not displayed, worn, or celebrated. It is '
              'reflected in what people stop saying when you enter.',
          'Tribulation lightning is only unpredictable to those who '
              'haven\u2019t read the ward charts. Get promoted; read them.',
        ],
      ),
      steward: SectNpc(
        name: 'Stewardess Xue Qiao',
        title: 'Tallymistress of Whispers',
        lines: [
          'Every task recorded is a whisper preserved. Whisper through '
              'deeds \u2014 the Bureau doesn\u2019t take letters.',
          'The Bureau repays precision. Approximations are returned '
              'unread with interest.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Warden Lian Gu',
        title: 'Keeper of Black Seals',
        lines: [
          'Warded talismans, sealed charts, unmarked blades \u2014 '
              'contribution points, nothing else.',
        ],
      ),
    ),
    SectHall(
      sectId: 'beast_court',
      master: SectNpc(
        name: 'Beastmother Ashara',
        title: 'Matriarch of the Spirit Beast Court',
        lines: [
          'The Court crowns no kings. The pack walks with whoever earns '
              'the howl \u2014 strength, given honestly, shared honestly.',
          'Your bonded beast will judge you before my tribunal does. Feed '
              'it, fight beside it, never sell it.',
          'The empire tamed its beasts with walls. We became something '
              'walls cannot contain.',
          'Rank in the Court is simple: the beasts obey at the elders\u2019 '
              'word, and at the elders\u2019 word only.',
        ],
      ),
      steward: SectNpc(
        name: 'Steward Thornwalker Vess',
        title: 'Tallyman of the Pack',
        lines: [
          'The pack remembers deeds in ways ledgers never manage. Still '
              '\u2014 sign the tally, it keeps the wolves off my desk.',
          'Hunt well, travel far. The Court rewards instincts already '
              'yours.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Hide-Binder Orlagh',
        title: 'Warden of Beast-Hide Stores',
        lines: [
          'Beast-hide armor from honest hunts. Contribution buys what '
              'boasting cannot.',
        ],
      ),
    ),
    SectHall(
      sectId: 'verdant_grove',
      master: SectNpc(
        name: 'Grovewarden Sylwen',
        title: 'Mother of the Whispering Grove',
        lines: [
          'Qi comes from green things and old rain. Everyone else is '
              'sprinting uphill; our path grows roots.',
          'The grove doesn\u2019t care for hurry. It remembers every hand '
              'that planted, and every hand that burned.',
          'Cultivation here outpaces any furnace \u2014 slowly, and then '
              'all at once, like spring.',
          'Serve the grove and it will serve you. Rank among us is grown, '
              'never granted.',
        ],
      ),
      steward: SectNpc(
        name: 'Steward Bramblehand Torvald',
        title: 'Keeper of Seed-Oaths',
        lines: [
          'A task accepted is a seed in the ground. Do the deed, the '
              'grove keeps count in rings.',
          'The grove\u2019s cultivators bloom by deeds, not by politics. '
              'Understand that and you are halfway sworn.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Sapkeeper Ildra',
        title: 'Warden of Living Stores',
        lines: [
          'Sap-talismans, rootbound staves, springwater flasks \u2014 fair '
              'prices in contribution points.',
        ],
      ),
    ),
    SectHall(
      sectId: 'wind_speaker_circle',
      master: SectNpc(
        name: 'Elder Zephyrmouth Kaelan',
        title: 'Speaker to the Four Winds',
        lines: [
          'The winds told us the heaven-gates were built narrow on '
              'purpose. So we studied what the wind knows \u2014 which is '
              'everything, delivered rudely.',
          'Foresee the storm and you need not survive it. That is the '
              'entire Ballad of the Circle.',
          'Rank here I cannot grant louder than a whisper \u2014 the wind '
              'announces my promotions.',
          'Breakthroughs are conversations with lightning. The Circle '
              'teaches the grammar.',
        ],
      ),
      steward: SectNpc(
        name: 'Stewardess Lirakin',
        title: 'Tallymistress of Echoes',
        lines: [
          'Deeds echo. I simply count the echoes. Do yours loudly.',
          'The Circle asks warriors, wanderers, and brewers alike. The '
              'wind sings all trades.',
        ],
      ),
      quartermaster: SectNpc(
        name: 'Featherkeeper Sarnai',
        title: 'Warden of Wind-Charms',
        lines: [
          'Wind-charms, storm-feathers, silence-bells \u2014 priced in '
              'contribution, effective in weather.',
        ],
      ),
    ),
  ];

  static SectHall byId(String sectId) => catalog.firstWhere(
        (hall) => hall.sectId == sectId,
        orElse: () => catalog.first,
      );

  static const Map<String, SectNpc> gatekeepers = {
    'human': SectNpc(
      name: 'Gate-Watchman Qiu',
      title: 'Warden of the Verdant Gates',
      lines: [
        'No sect? Fine. The empire\u2019s stairs were always open to those '
            'who climb with their own fists. Strength ranks highest here '
            '\u2014 always has.',
        'Deeds are the only passport you own, wanderer. The gates open by '
            'reputation, not oaths.',
        'You want tasks while unsworn? The empire hires strength like '
            'yours \u2014 paid in reputation, held by honor.',
      ],
    ),
    'demon': SectNpc(
      name: 'Ashen Gatekeeper Vorune',
      title: 'Warden of the Ash Wastes',
      lines: [
        'Unsworn, standing at an ash gate? Bold. The clan respects bold '
            '\u2014 in measurable units of strength.',
        'Numbers gore the dishonest and bless the strong. Prove the old '
            'blood proud, unaligned one.',
        'The clans pay wandering fists in reputation. Strength is the '
            'whole contract.',
      ],
    ),
    'demi_human': SectNpc(
      name: 'Forest Warden Odarune',
      title: 'Gatekeeper of the Border Tribes',
      lines: [
        'The forest doesn\u2019t ask for oaths, only for steps honestly '
            'taken. Walk them; we\u2019ll count them.',
        'Unaligned travelers earn their place in tribal memory by deed. '
            'The wind gossips faster than any ledger.',
        'A task for taskless feet: the tribes pay reputation to those who '
            'guard the border roads.',
      ],
    ),
  };
}
