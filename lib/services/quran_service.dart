import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_models.dart';

class QuranService {
  static const String _quranUrl = 'https://api.alquran.cloud/v1/quran/ar.alafasy';
  static const String _cacheKey = 'cached_quran_alafasy';

  // Fetch the full Quran (with audio links) from API or Cache
  Future<List<Surah>> fetchFullQuran() async {
    final prefs = await SharedPreferences.getInstance();

    // Check Cache First
    if (prefs.containsKey(_cacheKey)) {
      final String? cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final Map<String, dynamic> decodedData = json.decode(cachedData);
        final List<dynamic> surahsJson = decodedData['surahs'];
        return surahsJson.map((i) => Surah.fromJson(i)).toList();
      }
    }

    // If not in cache, fetch from API (Note: This is ~5MB)
    try {
      final response = await http
          .get(Uri.parse(_quranUrl))
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> dataJson = responseData['data'];

        // Save to cache
        await prefs.setString(_cacheKey, json.encode(dataJson));

        final List<dynamic> surahsJson = dataJson['surahs'];
        return surahsJson.map((i) => Surah.fromJson(i)).toList();
      } else {
        throw Exception('Failed to load full Quran');
      }
    } catch (e) {
      throw Exception('Error fetching Quran: $e');
    }
  }

  // Fetch specific Surah by number (Now retrieved from the bulk fetch)
  Future<Surah> fetchSurah(int surahNumber) async {
    try {
      final fullQuran = await fetchFullQuran();
      return fullQuran.firstWhere((s) => s.number == surahNumber);
    } catch (e) {
      throw Exception('Error retrieving Surah $surahNumber: $e');
    }
  }

  // Check if a Surah is downloaded securely by examining the cache
  Future<bool> isSurahDownloaded(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    // Because we fetch the full Quran in one ~5MB payload now,
    // if the cache key exists, ALL surahs are downloaded.
    return prefs.containsKey(_cacheKey);
  }

  // Save the Last Read Surah and Ayah
  Future<void> saveLastRead(int surahNumber, String surahName, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_data', json.encode({
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
    }));
  }

  // Get the Last Read Surah and Ayah
  Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('last_read_data');
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasSeenSurahTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_surah_tutorial') ?? false;
  }

  Future<void> setHasSeenSurahTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_surah_tutorial', true);
  }
}
