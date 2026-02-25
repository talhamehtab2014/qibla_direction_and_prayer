import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Timezone
    tz.initializeTimeZones();
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    // Initialize Local Notifications Setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
      },
    );

    // Request permissions for iOS and Android 13+
    await _requestPermissions();

    // Firebase Messaging Setup
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title,
          message.notification!.body,
        );
      }
    });

    // Optionally get fcm token for targeted sending
    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    // For iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // For Android 13+ local notifications
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> _showLocalNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'iman360_channel_id',
          'Iman360 Notifications',
          channelDescription: 'Notifications for Iman360 app',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: 'foreground_fcm',
    );
  }

  /// Schedule notifications for Iftar and Sehri
  Future<void> scheduleRamadanNotifications({
    required DateTime todayIftarTime,
    required DateTime
    tomorrowSehriTime, // Pass today's Sehri if still before sehri time
  }) async {
    try {
      // Cancel previous scheduled ramadan notifications to avoid duplicates
      await _localNotificationsPlugin.cancel(id: 1); // 1 = Iftar ID
      await _localNotificationsPlugin.cancel(id: 2); // 2 = Sehri ID

      final now = DateTime.now();

      // Schedule Iftar notification (1 hour before)
      final iftarNotificationTime = todayIftarTime.subtract(
        const Duration(hours: 1),
      );
      if (iftarNotificationTime.isAfter(now)) {
        await _scheduleNotification(
          id: 1,
          title: 'Iftar Reminder',
          body: 'Iftar time is in 1 hour. Get ready to break your fast!',
          scheduledDate: iftarNotificationTime,
        );
        debugPrint('Scheduled Iftar notification at $iftarNotificationTime');
      }

      // Schedule Sehri notification (1 hour before)
      final sehriNotificationTime = tomorrowSehriTime.subtract(
        const Duration(hours: 1),
      );
      if (sehriNotificationTime.isAfter(now)) {
        await _scheduleNotification(
          id: 2,
          title: 'Sehri Reminder',
          body: 'Sehri time is in 1 hour. Wake up and start your fast!',
          scheduledDate: sehriNotificationTime,
        );
        debugPrint('Scheduled Sehri notification at $sehriNotificationTime');
      }
    } catch (e) {
      debugPrint('Error scheduling Ramadan notifications: $e');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _localNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ramadan_timing_channel_id',
          'Ramadan Reminders',
          channelDescription: 'Notifications for Iftar and Sehri times',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
