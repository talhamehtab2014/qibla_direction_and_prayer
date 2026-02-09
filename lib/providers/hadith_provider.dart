import 'package:flutter/foundation.dart';
import 'package:qibla_direction/models/hadith.dart';
import 'package:qibla_direction/services/hadith_service.dart';

class HadithProvider extends ChangeNotifier {
  final HadithService _hadithService = HadithService();

  List<Hadith> _hadiths = [];
  bool _isLoading = false;

  List<Hadith> get hadiths => _hadiths;
  bool get isLoading => _isLoading;

  Future<void> fetchHadiths() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hadiths = await _hadithService.fetchAllHadiths();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
