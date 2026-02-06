import 'dart:math';

/// Model class for location data and Qibla calculations
class LocationData {
  final double latitude;
  final double longitude;
  final double qiblaBearing;
  final double distanceToKaaba;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.qiblaBearing,
    required this.distanceToKaaba,
  });

  /// Kaaba coordinates in Mecca
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla direction from current location
  factory LocationData.fromCoordinates(double latitude, double longitude) {
    final qiblaBearing = _calculateQiblaBearing(latitude, longitude);
    final distance = _calculateDistance(latitude, longitude);

    return LocationData(
      latitude: latitude,
      longitude: longitude,
      qiblaBearing: qiblaBearing,
      distanceToKaaba: distance,
    );
  }

  /// Calculate bearing to Kaaba using spherical geometry
  static double _calculateQiblaBearing(double lat, double lon) {
    // Convert to radians
    final lat1 = _toRadians(lat);
    final lon1 = _toRadians(lon);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    final dLon = lon2 - lon1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    final bearing = atan2(y, x);

    // Convert to degrees and normalize to 0-360
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// Calculate distance to Kaaba using Haversine formula
  static double _calculateDistance(double lat, double lon) {
    const earthRadius = 6371.0; // km

    final lat1 = _toRadians(lat);
    final lon1 = _toRadians(lon);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;

  @override
  String toString() {
    return 'LocationData(lat: ${latitude.toStringAsFixed(6)}, '
        'lon: ${longitude.toStringAsFixed(6)}, '
        'qiblaBearing: ${qiblaBearing.toStringAsFixed(2)}°, '
        'distance: ${distanceToKaaba.toStringAsFixed(2)} km)';
  }
}
