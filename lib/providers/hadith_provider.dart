import 'package:flutter/foundation.dart';
import 'package:qibla_direction/models/hadith.dart';
import 'package:qibla_direction/services/hadith_service.dart';

class HadithProvider extends ChangeNotifier {
  final HadithService _hadithService = HadithService();

  Hadith? _currentHadith;
  bool _isLoading = false;

  Hadith? get currentHadith => _currentHadith;
  bool get isLoading => _isLoading;

  Future<void> fetchNewHadith() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentHadith = await _hadithService.fetchRandomHadith();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
