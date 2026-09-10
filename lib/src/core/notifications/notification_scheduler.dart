import "package:imaanly/src/core/notifications/khatma_notification_service.dart";
import "package:imaanly/src/core/notifications/smart_notification_background_service.dart";
import "package:imaanly/src/platform_services.dart" as platform_services;

abstract class NotificationScheduler {
  Future<void> initialize();
}

class LocalNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> initialize() async {
    final platform = platform_services.getPlatform();

    // Local notifications and Workmanager are not available on Flutter Web.
    // Do not initialize their native implementations on Chrome/Wasm, as the
    // underlying packages may access dart:io Platform APIs.
    if (platform == platform_services.PlatformOwn.isWeb ||
        platform == platform_services.PlatformOwn.isWasm) {
      return;
    }

    await KhatmaNotificationService.instance.init();

    if (platform != platform_services.PlatformOwn.isLinux &&
        platform != platform_services.PlatformOwn.isWindows) {
      await platform_services.initAwesomeNotification();
    }

    // Workmanager is intended for Android/iOS background execution. Desktop
    // and web should not attempt to initialize it during app startup.
    if (platform == platform_services.PlatformOwn.isAndroid ||
        platform == platform_services.PlatformOwn.isIos) {
      await SmartNotificationBackgroundService.initialize();
    }
  }
}
