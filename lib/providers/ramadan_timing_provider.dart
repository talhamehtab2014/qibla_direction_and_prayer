import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:qibla_direction/models/ramadan_timing_model.dart';
import 'package:qibla_direction/services/notification_service.dart';
import 'package:qibla_direction/services/ramadan_timing_service.dart';

class RamadanTimingProvider extends ChangeNotifier {
  final RamadanTimingService _service = RamadanTimingService();

  RamadanTiming? _currentTiming;
  bool _isLoading = false;
  String? _errorMessage;

  RamadanTiming? get currentTiming => _currentTiming;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches today's Ramadan timing
  Future<void> fetchTodayTiming() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentTiming = await _service.getTodayTiming();
      _isLoading = false;
      notifyListeners();

      if (_currentTiming != null) {
        _scheduleNotifications(_currentTiming!);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Refreshes the timing data
  Future<void> refresh() async {
    await fetchTodayTiming();
  }

  void _scheduleNotifications(RamadanTiming timing) {
    try {
      // The model dates come in format "22 Feb 2026"
      // the times come in format e.g. "05:14 AM" or "06:17 PM"
      final dateFormatter = DateFormat('d MMM yyyy');
      final timeFormatter = DateFormat('hh:mm a');

      final date = dateFormatter.parse(timing.date);
      final iftarTime = timeFormatter.parse(timing.iftar);
      final sehriTime = timeFormatter.parse(timing.sehri);

      final todayIftarTime = DateTime(
        date.year,
        date.month,
        date.day,
        iftarTime.hour,
        iftarTime.minute,
      );

      // Sehri is typically the next morning, but in the model 'timing' it might represent
      // the date's sehri. To be robust, if it's already past today's sehri, we should
      // ideally schedule tomorrow's. However, the requirement is 1 hour before Sehri time.
      // Assuming `timing` represents today's fast, iftar is today, sehri might be tomorrow or today morning.
      // Let's just create a DateTime for the date and the parsed sehri time.
      final sehriDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        sehriTime.hour,
        sehriTime.minute,
      );

      // If today's sehri time is already in the past, maybe the user wants tomorrow's sehri.
      // But the model is per day. We'll pass the date's Sehri and Iftar. The NotificationService
      // checks if the time is in the future before scheduling.

      NotificationService().scheduleRamadanNotifications(
        todayIftarTime: todayIftarTime,
        tomorrowSehriTime: sehriDateTime,
      );
    } catch (e) {
      debugPrint(
        "Error parsing and scheduling Ramadan Timing notifications: $e",
      );
    }
  }
}
