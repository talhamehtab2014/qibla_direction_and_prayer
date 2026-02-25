import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qibla_direction/models/ramadan_day.dart';
import 'package:qibla_direction/services/ramadan_service.dart';

class RamadanProvider extends ChangeNotifier {
  final RamadanService _ramadanService = RamadanService();

  List<RamadanDay> _ramadanDays = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RamadanDay> get ramadanDays => _ramadanDays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRamadanCalendar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final adj = prefs.getInt('hijri_adj') ?? 0;
      final calendarMethod = prefs.getString('calendar_method') ?? 'HJCoSA';
      final method = prefs.getInt('prayer_method') ?? 4;
      final school = prefs.getInt('prayer_school') ?? 0;
      final midnightMode = prefs.containsKey('midnight_mode')
          ? prefs.getInt('midnight_mode')
          : null;
      final latAdj = prefs.containsKey('latitude_adj')
          ? prefs.getInt('latitude_adj')
          : null;

      _ramadanDays = await _ramadanService.fetchRamadanCalendar(
        adj: calendarMethod == 'MATHEMATICAL' ? adj : 0,
        calendarMethod: calendarMethod,
        method: method,
        school: school,
        midnightMode: midnightMode,
        latitudeAdjustmentMethod: latAdj,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
