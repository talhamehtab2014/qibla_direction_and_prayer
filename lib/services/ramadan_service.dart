import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:qibla_direction/models/prayer_times.dart';
import 'package:qibla_direction/models/ramadan_day.dart';
import 'package:qibla_direction/services/location_service.dart';

class RamadanService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/hijriCalendar';
  final LocationService _locationService = LocationService();

  Future<List<RamadanDay>> fetchRamadanCalendar({
    String? hijriYear,
    int? month,
    int adj = 0,
    String calendarMethod = 'HJCoSA',
    int method = 4,
    int school = 0,
    int? midnightMode,
    int? latitudeAdjustmentMethod,
  }) async {
    try {
      if (hijriYear == null || month == null) {
        final todayHijri = HijriCalendar.now();
        hijriYear ??= todayHijri.hYear.toString();
        month ??= todayHijri.hMonth;
      }
      double lat = 21.4225; // Fallback to Makkah
      double lng = 39.8262;
      try {
        final location = await _locationService.getLocationData();
        lat = location.latitude;
        lng = location.longitude;
      } catch (_) {}

      final url = Uri.parse(
        '$_baseUrl/$hijriYear/$month'
        '?latitude=$lat&longitude=$lng'
        '&method=$method&school=$school'
        '${midnightMode != null ? '&midnightMode=$midnightMode' : ''}'
        '${latitudeAdjustmentMethod != null ? '&latitudeAdjustmentMethod=$latitudeAdjustmentMethod' : ''}'
        '&calendarMethod=$calendarMethod'
        '${calendarMethod == 'MATHEMATICAL' && adj != 0 ? '&adjustment=$adj' : ''}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> daysList = data['data'];
        return daysList.map((day) => RamadanDay.fromJson(day)).toList();
      } else {
        throw Exception(
          'Failed to load Ramadan calendar: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching Ramadan calendar: $e');
    }
  }

  /// Fetches the full month calendar and extracts today's prayer timings.
  /// Uses [PrayerTimes.fromCalendarDayJson] to parse the result.
  Future<PrayerTimes> fetchTodayTimings({
    int adj = 0,
    String calendarMethod = 'HJCoSA',
    int method = 4,
    int school = 0,
    int? midnightMode,
    int? latitudeAdjustmentMethod,
  }) async {
    try {
      final todayHijri = HijriCalendar.now();
      final hijriYear = todayHijri.hYear.toString();
      final month = todayHijri.hMonth;

      double lat = 21.4225;
      double lng = 39.8262;
      try {
        final location = await _locationService.getLocationData();
        lat = location.latitude;
        lng = location.longitude;
      } catch (_) {}

      final url = Uri.parse(
        '$_baseUrl/$hijriYear/$month'
        '?latitude=$lat&longitude=$lng'
        '&method=$method&school=$school'
        '${midnightMode != null ? '&midnightMode=$midnightMode' : ''}'
        '${latitudeAdjustmentMethod != null ? '&latitudeAdjustmentMethod=$latitudeAdjustmentMethod' : ''}'
        '&calendarMethod=$calendarMethod'
        '${calendarMethod == 'MATHEMATICAL' && adj != 0 ? '&adjustment=$adj' : ''}',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to load calendar: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> daysList = data['data'];

      // Match today's Gregorian date — the API returns dates like "25-02-2026"
      final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final todayEntry = daysList.firstWhere(
        (d) => d['date']['gregorian']['date'] == todayStr,
        orElse: () => daysList.first,
      );

      return PrayerTimes.fromCalendarDayJson(todayEntry);
    } catch (e) {
      throw Exception('Error fetching today\'s timings: $e');
    }
  }
}
