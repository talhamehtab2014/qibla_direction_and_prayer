import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:qibla_direction/models/location_data.dart';
import 'package:qibla_direction/services/compass_service.dart';
import 'package:qibla_direction/services/location_service.dart';

/// Provider for managing Qibla compass state
class QiblaProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final CompassService _compassService = CompassService();

  LocationData? _locationData;
  double? _compassHeading;
  double? _qiblaDirection;
  double? _accuracy;
  bool _needsCalibration = false;

  bool _isLoading = false;
  bool _hasPermission = false;
  bool _isCompassAvailable = false;
  bool _isPermanentlyDenied = false;
  String? _errorMessage;

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<double>? _qiblaSubscription;

  // Getters
  LocationData? get locationData => _locationData;
  double? get compassHeading => _compassHeading;
  double? get qiblaDirection => _qiblaDirection;
  double? get accuracy => _accuracy;
  bool get needsCalibration => _needsCalibration;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  bool get isCompassAvailable => _isCompassAvailable;
  bool get isPermanentlyDenied => _isPermanentlyDenied;
  String? get errorMessage => _errorMessage;

  /// Initialize compass and location
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    _isPermanentlyDenied = false;
    notifyListeners();

    try {
      // Check compass availability
      _isCompassAvailable = await _compassService.isCompassAvailable();
      if (!_isCompassAvailable) {
        throw Exception('Compass sensor not available on this device');
      }

      // Get location data
      _locationData = await _locationService.getLocationData();
      _hasPermission = true;

      // Start compass stream
      _startCompassStream();

      _isLoading = false;
      notifyListeners();
    } on LocationPermissionPermanentlyDeniedException catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _hasPermission = false;
      _isPermanentlyDenied = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _hasPermission = false;
      _isPermanentlyDenied = false;
      notifyListeners();
    }
  }

  /// Start listening to compass stream
  void _startCompassStream() {
    if (_locationData == null) return;

    // Listen to raw compass event for heading and accuracy
    final compassStream = _compassService.getCompassStream();
    if (compassStream != null) {
      _compassSubscription = compassStream.listen((event) {
        // Normalize heading to 0-360
        double heading = event.heading ?? 0.0;
        if (heading < 0) {
          heading += 360;
        }
        _compassHeading = heading;
        _accuracy = event.accuracy;

        // Determine if calibration is needed
        // On Android, accuracy is 0-3 (0=unreliable, 1=low)
        // On iOS, accuracy is in degrees (>15 is considered low)
        if (defaultTargetPlatform == TargetPlatform.android) {
          _needsCalibration = event.accuracy != null && event.accuracy! <= 1;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          _needsCalibration = event.accuracy != null && event.accuracy! > 15;
        }

        notifyListeners();
      });
    }

    // Listen to Qibla direction stream
    final qiblaStream = _compassService.getQiblaDirectionStream(
      _locationData!.qiblaBearing,
    );
    if (qiblaStream != null) {
      _qiblaSubscription = qiblaStream.listen((direction) {
        _qiblaDirection = direction;
        notifyListeners();
      });
    }
  }

  /// Refresh location data
  Future<void> refreshLocation() async {
    try {
      _locationData = await _locationService.getLocationData();

      // Restart compass stream with new bearing
      _compassSubscription?.cancel();
      _qiblaSubscription?.cancel();
      _startCompassStream();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh location: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _qiblaSubscription?.cancel();
    _compassService.dispose();
    super.dispose();
  }
}
