// lib/core/utils/notification_helper.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification channel IDs
  static const String _deadlineChannelId = 'deadline_reminders';
  static const String _alarmChannelId = 'deadline_alarms';
  static const String _jarvisChannelId = 'jarvis_voice_channel';
  static const String _briefingChannelId = 'daily_briefing';

  // Unique ID offsets to avoid collisions
  static const int _offsetDaysBefore = 10000;
  static const int _offsetHoursBefore = 20000;
  static const int _offsetSameDay = 30000;
  static const int _offsetOverdue = 40000;

  static Future<void> initialize() async {
    // Initialize Timezone
    tz.initializeTimeZones();
    final dynamic location = await FlutterTimezone.getLocalTimezone();
    String timeZoneName = location.toString();

    if (timeZoneName.contains('(')) {
      final match = RegExp(r'\(([^,)]+)').firstMatch(timeZoneName);
      if (match != null) {
        timeZoneName = match.group(1)!.trim();
      }
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Warning: Could not set timezone $timeZoneName, falling back to UTC');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (e) {
        // Ultimate fallback
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Request permissions for Android 13+ (API 33)
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();

        // Jarvis Voice Service channel
        const jarvisChannel = AndroidNotificationChannel(
          _jarvisChannelId,
          'Jarvis Voice Service',
          description: 'Used for Jarvis background voice assistant',
          importance: Importance.max,
        );
        await androidPlugin.createNotificationChannel(jarvisChannel);

        // Deadline reminders (normal)
        const deadlineChannel = AndroidNotificationChannel(
          _deadlineChannelId,
          'Deadline Reminders',
          description: 'Notifications for upcoming task deadlines',
          importance: Importance.high,
        );
        await androidPlugin.createNotificationChannel(deadlineChannel);

        // Alarm channel (urgent — plays alarm sound, full-screen intent)
        const alarmChannel = AndroidNotificationChannel(
          _alarmChannelId,
          'Deadline Alarms',
          description: 'Urgent alarms for tasks about to be overdue',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );
        await androidPlugin.createNotificationChannel(alarmChannel);

        // Daily briefing channel
        const briefingChannel = AndroidNotificationChannel(
          _briefingChannelId,
          'Daily Briefing',
          description: 'Morning task summary from Jarvis',
          importance: Importance.defaultImportance,
        );
        await androidPlugin.createNotificationChannel(briefingChannel);
      }
    }
  }

  /// Schedule comprehensive reminders for a task deadline.
  /// Includes: D-3, D-2, D-1 (at 9AM), same-day (2h, 1h, 30min before),
  /// and an alarm-style notification 15min before.
  static Future<void> scheduleDeadlineReminders({
    required int taskId,
    required String title,
    required DateTime deadline,
  }) async {
    // Cancel existing ones first
    await cancelTaskReminders(taskId);

    final now = tz.TZDateTime.now(tz.local);

    // ── D-7, D-3, D-2, D-1 reminders at 9:00 AM ──
    final daysBefore = [1, 2, 3, 7];
    for (int d in daysBefore) {
      final scheduleDate = deadline.subtract(Duration(days: d));
      final scheduledTime = tz.TZDateTime(
        tz.local,
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
        9,
        0,
      );

      if (scheduledTime.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          id: taskId + (d * _offsetDaysBefore),
          title: '📋 Reminder: H-$d',
          body: 'Tugas "$title" akan berakhir dalam $d hari! Jangan lupa diselesaikan.',
          scheduledDate: scheduledTime,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _deadlineChannelId,
              'Deadline Reminders',
              channelDescription: 'Notifications for upcoming task deadlines',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'task:$taskId',
        );
      }
    }

    // ── Same-day reminders: 2h, 1h before ──
    final hoursBefore = [2, 1];
    for (int h in hoursBefore) {
      final scheduledTime = tz.TZDateTime.from(
        deadline.subtract(Duration(hours: h)),
        tz.local,
      );

      if (scheduledTime.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          id: taskId + (h * _offsetHoursBefore),
          title: '⏰ ${h}h left: $title',
          body: 'Your task "$title" is due in $h hour(s). Time to wrap up!',
          scheduledDate: scheduledTime,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _deadlineChannelId,
              'Deadline Reminders',
              channelDescription: 'Notifications for upcoming task deadlines',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'task:$taskId',
        );
      }
    }

    // ── 30 minutes before: same-day warning ──
    final thirtyMinBefore = tz.TZDateTime.from(
      deadline.subtract(const Duration(minutes: 30)),
      tz.local,
    );
    if (thirtyMinBefore.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        id: taskId + _offsetSameDay,
        title: '⚠️ 30 menit lagi: $title',
        body: 'Task "$title" akan jatuh tempo dalam 30 menit!',
        scheduledDate: thirtyMinBefore,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _deadlineChannelId,
            'Deadline Reminders',
            channelDescription: 'Notifications for upcoming task deadlines',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/launcher_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'task:$taskId',
      );
    }

    // ── 15 minutes before: ALARM (urgent) ──
    final fifteenMinBefore = tz.TZDateTime.from(
      deadline.subtract(const Duration(minutes: 15)),
      tz.local,
    );
    if (fifteenMinBefore.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        id: taskId + _offsetSameDay + 1,
        title: '🚨 ALARM: $title',
        body: 'DEADLINE dalam 15 menit! Segera selesaikan task "$title"!',
        scheduledDate: fifteenMinBefore,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _alarmChannelId,
            'Deadline Alarms',
            channelDescription: 'Urgent alarms for tasks about to be overdue',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            icon: '@mipmap/launcher_icon',
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: 'alarm:$taskId',
      );
    }

    // ── At deadline time: overdue alarm ──
    final atDeadline = tz.TZDateTime.from(deadline, tz.local);
    if (atDeadline.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        id: taskId + _offsetOverdue,
        title: '🔴 OVERDUE: $title',
        body: 'Task "$title" sudah melewati deadline! Segera selesaikan.',
        scheduledDate: atDeadline,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _alarmChannelId,
            'Deadline Alarms',
            channelDescription: 'Urgent alarms for tasks about to be overdue',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            icon: '@mipmap/launcher_icon',
            playSound: true,
            enableVibration: true,
            ongoing: true,
            autoCancel: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: 'overdue:$taskId',
      );
    }
  }

  /// Show an instant notification (for AI/Jarvis actions).
  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _deadlineChannelId,
          'Deadline Reminders',
          channelDescription: 'Notifications for upcoming task deadlines',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      payload: payload,
    );
  }

  /// Cancel all reminders and alarms for a task.
  static Future<void> cancelTaskReminders(int taskId) async {
    // D-1, D-2, D-3, D-7
    for (int d in [1, 2, 3, 7]) {
      await _notificationsPlugin.cancel(id: taskId + (d * _offsetDaysBefore));
    }
    // 2h, 1h before
    for (int h in [1, 2]) {
      await _notificationsPlugin.cancel(id: taskId + (h * _offsetHoursBefore));
    }
    // 30min, 15min before
    await _notificationsPlugin.cancel(id: taskId + _offsetSameDay);
    await _notificationsPlugin.cancel(id: taskId + _offsetSameDay + 1);
    // Overdue
    await _notificationsPlugin.cancel(id: taskId + _offsetOverdue);
  }

  /// Cancel all notifications.
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
