import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qibla_direction/models/ramadan_day.dart';

class RamadanService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/hToGCalendar';

  Future<List<RamadanDay>> fetchRamadanCalendar(String hijriYear) async {
    final url = Uri.parse('$_baseUrl/9/$hijriYear');

    try {
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
}
