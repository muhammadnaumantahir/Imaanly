import 'package:flutter/material.dart';

import '../data/dhikr_progress_store.dart';

/// Lightweight history view for completed daily Dhikr targets.
class DhikrHistoryPage extends StatefulWidget {
  const DhikrHistoryPage({super.key});

  @override
  State<DhikrHistoryPage> createState() => _DhikrHistoryPageState();
}

class _DhikrHistoryPageState extends State<DhikrHistoryPage> {
  final _store = const DhikrProgressStore();
  late Future<Set<String>> _dates;

  @override
  void initState() {
    super.initState();
    _dates = _store.loadCompletedDates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dhikr history')),
      body: FutureBuilder<Set<String>>(
        future: _dates,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final dates = (snapshot.data ?? <String>{}).toList()..sort((a, b) => b.compareTo(a));
          if (dates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Complete a daily Dhikr target to start your history.'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.check)),
                title: Text(dates[index]),
                subtitle: const Text('Daily target completed'),
              ),
            ),
          );
        },
      ),
    );
  }
}
