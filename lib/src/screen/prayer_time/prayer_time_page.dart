import "package:imaanly/src/core/notifications/wahy_notification_service.dart";
import "package:imaanly/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:imaanly/src/screen/location_handler/location_aquire.dart";
import "package:imaanly/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:imaanly/src/screen/prayer_time/prayer_timeline_page.dart";
import "package:imaanly/src/screen/prayer_time/time_list_of_prayers.dart";
import "package:imaanly/src/screen/mushaf/widgets/wahy_side_drawer.dart";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

/// Imaanly's daily Salah schedule.
///
/// The existing prayer engine remains the source of truth for calculation,
/// adjustments, notifications and related prayer features. This page only
/// provides the Imaanly presentation shell around that stable functionality.
class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize local notification channels before the prayer UI can schedule
    // alerts. No server, API key, or paid service is required.
    WahyNotificationService.instance.init().catchError((error) {
      debugPrint("[Imaanly] Prayer notification init failed: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: cs.surface,
      drawer: WahySideDrawer(
        primary: cs.primary,
        onOpenIndex: () {},
        onOpenBookmarks: () {},
        onOpenStarred: () {},
        onOpenNotes: () {},
        onJumpToAyah: (_) {},
      ),
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Prayer Times",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: cs.onSurface,
              ),
            ),
            Text(
              "مواقيت الصلاة",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Icon(Icons.menu_rounded, color: cs.primary),
          tooltip: "Main menu",
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrayerTimelinePage()),
              );
            },
            icon: Icon(Icons.view_timeline_rounded, color: cs.primary),
            tooltip: "Prayer timeline",
          ),
        ],
      ),
      body: BlocBuilder<
        LocationQiblaPrayerDataCubit,
        LocationQiblaPrayerDataState
      >(
        builder: (context, state) {
          if (state.latLon == null) {
            return const LocationAcquire();
          }
          return const TimeListOfPrayers();
        },
      ),
    );
  }
}
