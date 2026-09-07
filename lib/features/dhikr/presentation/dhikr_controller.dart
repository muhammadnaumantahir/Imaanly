import 'package:flutter/foundation.dart';

import '../data/dhikr_progress_store.dart';
import '../domain/dhikr_progress.dart';

class DhikrController extends ChangeNotifier {
  DhikrController({DhikrProgressStore? store})
      : _store = store ?? const DhikrProgressStore();

  final DhikrProgressStore _store;
  DhikrProgress _progress = const DhikrProgress(goal: 33, completed: 0);
  int _streak = 0;
  bool _loading = true;
  bool _busy = false;

  DhikrProgress get progress => _progress;
  int get streak => _streak;
  bool get loading => _loading;
  bool get busy => _busy;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _progress = await _store.load();
    _streak = await _store.loadCurrentStreak();
    _loading = false;
    notifyListeners();
  }

  Future<void> increment([int amount = 1]) async {
    if (_busy || _progress.isGoalComplete) return;
    _busy = true;
    notifyListeners();
    try {
      _progress = await _store.increment(amount: amount);
      _streak = await _store.loadCurrentStreak();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> setGoal(int goal) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      await _store.setGoal(goal);
      _progress = await _store.load();
      _streak = await _store.loadCurrentStreak();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
