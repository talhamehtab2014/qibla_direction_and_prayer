import 'package:flutter/material.dart';
import 'package:qibla_direction/services/remote_config_service.dart';

class RemoteConfigProvider with ChangeNotifier {
  final RemoteConfigService _service;

  RemoteConfigProvider({RemoteConfigService? service})
    : _service = service ?? RemoteConfigService();

  bool get showRamadanCalendar => _service.showRamadanCalendar;
  bool get showPrayersTime => _service.showPrayersTime;
  bool get showDailyAdhkar => _service.showDailyAdhkar;
  bool get isShowAds => _service.isShowAds;
  bool get showRamadanTiming => _service.showRamadanTiming;

  Future<void> initialize() async {
    await _service.initialize();

    // Listen for real-time updates
    _service.onConfigUpdated.listen((_) {
      notifyListeners();
    });

    notifyListeners();
  }
}
