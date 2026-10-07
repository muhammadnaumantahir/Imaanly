import 'dart:convert';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/theme/app_widgets.dart';

class _Dhikr {
  const _Dhikr(this.short, this.arabic, this.transliteration, this.meaning);

  final String short;
  final String arabic;
  final String transliteration;
  final String meaning;
}

const List<_Dhikr> _dhikrList = [
  _Dhikr('SubhanAllah', 'سُبْحَانَ اللَّهِ', 'SubhanAllah', 'Glory be to Allah'),
  _Dhikr('Alhamdulillah', 'الْحَمْدُ لِلَّهِ', 'Alhamdulillah', 'All praise is for Allah'),
  _Dhikr('Allahu Akbar', 'اللَّهُ أَكْبَرُ', 'Allahu Akbar', 'Allah is the Greatest'),
  _Dhikr('La ilaha illallah', 'لَا إِلَٰهَ إِلَّا اللَّهُ', 'La ilaha illallah', 'There is no god but Allah'),
  _Dhikr('Astaghfirullah', 'أَسْتَغْفِرُ اللَّهَ', 'Astaghfirullah', 'I seek forgiveness from Allah'),
  _Dhikr('Salawat', 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ', 'Allahumma salli wa sallim ala nabiyyina Muhammad', 'O Allah, send blessings and peace upon our Prophet Muhammad'),
];

/// Digital tasbih: tap to count, per-dhikr progress, daily and lifetime totals.
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const List<int> _targets = [33, 99, 100, 0]; // 0 = no target

  SharedPreferences? _prefs;
  int _index = 0;
  int _target = 33;
  final List<int> _counts = List<int>.filled(_dhikrList.length, 0);
  int _today = 0;
  int _lifetime = 0;
  final Map<String, int> _history = {};
  bool _haptics = true;
  bool _pressed = false;

  String get _todayStamp {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _index = (prefs.getInt('tasbih_index') ?? 0).clamp(0, _dhikrList.length - 1).toInt();
      _target = prefs.getInt('tasbih_target') ?? 33;
      _lifetime = prefs.getInt('tasbih_lifetime') ?? 0;
      _haptics = prefs.getBool('tasbih_haptics') ?? true;
      for (var i = 0; i < _counts.length; i++) {
        _counts[i] = prefs.getInt('tasbih_count_$i') ?? 0;
      }
      _today = prefs.getString('tasbih_today_date') == _todayStamp
          ? (prefs.getInt('tasbih_today_count') ?? 0)
          : 0;
      final rawHistory = prefs.getString('tasbih_history');
      if (rawHistory != null) {
        try {
          final map = jsonDecode(rawHistory) as Map<String, dynamic>;
          map.forEach((k, v) {
            if (v is int) _history[k] = v;
          });
        } catch (_) {}
      }
    });
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setInt('tasbih_index', _index);
    await prefs.setInt('tasbih_target', _target);
    await prefs.setInt('tasbih_lifetime', _lifetime);
    await prefs.setBool('tasbih_haptics', _haptics);
    await prefs.setInt('tasbih_count_$_index', _counts[_index]);
    await prefs.setString('tasbih_today_date', _todayStamp);
    await prefs.setInt('tasbih_today_count', _today);
    _history[_histKey(DateTime.now())] = _today;
    if (_history.length > 60) {
      final keys = _history.keys.toList()..sort();
      for (final k in keys.take(_history.length - 60)) {
        _history.remove(k);
      }
    }
    await prefs.setString('tasbih_history', jsonEncode(_history));
  }

  String _histKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _countOn(DateTime d) {
    final key = _histKey(d);
    final now = DateTime.now();
    if (key == _histKey(now)) return _today;
    return _history[key] ?? 0;
  }

  int get _streak {
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (_countOn(day) == 0) day = DateTime(day.year, day.month, day.day - 1);
    var streak = 0;
    while (_countOn(day) > 0) {
      streak++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return streak;
  }

  int get _count => _counts[_index];

  void _increment() {
    setState(() {
      _counts[_index]++;
      _today++;
      _lifetime++;
    });
    if (_haptics) {
      if (_target > 0 && _count % _target == 0) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    _save();
  }

  void _undo() {
    if (_count == 0) return;
    setState(() {
      _counts[_index]--;
      if (_today > 0) _today--;
      if (_lifetime > 0) _lifetime--;
    });
    _save();
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset counter?'),
        content: Text('This clears the count for ${_dhikrList[_index].short}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _counts[_index] = 0);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dhikr = _dhikrList[_index];

    final inRound = _target == 0 ? _count : _count % _target;
    final roundDone = _target > 0 && _count > 0 && inRound == 0;
    final display = _target == 0 ? _count : (roundDone ? _target : inRound);
    final progress = _target == 0 ? 0.0 : (roundDone ? 1.0 : inRound / _target);
    final rounds = _target == 0 ? 0 : _count ~/ _target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih'),
        actions: [
          IconButton(
            tooltip: _haptics ? 'Vibration on' : 'Vibration off',
            icon: Icon(_haptics ? Icons.vibration_rounded : Icons.phone_android_rounded),
            onPressed: () {
              setState(() => _haptics = !_haptics);
              _save();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dhikrList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ChoiceChip(
                  label: Text(_dhikrList[i].short),
                  selected: i == _index,
                  onSelected: (_) {
                    setState(() => _index = i);
                    _save();
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            HeroCard(
              showSkyline: true,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 52),
              child: Column(
                children: [
                  Text(
                    dhikr.arabic,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, height: 1.7, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dhikr.transliteration,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dhikr.meaning,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Center(
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressed = true),
                onTapCancel: () => setState(() => _pressed = false),
                onTapUp: (_) => setState(() => _pressed = false),
                onTap: _increment,
                child: AnimatedScale(
                  scale: _pressed ? 0.95 : 1,
                  duration: const Duration(milliseconds: 90),
                  child: SizedBox(
                    width: 244,
                    height: 244,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 244,
                          height: 244,
                          child: CircularProgressIndicator(
                            value: _target == 0 ? 0 : progress,
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                            backgroundColor: cs.primaryContainer.withValues(alpha: 0.6),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC9A24B)),
                          ),
                        ),
                        Container(
                          width: 204,
                          height: 204,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.heroGradient(isDark),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF063D2E).withValues(alpha: 0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$display',
                                style: const TextStyle(
                                  fontSize: 68,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              Text(
                                _target == 0 ? 'Tap to count' : 'of $_target',
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                _target == 0
                    ? 'Total ${_count}'
                    : (rounds == 0 ? 'Round 1' : 'Completed $rounds ${rounds == 1 ? 'round' : 'rounds'}'),
                style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                for (final t in _targets)
                  ChoiceChip(
                    label: Text(t == 0 ? 'No target' : '$t'),
                    selected: _target == t,
                    onSelected: (_) {
                      setState(() => _target = t);
                      _save();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Today', value: _today, icon: Icons.today_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'All time', value: _lifetime, icon: Icons.all_inclusive_rounded)),
              ],
            ),
            const SizedBox(height: 14),
            _HistoryCard(
              values: [
                for (var i = 6; i >= 0; i--)
                  _countOn(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - i)),
              ],
              weekdays: [
                for (var i = 6; i >= 0; i--)
                  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - i).weekday,
              ],
              streak: _streak,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _count == 0 ? null : _undo,
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Undo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _count == 0 ? null : _confirmReset,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SoftCard(
      child: Row(
        children: [
          IconBadge(icon: icon, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.values, required this.weekdays, required this.streak});

  final List<int> values;
  final List<int> weekdays;
  final int streak;

  static const List<String> _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxValue = values.fold<int>(1, (a, b) => b > a ? b : a);
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Last 7 days', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              Icon(Icons.local_fire_department_rounded, size: 18, color: streak > 0 ? AppColors.goldDeep : cs.outline),
              const SizedBox(width: 4),
              Text(
                streak == 1 ? '1 day streak' : '$streak day streak',
                style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          values[i] == 0 ? '' : '${values[i]}',
                          style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 20,
                          height: values[i] == 0 ? 4 : 8 + 52 * values[i] / maxValue,
                          decoration: BoxDecoration(
                            color: i == values.length - 1 ? cs.primary : cs.primary.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _letters[weekdays[i] - 1],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == values.length - 1 ? FontWeight.w800 : FontWeight.w600,
                            color: i == values.length - 1 ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
