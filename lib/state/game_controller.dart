import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
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

  final SaveRepository _repository;
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

  BreakthroughResult? attemptBreakthrough() {
    if (!CultivationEngine.isBreakthroughReady(_state)) return null;
    final result = CultivationEngine.attemptBreakthrough(_state);
    _state = result.state;
    notifyListeners();
    save();
    return result;
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
