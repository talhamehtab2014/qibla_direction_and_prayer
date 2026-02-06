import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qibla_direction/models/prayer_times.dart';
import 'package:qibla_direction/services/location_service.dart';
import 'package:qibla_direction/services/prayer_service.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _prayerService = PrayerService();
  final LocationService _locationService = LocationService();

  PrayerTimes? _prayerTimes;
  bool _isLoading = false;
  String? _errorMessage;
  String? _upcomingPrayer;
  Duration? _timeLeft;
  Timer? _timer;
  String _locationName = 'Current Location';
  double? _latitude;
  double? _longitude;

  // Settings
  int _selectedMethod = 4; // Default: Umm Al-Qura University, Makkah
  int _selectedSchool = 0; // Default: Shafi (Standard)
  int? _midnightMode;
  int? _latitudeAdjustmentMethod;

  PrayerTimes? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get upcomingPrayer => _upcomingPrayer;
  Duration? get timeLeft => _timeLeft;
  String get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  int get selectedMethod => _selectedMethod;
  int get selectedSchool => _selectedSchool;
  int? get midnightMode => _midnightMode;
  int? get latitudeAdjustmentMethod => _latitudeAdjustmentMethod;

  // Makkah coordinates for fallback
  static const double _makkahLat = 21.4225;
  static const double _makkahLng = 39.8262;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _loadSettings();

    try {
      double lat = _makkahLat;
      double lng = _makkahLng;
      _locationName = 'Makkah';

      try {
        final location = await _locationService.getLocationData();
        lat = location.latitude;
        lng = location.longitude;
        _locationName = 'Current Location';
      } catch (e) {
        // Fallback to Makkah if location is not available
        debugPrint('Location error, falling back to Makkah: $e');
      }

      _latitude = lat;
      _longitude = lng;

      _prayerTimes = await _prayerService.fetchPrayerTimes(
        latitude: lat,
        longitude: lng,
        method: _selectedMethod,
        school: _selectedSchool,
        midnightMode: _midnightMode,
        latitudeAdjustmentMethod: _latitudeAdjustmentMethod,
      );

      _updateUpcomingPrayer();
      _startTimer();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedMethod = prefs.getInt('prayer_method') ?? 4;
    _selectedSchool = prefs.getInt('prayer_school') ?? 0;
    _midnightMode = prefs.containsKey('midnight_mode')
        ? prefs.getInt('midnight_mode')
        : null;
    _latitudeAdjustmentMethod = prefs.containsKey('latitude_adj')
        ? prefs.getInt('latitude_adj')
        : null;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayer_method', _selectedMethod);
    await prefs.setInt('prayer_school', _selectedSchool);
    if (_midnightMode != null) {
      await prefs.setInt('midnight_mode', _midnightMode!);
    } else {
      await prefs.remove('midnight_mode');
    }
    if (_latitudeAdjustmentMethod != null) {
      await prefs.setInt('latitude_adj', _latitudeAdjustmentMethod!);
    } else {
      await prefs.remove('latitude_adj');
    }
  }

  Future<void> updateSettings(
    int method,
    int school, {
    int? midnightMode,
    int? latitudeAdj,
  }) async {
    _selectedMethod = method;
    _selectedSchool = school;
    _midnightMode = midnightMode;
    _latitudeAdjustmentMethod = latitudeAdj;
    await _saveSettings();
    await initialize(); // Refresh data with new settings
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _updateUpcomingPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final timings = _prayerTimes!.asMap;

    String? next;
    DateTime? nextTime;

    for (var entry in timings.entries) {
      final prayerTime = _parseTime(entry.value);
      if (prayerTime.isAfter(now)) {
        if (nextTime == null || prayerTime.isBefore(nextTime)) {
          next = entry.key;
          nextTime = prayerTime;
        }
      }
    }

    // If no more prayers today, next is Fajr tomorrow
    next ??= 'Fajr';

    _upcomingPrayer = next;
    _calculateTimeLeft();
  }

  void _calculateTimeLeft() {
    if (_prayerTimes == null || _upcomingPrayer == null) return;

    final now = DateTime.now();
    final timingStr = _prayerTimes!.asMap[_upcomingPrayer];

    if (timingStr == null && _upcomingPrayer == 'Fajr') {
      // Logic for Fajr tomorrow could be added here if needed for exact countdown
      // For now, just set a placeholder or refresh at midnight
      _timeLeft = Duration.zero;
    } else if (timingStr != null) {
      final prayerTime = _parseTime(timingStr);
      _timeLeft = prayerTime.difference(now);

      if (_timeLeft!.isNegative) {
        _updateUpcomingPrayer();
      }
    }

    notifyListeners();
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
