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
  String? _currentPrayer;
  Duration? _timeLeft;
  Timer? _timer;
  String _locationName = 'Current Location';
  double? _latitude;
  double? _longitude;
  bool _isDisposed = false;

  // Settings
  int _selectedMethod = 4; // Default: Umm Al-Qura University, Makkah
  int _selectedSchool = 0; // Default: Shafi (Standard)
  int? _midnightMode;
  int? _latitudeAdjustmentMethod;

  PrayerTimes? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get upcomingPrayer => _upcomingPrayer;
  String? get currentPrayer => _currentPrayer;
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
    if (!_isDisposed) notifyListeners();

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
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_isDisposed) notifyListeners();
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
    String? current;

    final entries = timings.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final prayerTime = _parseTime(entries[i].value);

      if (prayerTime.isAfter(now)) {
        if (nextTime == null || prayerTime.isBefore(nextTime)) {
          next = entries[i].key;
          nextTime = prayerTime;
        }
      } else {
        current = entries[i].key;
      }
    }

    _upcomingPrayer = next ?? 'Fajr';
    _currentPrayer = current ?? 'Isha';

    if (!_isDisposed) notifyListeners();
  }

  void _calculateTimeLeft() {
    if (_prayerTimes == null || _upcomingPrayer == null) return;

    final now = DateTime.now();
    final timingStr = _prayerTimes!.asMap[_upcomingPrayer];

    if (timingStr != null) {
      DateTime prayerTime = _parseTime(timingStr);

      // If prayer time is in the past, it might be Fajr for tomorrow
      if (prayerTime.isBefore(now)) {
        if (_upcomingPrayer == 'Fajr') {
          prayerTime = prayerTime.add(const Duration(days: 1));
        } else {
          // Some other prayer just passed, update the upcoming prayer
          _updateUpcomingPrayer();
          return; // The next timer tick will calculate for the new upcoming prayer
        }
      }

      _timeLeft = prayerTime.difference(now);
    } else if (_upcomingPrayer == 'Fajr') {
      // Small helper if Fajr is not in the map for some reason but we know it's next
      // This is a safety guard
      _timeLeft = Duration.zero;
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
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
