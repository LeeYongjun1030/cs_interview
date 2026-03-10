import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local notification service for daily training reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _prefKey = 'daily_notification_enabled';
  static const _dailyNotifId = 0;
  static const _channelId = 'soarq_daily_reminder';
  static const _channelName = 'Daily Training Reminder';

  /// Initialize the notification plugin. Call once at app startup.
  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
  }

  /// Request notification permission (iOS 10+, Android 13+).
  Future<bool> requestPermission() async {
    // iOS
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Android 13+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// Check if daily notification is currently enabled.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Enable or disable the daily notification.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);

    if (enabled) {
      final granted = await requestPermission();
      if (granted) {
        await _scheduleDailyNotification();
      }
    } else {
      await _plugin.cancel(id: _dailyNotifId);
    }
  }

  /// Schedule a daily notification at 9:00 AM local time.
  Future<void> _scheduleDailyNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);

    // If 9 AM already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily reminder to practice CS interview training',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: _dailyNotifId,
      title: 'SoarQ 🚀',
      body: _getRandomMessage(),
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('[Notification] Daily notification scheduled at 09:00');
  }

  /// Re-schedule if already enabled (call on app restart).
  Future<void> rescheduleIfEnabled() async {
    if (await isEnabled()) {
      await _scheduleDailyNotification();
    }
  }

  /// Randomly pick a motivational message.
  String _getRandomMessage() {
    final messages = [
      '오늘의 CS 훈련을 완료해보세요! 💪',
      '면접 준비, 꾸준함이 실력입니다 🔥',
      '오늘도 한 문제 풀어볼까요? 🧠',
      '질문을 쏘면 실력이 올라갑니다 🚀',
      '매일 조금씩, 면접 마스터가 되는 길 📈',
    ];
    return messages[DateTime.now().microsecond % messages.length];
  }
}
