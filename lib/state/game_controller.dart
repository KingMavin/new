import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:immortal_path/game/engine/alchemy_engine.dart';
import 'package:immortal_path/game/engine/boost_engine.dart';
import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/disciple_engine.dart';
import 'package:immortal_path/game/engine/encounter_engine.dart';
import 'package:immortal_path/game/engine/ending_engine.dart';
import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/engine/race_engine.dart';
import 'package:immortal_path/game/engine/reputation_engine.dart';
import 'package:immortal_path/game/engine/tournament_engine.dart';
import 'package:immortal_path/game/engine/war_engine.dart';
import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/engine/story_engine.dart';
import 'package:immortal_path/game/engine/tribulation_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/monetization.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/power.dart';
import 'package:immortal_path/game/models/race.dart';
import 'package:immortal_path/game/models/story.dart';
import 'package:immortal_path/game/models/soul_upgrade.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/game/persistence/shared_prefs_save_repository.dart';
import 'package:immortal_path/monetization/monetization_gateway.dart';
import 'package:immortal_path/game/util/format.dart';

class GameController extends ChangeNotifier with WidgetsBindingObserver {
  GameController({SaveRepository? repository, MonetizationGateway? gateway})
      : _repository = repository ?? SharedPrefsSaveRepository(),
        _gateway = gateway ?? StubMonetizationGateway() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration _tickInterval = Duration(milliseconds: 250);
  static const Duration _autosaveInterval = Duration(seconds: 30);
  static const Duration _offlineReportThreshold = Duration(seconds: 30);
  static const Duration maxOfflineDuration = Duration(hours: 24);
  static const double maxBreakthroughBonus = 0.5;

  final SaveRepository _repository;
  final MonetizationGateway _gateway;
  final Random _rng = Random();
  Timer? _timer;
  DateTime _lastTick = DateTime.now();
  DateTime _lastSave = DateTime.now();
  GameState _state = GameState.initial();
  OfflineReport? _pendingOfflineReport;
  EncounterState? _encounter;
  EncounterKind _encounterKind = EncounterKind.hunt;
  String? _lastEncounterSummary;

