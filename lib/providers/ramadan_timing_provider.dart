import 'package:flutter/foundation.dart';
import 'package:qibla_direction/models/ramadan_timing_model.dart';
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
}
