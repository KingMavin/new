import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:immortal_path/game/engine/alchemy_engine.dart';
import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/disciple_engine.dart';
import 'package:immortal_path/game/engine/encounter_engine.dart';
import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/engine/tribulation_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/soul_upgrade.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/game/persistence/shared_prefs_save_repository.dart';
import 'package:immortal_path/game/util/format.dart';

class GameController extends ChangeNotifier with WidgetsBindingObserver {
  GameController({SaveRepository? repository})
      : _repository = repository ?? SharedPrefsSaveRepository() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration _tickInterval = Duration(milliseconds: 250);
  static const Duration _autosaveInterval = Duration(seconds: 30);
  static const Duration _offlineReportThreshold = Duration(seconds: 30);
  static const Duration maxOfflineDuration = Duration(hours: 24);
  static const double maxBreakthroughBonus = 0.5;

  final SaveRepository _repository;
  final Random _rng = Random();
  Timer? _timer;
  DateTime _lastTick = DateTime.now();
  DateTime _lastSave = DateTime.now();
  GameState _state = GameState.initial();
  OfflineReport? _pendingOfflineReport;
  EncounterState? _encounter;
  String? _lastEncounterSummary;

  GameState get state => _state;
  EncounterState? get encounter => _encounter;
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
    final outcome = TribulationEngine.faceWave(_state, action, rng: _rng);
    _state = outcome.state;
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
    if (_state.realmIndex < location.requiredRealm) return false;
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
          _state.realmIndex >= location.requiredRealm) {
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

  void startEncounter() {
    final location = effectiveLocation();
    final beast = location.beasts[_rng.nextInt(location.beasts.length)];
    _encounter = EncounterEngine.begin(_state, beast);
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