  GameState get state => _state;
  EncounterState? get encounter => _encounter;
  EncounterKind get encounterKind => _encounterKind;
  String? get lastEncounterSummary => _lastEncounterSummary;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    final saved = await _repository.load();
    if (saved != null) {
      _state = saved;
      _applyOfflineGains();
    }
    _lastTick = DateTime.now();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _lastTick = DateTime.now();
    _timer = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final seconds = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;
    if (seconds <= 0) return;
    final rate = CultivationEngine.qiPerSecond(_state);
    final gain = rate * seconds;
    _state = _state.copyWith(
      qi: _state.qi + gain,
      totalQiGained: _state.totalQiGained + gain,
    );
    if (now.difference(_lastSave) >= _autosaveInterval) {
      _lastSave = now;
      save();
    }
    _checkDiscipleMissions(now);
    notifyListeners();
  }

  void _checkDiscipleMissions(DateTime now) {
    var updated = _state;
    for (var i = 0; i < updated.disciples.length; i++) {
      final report = DiscipleEngine.collectIfReady(updated, i, now: now);
      if (report != null) updated = report.state;
    }
    if (!identical(updated, _state)) {
      _state = updated;
      save();
    }
  }

  void _applyOfflineGains() {
    final report = CultivationEngine.computeOfflineProgress(
      _state,
      DateTime.now(),
      maxOfflineDuration: maxOfflineDuration,
    );
    _state = report.stateAfter;
    if (report.counted >= _offlineReportThreshold) {
      _pendingOfflineReport = report;
    }
  }

  OfflineReport? consumePendingOfflineReport() {
    final report = _pendingOfflineReport;
    _pendingOfflineReport = null;
    return report;
  }

  void circulateQi() {
    final gain = CultivationEngine.qiPerSecond(_state) * 5;
    _state = _state.copyWith(
      qi: _state.qi + gain,
      totalQiGained: _state.totalQiGained + gain,
    );
    notifyListeners();
  }

  BreakthroughAttempt attemptBreakthrough() {
    if (!CultivationEngine.isBreakthroughReady(_state)) {
      return const BreakthroughAttempt();
    }
    if (CultivationEngine.isMajorBreakthrough(_state)) {
      _state = TribulationEngine.begin(_state);
      notifyListeners();
      save();
      return const BreakthroughAttempt(tribulationStarted: true);
    }
    final result = CultivationEngine.attemptStageBreakthrough(_state);
    _state = result.state;
    notifyListeners();
    save();
    return BreakthroughAttempt(result: result);
  }

  TribulationOutcome? faceTribulation(TribulationAction action) {
    if (!_state.tribulationActive) return null;
    final wasAscended = _state.ascended;
    final outcome = TribulationEngine.faceWave(_state, action, rng: _rng);
    _state = outcome.state;
    if (!wasAscended && _state.ascended) {
      _evaluateEnding();
    }
    notifyListeners();
    save();
    return outcome;
  }

  void equipTechnique(String id) {
    if (!_state.discoveredTechniques.contains(id)) return;
    _state = _state.copyWith(techniqueId: id);
    notifyListeners();
    save();
  }

  bool feedCompanion() {
    final companion = _state.companion;
    if (companion == null || companion.level >= Companion.maxLevel) {
      return false;
    }
    if (_state.beastCores < Companion.feedCost) return false;
    _state = _state.copyWith(
      beastCores: _state.beastCores - Companion.feedCost,
      companion: Companion(
        name: companion.name,
        bonusType: companion.bonusType,
        level: companion.level + 1,
      ),
    );
    notifyListeners();
    save();
    return true;
  }

  bool selectLocation(String id) {
    final location = WorldCatalog.locations.firstWhere(
      (candidate) => candidate.id == id,
      orElse: () => WorldCatalog.locations.first,
    );
    if (location.id != id) return false;
    if (!WorldCatalog.isKnown(_state.discoveredLocations, location)) {
      return false;
    }
    if (!CombatEngine.isLocationUnlocked(_state, location)) return false;
    final standardIndex =
        WorldCatalog.standardLocations().indexOf(location);
    _state = _state.copyWith(
      activeLocationId: id,
      selectedZoneIndex:
          standardIndex >= 0 ? standardIndex : _state.selectedZoneIndex,
    );
    notifyListeners();
    save();
    return true;
  }

  WorldLocation effectiveLocation() {
    final id = _state.activeLocationId;
    if (id != null) {
      final location = WorldCatalog.byId(id);
      if (location.id == id &&
          WorldCatalog.isKnown(_state.discoveredLocations, location) &&
          CombatEngine.isLocationUnlocked(_state, location)) {
        return location;
      }
    }
    final zones = WorldCatalog.standardLocations();
    var index = _state.selectedZoneIndex.clamp(0, zones.length - 1).toInt();
    if (_state.realmIndex < zones[index].requiredRealm) {
      for (var i = zones.length - 1; i >= 0; i--) {
        if (_state.realmIndex >= zones[i].requiredRealm) {
          index = i;
          break;
        }
      }
    }
    return zones[index];
  }

  void startEncounter() => _startHunt();

  void _startHunt() {
    final location = effectiveLocation();
    final beast = location.beasts[_rng.nextInt(location.beasts.length)];
    _encounterKind = EncounterKind.hunt;
    _encounter = EncounterEngine.begin(_state, beast);
    _lastEncounterSummary = null;
    notifyListeners();
  }

  bool canStartTournament() {
    if (_state.raceId == null || _state.sectId == null) return false;
    final last = _state.lastTournamentAt;
    return last == null ||
        DateTime.now().difference(last) >= TournamentEngine.cooldown;
  }

  Duration tournamentCooldownRemaining() {
    final last = _state.lastTournamentAt;
    if (last == null) return Duration.zero;
    final remaining =
        TournamentEngine.cooldown - DateTime.now().difference(last);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void startTournament() {
    if (!canStartTournament()) return;
    final beast = TournamentEngine.opponent(_state, rng: _rng);
    _encounterKind = EncounterKind.tournament;
    _encounter = EncounterEngine.begin(
      _state,
      beast,
      introLines: [
        if (_state.immortalized && _state.legacyName != null)
          'The heralds cry your name across the sands \u2014 '
              '${_state.legacyName}, whose statues stand in three '
              'kingdoms. The crowd roars before a single blow is struck.',
        'The tournament platform smells of sand and incense. Across the '
            'ring, ${beast.name} bows with a blade salute.',
        'The gong sounds — the bout begins!',
      ],
      opening: const EncounterMoment(
        title: 'Opening Salute',
        text:
            'Your opponent settles into stance. Tournament rules forbid '
            'killing blows, but bones still break all the same.',
        choices: [
          EncounterChoice(
            label: 'Open with a probing exchange',
            successText:
                'You trade a flurry of measured strikes and come out '
                'ahead, reading their rhythm.',
            failText:
                'Their flurry is faster — a palm catches your '
                'shoulder and spins you half around.',
            damageMultiplier: 1.0,
            selfDamageFraction: 0.08,
            baseChance: 0.75,
          ),
          EncounterChoice(
            label: 'Blitz from the gong',
            successText:
                'You move before the echo dies, landing a stunning blow '
                'to open the bout.',
            failText:
                'They were ready for the rush — a counter throw '
                'slams you into the platform.',
            damageMultiplier: 1.7,
            selfDamageFraction: 0.18,
            baseChance: 0.5,
          ),
        ],
      ),
    );
    _lastEncounterSummary = null;
    notifyListeners();
  }

  bool canStartWar() {
    if (_state.raceId == null || _state.sectId == null) return false;
    if (_state.realmIndex < WarEngine.requiredRealm) return false;
    final last = _state.lastWarAt;
    return last == null ||
        DateTime.now().difference(last) >= WarEngine.cooldown;
  }

  Duration warCooldownRemaining() {
    final last = _state.lastWarAt;
    if (last == null) return Duration.zero;
    final remaining = WarEngine.cooldown - DateTime.now().difference(last);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void startWar() {
    if (!canStartWar()) return;
    final beast = WarEngine.champion(_state, rng: _rng);
    _encounterKind = EncounterKind.war;
    _encounter = EncounterEngine.begin(
      _state,
      beast,
      introLines: [
        WarEngine.frontDescription(_state),
        if (_state.immortalized && _state.legacyName != null)
          'Enemy soldiers whisper your name \u2014 ${_state.legacyName} '
              'walks the field. More than one shield arm drops.',
        'Their champion, ${beast.name}, strides from the enemy lines. '
            'Both armies fall silent.',
      ],
      opening: const EncounterMoment(
        title: 'The Lines Meet',
        text:
            'The war horns sound. Around you, thousands collide — '
            'but all of it hinges on the duel at the center.',
        choices: [
          EncounterChoice(
            label: 'Hold the center with your ranks',
            successText:
                'Your formation absorbs their charge and your counterpush '
                'buys the line time.',
            failText:
                'Their vanguard punches through — you take a spear '
                'graze holding the gap.',
            damageMultiplier: 1.0,
            selfDamageFraction: 0.08,
            baseChance: 0.75,
          ),
          EncounterChoice(
            label: 'Charge their champion directly',
            successText:
                'You smash through the bodyguard ring and your opening '
                'strike staggers their champion.',
            failText:
                'The guard ring closes — blades find you before you '
                'reach him.',
            damageMultiplier: 1.8,
            selfDamageFraction: 0.2,
            baseChance: 0.45,
          ),
        ],
      ),
    );
    _lastEncounterSummary = null;
    notifyListeners();
  }

  EncounterState? advanceEncounter() {
    final current = _encounter;
    if (current == null || current.finished || current.pendingMoment != null) {
      return current;
    }
    var next = EncounterEngine.advance(current, _state, rng: _rng);
    if (next.finished && next.victory) {
      _completeVictory(next, current.round + 1);
      return _encounter;
    }
    _encounter = next;
    notifyListeners();
    return next;
  }

  EncounterState? chooseEncounterOption(int choiceIndex) {
    final current = _encounter;
    if (current == null || current.pendingMoment == null) return current;
    var next = EncounterEngine.choose(
      current,
      _state,
      choiceIndex,
      rng: _rng,
    );
    if (next.finished && next.victory) {
      _completeVictory(next, next.round);
      return _encounter;
    }
    _encounter = next;
    if (next.finished) {
      _lastEncounterSummary = next.fled
          ? 'You escaped with your life, but gained nothing.'
          : 'You were driven from the field with nothing to show for it.';
    }
    notifyListeners();
    return next;
  }

  void _completeVictory(EncounterState finished, int rounds) {
    if (_encounterKind == EncounterKind.tournament) {
      _completeTournament(finished);
      return;
    }
    if (_encounterKind == EncounterKind.war) {
      _completeWar(finished);
      return;
    }
    _completeHunt(finished, rounds);
  }

  void _completeTournament(EncounterState finished) {
    final won = finished.victory;
    final stones = won
        ? TournamentEngine.prizeStones(_state)
        : TournamentEngine.prizeStones(_state) * 0.1;
    final contribution = won ? TournamentEngine.prizeContribution(_state) : 5;
    final reputation = won
        ? ReputationEngine.tournamentWinGain(_state)
        : ReputationEngine.tournamentLossGain;
    _state = _state.copyWith(
      spiritStones: _state.spiritStones + stones,
      contribution: _state.contribution + contribution,
      reputation: ReputationEngine.gain(_state, reputation),
      tournamentsWon: _state.tournamentsWon + (won ? 1 : 0),
      lastTournamentAt: DateTime.now(),
    );
    _checkImmortalization();
    _lastEncounterSummary = won
        ? '${TournamentEngine.victoryText(_state)}\n\n'
            '+${formatNumber(stones)} spirit stones, +$contribution '
            'contribution, +$reputation reputation'
        : '${TournamentEngine.defeatText}\n\n'
            '+${formatNumber(stones)} spirit stones, +$contribution '
            'contribution, +$reputation reputation';
    _encounter = finished;
    notifyListeners();
    save();
  }

  void _completeWar(EncounterState finished) {
    final won = finished.victory;
    final stones = won ? WarEngine.prizeStones(_state) : 0.0;
    final contribution = won ? WarEngine.prizeContribution(_state) : 10;
    final reputation = won
        ? ReputationEngine.warWinGain(_state)
        : ReputationEngine.warLossGain;
    _state = _state.copyWith(
      spiritStones: _state.spiritStones + stones,
      contribution: _state.contribution + contribution,
      reputation: ReputationEngine.gain(_state, reputation),
      warsWon: _state.warsWon + (won ? 1 : 0),
      lastWarAt: DateTime.now(),
    );
    _checkImmortalization();
    _lastEncounterSummary = won
        ? '${WarEngine.victoryText(_state)}\n\n'
            '+${formatNumber(stones)} spirit stones, +$contribution '
            'contribution, +$reputation reputation'
        : '${WarEngine.defeatText}\n\n'
            '+$contribution contribution, +$reputation reputation '
            'for holding the line';
    _encounter = finished;
    notifyListeners();
    save();
  }

  void _completeHunt(EncounterState finished, int rounds) {
    final location = effectiveLocation();
    final loot = CombatEngine.rollLoot(_state, location, finished.beast, _rng);
    final battle = BattleResult(
      victory: true,
      rounds: rounds,
      beastName: finished.beast.name,
      log: finished.log,
      loot: loot,
    );
    final outcome = CombatEngine.applyLoot(_state, battle);
    var updated = outcome.state;

    final lines = <String>[];
    if (loot.spiritStones > 0) {
      lines.add('+${formatNumber(loot.spiritStones)} spirit stones');
    }
    if (loot.spiritHerbs > 0) lines.add('+${loot.spiritHerbs} spirit herb(s)');
    if (loot.beastCores > 0) lines.add('+${loot.beastCores} beast core(s)');
    if (loot.equipment != null && outcome.equipped) {
      lines.add(
        'Equipped ${loot.equipment!.name} (${loot.equipment!.gradeName})',
      );
    } else if (loot.equipment != null) {
      lines.add(
        'Sold ${loot.equipment!.name} for '
        '${formatNumber(outcome.soldFor)} spirit stones',
      );
    }
    if (loot.technique != null) {
      lines.add('Discovered technique: ${loot.technique!.name}');
    }
    if (loot.tamedCompanion != null) {
      lines.add('Tamed companion: ${loot.tamedCompanion!.name}');
    }
    final powerId = PowerEngine.rollDiscovery(updated, location, _rng);
    if (powerId != null) {
      final power = PowerCatalog.byId(powerId)!;
      updated = updated.copyWith(
        discoveredPowers: [...updated.discoveredPowers, powerId],
      );
      lines.add('Discovered power: ${power.name} (${power.bonusLabel})');
    }
    final reputationGain = ReputationEngine.huntGain(updated);
    updated = updated.copyWith(
      reputation: ReputationEngine.gain(updated, reputationGain),
    );
    if (_state.raceId != null) {
      lines.add(
        '+$reputationGain reputation with '
        '${ReputationEngine.factionNames[_state.raceId!]}',
      );
    }

    _lastEncounterSummary = lines.isEmpty ? 'Nothing gained.' : lines.join('\n');

    final eventId = EventEngine.maybeTrigger(updated, rng: _rng);
    if (eventId != null) {
      updated = updated.copyWith(pendingEventId: eventId);
    }

    final hiddenId = WorldCatalog.hiddenToDiscover(
      updated.realmIndex,
      updated.discoveredLocations,
    );
    if (hiddenId != null && _rng.nextDouble() < 0.08) {
      updated = updated.copyWith(
        discoveredLocations: [...updated.discoveredLocations, hiddenId],
      );
    }

    _checkImmortalization();
    _state = updated;
    _encounter = finished;
    notifyListeners();
    save();
  }

  void clearEncounter() {
    _encounter = null;
    notifyListeners();
  }

  EventOutcome? resolvePendingEvent(int choiceIndex) {
    final eventId = _state.pendingEventId;
    if (eventId == null) return null;
    final location = effectiveLocation();
    final outcome = EventEngine.resolve(
      _state,
      eventId,
      choiceIndex,
      location,
      rng: _rng,
    );
    if (outcome == null) return null;
    _state = outcome.state.copyWith(pendingEventId: null);
    notifyListeners();
    save();
    return EventOutcome(state: _state, message: outcome.message);
  }

  bool craft(String recipeId) {
    final recipe = AlchemyEngine.recipeById(recipeId);
    if (recipe == null) return false;
    final updated = AlchemyEngine.craft(_state, recipe);
    if (updated == null) return false;
    _state = updated;
    notifyListeners();
    save();
    return true;
  }

  bool useQiPill() {
    if (_state.qiPills <= 0) return false;
    final gain = CultivationEngine.qiPerSecond(_state) * 120;
    _state = _state.copyWith(
      qiPills: _state.qiPills - 1,
      qi: _state.qi + gain,
      totalQiGained: _state.totalQiGained + gain,
    );
    notifyListeners();
    save();
    return true;
  }

  bool useBreakthroughPill() {
    if (_state.breakthroughPills <= 0) return false;
    _state = _state.copyWith(
      breakthroughPills: _state.breakthroughPills - 1,
      breakthroughBonus: min(
        maxBreakthroughBonus,
        _state.breakthroughBonus + 0.2,
      ),
    );
    notifyListeners();
    save();
    return true;
  }

  bool useLifespanPill() {
    if (_state.lifespanPills <= 0) return false;
    _state = _state.copyWith(
      lifespanPills: _state.lifespanPills - 1,
      lifespanBonusYears: _state.lifespanBonusYears + 25,
    );
    notifyListeners();
    save();
    return true;
  }

  bool chooseRace(String raceId, {String? name}) {
    if (_state.raceId != null) return false;
    if (Race.catalog.every((race) => race.id != raceId)) return false;
    final trimmed = name?.trim() ?? '';
    _state = _state.copyWith(
      raceId: raceId,
      legacyName: trimmed.isEmpty || trimmed.length > 20
          ? null
          : trimmed,
    );
    notifyListeners();
    save();
    return true;
  }

  StoryChapter? currentStoryChapter() => StoryEngine.currentChapter(_state);

  StoryOutcome? advanceStory(int choiceIndex) {
    final outcome = StoryEngine.advance(_state, choiceIndex);
    if (outcome == null) return null;
    _state = outcome.state;
    notifyListeners();
    save();
    return outcome;
  }

  String exportSaveJson() => jsonEncode(_state.toJson());

  bool importSaveJson(String raw) {
    if (raw.trim().isEmpty) return false;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return false;
      final parsed = GameState.fromJson(decoded);
      _state = parsed;
      notifyListeners();
      save();
      return true;
    } on FormatException {
      return false;
    } on TypeError {
      return false;
    }
  }

  void resetGame() {
    _state = GameState.initial();
    notifyListeners();
    save();
  }

  bool get monetizationConfigured => _gateway.isConfigured;

  Duration adCooldownRemaining(String placementId) {
    final placement = MonetizationCatalog.placementById(placementId);
    if (placement == null) return Duration.zero;
    return BoostEngine.remainingCooldown(_state, placement);
  }

  Future<bool> watchAdFor(String placementId) async {
    final placement = MonetizationCatalog.placementById(placementId);
    if (placement == null) return false;
    if (BoostEngine.remainingCooldown(_state, placement) > Duration.zero) {
      return false;
    }
    final watched = await _gateway.showRewardedAd(placementId);
    if (!watched) return false;
    _state = BoostEngine.grantPlacement(_state, placement);
    notifyListeners();
    save();
    return true;
  }

  Future<bool> purchaseProduct(String productId) async {
    final product = MonetizationCatalog.productById(productId);
    if (product == null) return false;
    if (product.id == 'immortal_patron' && _state.supportTier) return false;
    if (_state.ownedCosmetics.contains(productId)) return false;
    final bought = await _gateway.purchase(productId);
    if (!bought) return false;
    if (product.kind == 'support') {
      _state = _state.copyWith(
        supportTier: true,
        ownedCosmetics: [
          ..._state.ownedCosmetics,
          productId,
          'theme_celestial_gold',
        ],
      );
    } else {
      _state = _state.copyWith(
        ownedCosmetics: [..._state.ownedCosmetics, productId],
      );
    }
    notifyListeners();
    save();
    return true;
  }

  bool ownsTheme(String? themeId) {
    if (themeId == null) return true;
    return _state.ownedCosmetics.contains(themeId);
  }

  void chooseTheme(String? themeId) {
    if (!ownsTheme(themeId)) return;
    _state = _state.copyWith(activeThemeId: themeId);
    notifyListeners();
    save();
  }

  bool buySectPower(String id) {
    final power = PowerCatalog.byId(id);
    if (power == null || !power.isSectPower) return false;
    if (_state.discoveredPowers.contains(id)) return false;
    if (_state.sectId != power.sectId) return false;
    if (SectEngine.rankOf(_state.contribution) < power.minSectRank) {
      return false;
    }
    if (_state.contribution < power.contributionCost) return false;
    _state = _state.copyWith(
      contribution: _state.contribution - power.contributionCost,
      discoveredPowers: [..._state.discoveredPowers, id],
    );
    notifyListeners();
    save();
    return true;
  }

  void acknowledgeEnding() {
    if (_state.pendingEndingId == null) return;
    _state = _state.copyWith(
      pendingEndingId: null,
      immortalized: true,
    );
    notifyListeners();
    save();
  }

  void acknowledgeLegend() {
    if (!_state.immortalized || _state.legendSeen) return;
    _state = _state.copyWith(legendSeen: true);
    notifyListeners();
    save();
  }

  void _evaluateEnding() {
    final id = EndingEngine.evaluateState(_state);
    if (id == null || _state.achievedEndings.contains(id)) return;
    _state = _state.copyWith(
      pendingEndingId: id,
      achievedEndings: [..._state.achievedEndings, id],
      immortalized: true,
    );
  }

  void _checkImmortalization() {
    if (_state.immortalized || _state.raceId == null) return;
    if (ReputationEngine.tierOf(
          ReputationEngine.ownReputation(_state),
        ) >=
        ReputationEngine.tierThresholds.length - 1) {
      _state = _state.copyWith(immortalized: true);
    }
  }

  void reincarnate() {
    if (!SoulEngine.canReincarnate(_state)) return;
    _state = SoulEngine.reincarnate(_state);
    notifyListeners();
    save();
  }

  bool buySoulUpgrade(String id) {
    final upgrade = SoulUpgrade.byId(id);
    final updated = SoulEngine.buyUpgrade(_state, upgrade);
    if (identical(updated, _state)) return false;
    _state = updated;
    notifyListeners();
    save();
    return true;
  }

  bool joinSect(String sectId) {
    if (!SectEngine.canJoin(_state)) return false;
    _state = SectEngine.join(_state, sectId);
    notifyListeners();
    save();
    return true;
  }

  void leaveSect() {
    if (_state.sectId == null) return;
    _state = _state.copyWith(
      sectId: null,
      contribution: 0,
      disciples: const [],
      missionLog: const [],
    );
    notifyListeners();
    save();
  }

  bool recruitDisciple() {
    final updated = DiscipleEngine.recruit(_state, rng: _rng);
    if (identical(updated, _state)) return false;
    _state = updated;
    notifyListeners();
    save();
    return true;
  }

  bool dispatchDisciple(int index, String missionId, double hours) {
    final updated = DiscipleEngine.dispatch(_state, index, missionId, hours);
    if (identical(updated, _state)) return false;
    _state = updated;
    notifyListeners();
    save();
    return true;
  }

  Future<void> save() async {
    _state = _state.copyWith(lastSaved: DateTime.now());
    await _repository.save(_state);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _timer?.cancel();
      _timer = null;
      save();
    } else if (state == AppLifecycleState.resumed) {
      _applyOfflineGains();
      _startTimer();
      notifyListeners();
    }
  }
}
