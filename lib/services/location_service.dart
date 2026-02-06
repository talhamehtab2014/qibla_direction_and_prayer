import 'package:geolocator/geolocator.dart';
import 'package:qibla_direction/models/location_data.dart';

/// Custom exception for permanently denied location permissions
class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message;
  LocationPermissionPermanentlyDeniedException(this.message);

  @override
  String toString() => message;
}

/// Service for handling location and GPS functionality
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current device location
  /// Throws LocationPermissionPermanentlyDeniedException if permission is permanently denied
  /// Throws general Exception for other permission or service issues
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get location data with Qibla calculations
  Future<LocationData> getLocationData() async {
    final position = await getCurrentPosition();
    return LocationData.fromCoordinates(position.latitude, position.longitude);
  }

  /// Stream location updates (for continuous tracking)
  Stream<LocationData> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (position) =>
          LocationData.fromCoordinates(position.latitude, position.longitude),
    );
  }
}
