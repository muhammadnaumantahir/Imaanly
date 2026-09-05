import 'dart:math' as math;

/// Pure, offline calculations used by the Qibla experience.
///
/// Keeping these calculations independent from Flutter makes them easy to
/// verify and keeps the core Qibla experience free of network dependencies.
class QiblaCalculator {
  const QiblaCalculator._();

  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;
  static const double earthRadiusKm = 6371.0088;

  static double normalizeDegrees(double value) => (value % 360 + 360) % 360;

  static double shortestSignedDifference(double fromDegrees, double toDegrees) {
    final normalized = normalizeDegrees(toDegrees - fromDegrees);
    return normalized > 180 ? normalized - 360 : normalized;
  }

  static double distanceToKaaba(double latitude, double longitude) {
    final lat1 = latitude * math.pi / 180;
    final lat2 = kaabaLatitude * math.pi / 180;
    final deltaLat = (kaabaLatitude - latitude) * math.pi / 180;
    final deltaLon = (kaabaLongitude - longitude) * math.pi / 180;

    final sinLat = math.sin(deltaLat / 2);
    final sinLon = math.sin(deltaLon / 2);
    final a = sinLat * sinLat +
        math.cos(lat1) * math.cos(lat2) * sinLon * sinLon;
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }
}
