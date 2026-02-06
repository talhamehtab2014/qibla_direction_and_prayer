import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

/// Service for handling compass/magnetometer functionality
class CompassService {
  StreamSubscription<CompassEvent>? _compassSubscription;

  /// Check if compass is available on the device
  Future<bool> isCompassAvailable() async {
    try {
      final compassStream = FlutterCompass.events;
      if (compassStream == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get compass heading stream
  /// Returns null if compass is not available
  Stream<CompassEvent>? getCompassStream() {
    return FlutterCompass.events;
  }

  /// Get combined stream of compass heading and Qibla direction
  /// Returns the angle to rotate the compass to point to Qibla
  Stream<double>? getQiblaDirectionStream(double qiblaBearing) {
    final compassStream = getCompassStream();
    if (compassStream == null) {
      return null;
    }

    return compassStream.map((event) {
      // Some devices return null heading
      double heading = event.heading ?? 0.0;

      // Normalize heading to 0-360
      if (heading < 0) {
        heading += 360;
      }

      // Calculate the angle difference between current heading and Qibla
      // This gives us the rotation needed to point to Qibla
      double qiblaDirection = qiblaBearing - heading;

      // Normalize to -180 to 180 range for shortest rotation
      if (qiblaDirection > 180) {
        qiblaDirection -= 360;
      } else if (qiblaDirection < -180) {
        qiblaDirection += 360;
      }

      return qiblaDirection;
    });
  }

  /// Dispose compass subscription
  void dispose() {
    _compassSubscription?.cancel();
  }
}
