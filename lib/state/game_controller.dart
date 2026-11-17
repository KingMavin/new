import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:immortal_path/game/engine/alchemy_engine.dart';
import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/disciple_engine.dart';
import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/engine/tribulation_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/soul_upgrade.dart';
import 'package:immortal_path/game/models/zone.dart';
import 'package:immortal_path/game/persistence/shared_prefs_save_repository.dart';

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

  GameState get state => _state;

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

  void selectZone(int index) {
    final zones = ZoneCatalog.zones;
    if (index < 0 || index >= zones.length) return;
    if (_state.realmIndex < zones[index].requiredRealm) return;
    _state = _state.copyWith(selectedZoneIndex: index);
    notifyListeners();
  }

  int effectiveZoneIndex() {
    final zones = ZoneCatalog.zones;
    var index = _state.selectedZoneIndex.clamp(0, zones.length - 1).toInt();
    if (_state.realmIndex < zones[index].requiredRealm) {
      for (var i = zones.length - 1; i >= 0; i--) {
        if (_state.realmIndex >= zones[i].requiredRealm) {
          index = i;
          break;
        }
      }
    }
    return index;
  }

  ExploreOutcome? explore() {
    final zone = ZoneCatalog.zones[effectiveZoneIndex()];
    final beast = zone.beasts[_rng.nextInt(zone.beasts.length)];
    final battle = CombatEngine.resolve(_state, zone, beast, rng: _rng);
    final outcome = CombatEngine.applyLoot(_state, battle);
    var updated = outcome.state;
    if (battle.victory) {
      final eventId = EventEngine.maybeTrigger(updated, rng: _rng);
      if (eventId != null) {
        updated = updated.copyWith(pendingEventId: eventId);
      }
    }
    _state = updated;
    notifyListeners();
    save();
    return outcome;
  }

  EventOutcome? resolvePendingEvent(int choiceIndex) {
    final eventId = _state.pendingEventId;
    if (eventId == null) return null;
    final zone = ZoneCatalog.zones[effectiveZoneIndex()];
    final outcome = EventEngine.resolve(
      _state,
      eventId,
      choiceIndex,
      zone,
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
