import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const String _showRamadanCalendarKey = 'isRamadanMonth';
  static const String _showPrayersTimeKey = 'showPrayersTime';
  static const String _showDailyAdhkarKey = 'showDailyAdhkar';
  static const String _isShowAdsKey = 'isShowAds';
  static const String _showRamadanTimingKey = 'showRamadanTiming';

  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('RemoteConfig: Initializing...');
      }

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 0)
              : const Duration(seconds: 5),
        ),
      );

      await _remoteConfig.setDefaults({
        _showRamadanCalendarKey: true,
        _showPrayersTimeKey: true,
        _showDailyAdhkarKey: true,
        _isShowAdsKey: true,
        _showRamadanTimingKey: true,
      });

      if (kDebugMode) {
        print(
          'RemoteConfig: Defaults set. Value before fetch: ${_remoteConfig.getBool(_showRamadanCalendarKey)}',
        );
      }

      await _fetchAndActivate();

      if (kDebugMode) {
        print('RemoteConfig: Fetch complete.');
        print(
          'RemoteConfig: Last fetch status: ${_remoteConfig.lastFetchStatus}',
        );
        print('RemoteConfig: Last fetch time: ${_remoteConfig.lastFetchTime}');
        print(
          'RemoteConfig: Value for $_showRamadanCalendarKey: ${_remoteConfig.getBool(_showRamadanCalendarKey)}',
        );
        print(
          'RemoteConfig: All keys: ${_remoteConfig.getAll().keys.toList()}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config initialization failed: $e');
      }
    }
  }

  Future<void> _fetchAndActivate() async {
    try {
      bool updated = await _remoteConfig.fetchAndActivate();
      if (kDebugMode) {
        print('RemoteConfig: fetchAndActivate returned $updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config fetch failed: $e');
      }
    }
  }

  bool get showRamadanCalendar {
    final value = _remoteConfig.getBool(_showRamadanCalendarKey);
    if (kDebugMode) {
      print('RemoteConfig: Getting $value for key $_showRamadanCalendarKey');
    }
    return value;
  }

  bool get showPrayersTime {
    final value = _remoteConfig.getBool(_showPrayersTimeKey);
    if (kDebugMode) {
      print('RemoteConfig: Getting $value for key $_showPrayersTimeKey');
    }
    return value;
  }

  bool get showDailyAdhkar {
    final value = _remoteConfig.getBool(_showDailyAdhkarKey);
    if (kDebugMode) {
      print('RemoteConfig: Getting $value for key $_showDailyAdhkarKey');
    }
    return value;
  }

  bool get isShowAds {
    final value = _remoteConfig.getBool(_isShowAdsKey);
    if (kDebugMode) {
      print('RemoteConfig: Getting $value for key $_isShowAdsKey');
    }
    return value;
  }

  bool get showRamadanTiming {
    final value = _remoteConfig.getBool(_showRamadanTimingKey);
    if (kDebugMode) {
      print('RemoteConfig: Getting $value for key $_showRamadanTimingKey');
    }
    return value;
  }
}
