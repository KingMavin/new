import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:immortal_path/game/engine/alchemy_engine.dart';
import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/tribulation_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/game_state.dart';
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
    notifyListeners();
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
    _state = outcome.state;
    notifyListeners();
    save();
    return outcome;
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
