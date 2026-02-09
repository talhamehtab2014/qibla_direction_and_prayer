import 'package:flutter/foundation.dart';
import 'package:qibla_direction/models/adhkar.dart';
import 'package:qibla_direction/services/adhkar_service.dart';

class AdhkarProvider extends ChangeNotifier {
  final AdhkarService _adhkarService = AdhkarService();

  List<Adhkar> _morningAdhkar = [];
  List<Adhkar> _eveningAdhkar = [];
  bool _isLoading = false;

  List<Adhkar> get morningAdhkar => _morningAdhkar;
  List<Adhkar> get eveningAdhkar => _eveningAdhkar;
  bool get isLoading => _isLoading;

  void loadAdhkar() {
    _isLoading = true;
    notifyListeners();

    _morningAdhkar = _adhkarService.getMorningAdhkar();
    _eveningAdhkar = _adhkarService.getEveningAdhkar();

    _isLoading = false;
    notifyListeners();
  }
}
