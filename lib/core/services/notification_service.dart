import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// Training-triggered local notification service.
///
/// After a user completes training, schedules reminders for the next 2 days
/// (tomorrow 8 PM + day-after-tomorrow 8 PM) to encourage streak continuity.
/// If the user trains again, old notifications are cancelled and fresh ones
/// are scheduled.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _prefKey = 'notification_enabled';
  static const _lastTrainedKey = 'last_trained_date';
  static const _notifIdDay1 = 100;
  static const _notifIdDay2 = 101;
  static const _channelId = 'soarq_training_reminder';
  static const _channelName = 'Training Reminder';

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

  /// Check if notification is currently enabled.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Enable or disable the notification feature.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);

    if (enabled) {
      await requestPermission();
    } else {
      await cancelAll();
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancel(id: _notifIdDay1);
    await _plugin.cancel(id: _notifIdDay2);
  }

  /// Call this when the user completes a training session.
  /// If notifications are enabled, schedules reminders for
  /// tomorrow 8 PM and day-after-tomorrow 8 PM.
  Future<void> onTrainingCompleted() async {
    if (!await isEnabled()) return;

    // Save last trained date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTrainedKey, DateTime.now().toIso8601String());

    // Cancel any existing reminders, then schedule fresh ones
    await cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    final tomorrow8pm = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20)
        .add(const Duration(days: 1));
    final dayAfter8pm = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20)
        .add(const Duration(days: 2));

    // Day 1: Tomorrow
    await _scheduleNotification(
      id: _notifIdDay1,
      scheduledDate: tomorrow8pm,
      body: _getDay1Message(),
    );

    // Day 2: Day after tomorrow
    await _scheduleNotification(
      id: _notifIdDay2,
      scheduledDate: dayAfter8pm,
      body: _getDay2Message(),
    );

    debugPrint('[Notification] Scheduled: tomorrow + day-after at 20:00');
  }

  /// Re-schedule pending notifications on app restart (if still valid).
  Future<void> rescheduleIfNeeded() async {
    if (!await isEnabled()) return;

    final prefs = await SharedPreferences.getInstance();
    final lastTrained = prefs.getString(_lastTrainedKey);
    if (lastTrained == null) return;

    final trainedDate = DateTime.parse(lastTrained);
    final now = DateTime.now();
    final daysSince = now.difference(trainedDate).inDays;

    // Only reschedule if within the 2-day window
    if (daysSince >= 2) return;

    final tomorrow8pm = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20)
        .add(Duration(days: daysSince == 0 ? 1 : 1));
    final dayAfter8pm = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20)
        .add(Duration(days: daysSince == 0 ? 2 : 2));

    await cancelAll();

    if (daysSince == 0) {
      // Trained today → schedule both
      if (tomorrow8pm.isAfter(tz.TZDateTime.now(tz.local))) {
        await _scheduleNotification(
          id: _notifIdDay1,
          scheduledDate: tomorrow8pm,
          body: _getDay1Message(),
        );
      }
      if (dayAfter8pm.isAfter(tz.TZDateTime.now(tz.local))) {
        await _scheduleNotification(
          id: _notifIdDay2,
          scheduledDate: dayAfter8pm,
          body: _getDay2Message(),
        );
      }
    } else if (daysSince == 1) {
      // Trained yesterday → only day-after remains
      final today8pm = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
      if (today8pm.isAfter(tz.TZDateTime.now(tz.local))) {
        await _scheduleNotification(
          id: _notifIdDay1,
          scheduledDate: today8pm,
          body: _getDay2Message(),
        );
      }
      final tomorrowFor2 =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 20)
              .add(const Duration(days: 1));
      if (tomorrowFor2.isAfter(tz.TZDateTime.now(tz.local))) {
        await _scheduleNotification(
          id: _notifIdDay2,
          scheduledDate: tomorrowFor2,
          body: _getDay2Message(),
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required tz.TZDateTime scheduledDate,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Reminder after training to keep the streak going',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'SoarQ 🚀',
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Day 1 message — encourage continuing the streak.
  String _getDay1Message() {
    final messages = [
      '어제 훈련 잘했어요! 오늘도 한 문제 도전? 🔥',
      '연속 훈련 중! 오늘도 이어가볼까요? 💪',
      '어제의 노력이 쌓이고 있어요. 오늘도 GO! 🚀',
    ];
    return messages[DateTime.now().microsecond % messages.length];
  }

  /// Day 2 message — gentle nudge without saying "last".
  String _getDay2Message() {
    final messages = [
      '오늘도 CS 한 문제 풀어볼까요? 🧠',
      '잠깐이면 돼요, 한 문제만! ⚡',
      '실력은 꾸준함에서 나와요 📈',
    ];
    return messages[DateTime.now().microsecond % messages.length];
  }
}
