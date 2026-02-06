import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times.dart';

class PrayerService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/timings';

  Future<PrayerTimes> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 4,
    int school = 0,
    int? midnightMode,
    int? latitudeAdjustmentMethod,
    DateTime? date,
  }) async {
    final dateStr = date != null
        ? '${date.day}-${date.month}-${date.year}'
        : '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';

    final url = Uri.parse(
      '$_baseUrl/$dateStr?latitude=$latitude&longitude=$longitude&method=$method&school=$school'
      '${midnightMode != null ? '&midnightMode=$midnightMode' : ''}'
      '${latitudeAdjustmentMethod != null ? '&latitudeAdjustmentMethod=$latitudeAdjustmentMethod' : ''}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimes.fromJson(data);
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }
}
