import 'package:flutter/material.dart';
import 'package:imaanly/features/fasting/data/fasting_repository.dart';
import 'package:imaanly/features/fasting/presentation/fasting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastingLauncherScreen extends StatelessWidget {
  const FastingLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return FastingScreen(repository: FastingRepository(snapshot.data!));
      },
    );
  }
}
