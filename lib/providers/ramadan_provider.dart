import 'package:flutter/foundation.dart';
import 'package:qibla_direction/models/ramadan_day.dart';
import 'package:qibla_direction/services/ramadan_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RamadanProvider extends ChangeNotifier {
  final RamadanService _ramadanService = RamadanService();

  List<RamadanDay> _ramadanDays = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RamadanDay> get ramadanDays => _ramadanDays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRamadanCalendar({String? hijriYear}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String year = hijriYear ?? await _getCurrentHijriYear();
      _ramadanDays = await _ramadanService.fetchRamadanCalendar(year);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<String> _getCurrentHijriYear() async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.day}-${now.month}-${now.year}';
      final response = await http.get(
        Uri.parse('https://api.aladhan.com/v1/gToH/$dateStr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['hijri']['year'].toString();
      }
    } catch (e) {
      debugPrint('Error fetching Hijri year: $e');
    }
    return '1447'; // Fallback to provided example year
  }
}
