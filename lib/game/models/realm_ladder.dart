class RealmLadder {
  static const List<String> realmNames = [
    'Qi Refining',
    'Foundation Establishment',
    'Golden Core',
    'Nascent Soul',
    'Soul Formation',
    'Void Refinement',
    'Body Integration',
    'Tribulation Transcendence',
    'Ascension',
  ];

  static const List<String> stageNames = ['Early', 'Middle', 'Late', 'Peak'];

  static const int stagesPerRealm = 4;

  static const List<int> _lifespans = [
    80,
    150,
    300,
    500,
    1000,
    2000,
    4000,
    8000,
    100000,
  ];

  static int get totalStages => realmNames.length * stagesPerRealm;

  static String realmName(int realmIndex) => realmNames[realmIndex];

  static String stageName(int stageIndex) => stageNames[stageIndex];

  static int lifespanYears(int realmIndex) => _lifespans[realmIndex];
}
