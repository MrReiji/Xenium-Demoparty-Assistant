import 'package:demoparty_assistant/data/manager/time_table/time_table_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get_it/get_it.dart';
import '../manager/settings/settings_manager.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final SettingsManager _settingsManager = SettingsManager();

  static const String _channelId = 'event_channel';
  static const String _channelName = 'Event Notifications';
  static const String _channelDescription = 'This channel is used for event notifications';

  Future<void> initialize() async {
    debugPrint('[NotificationService] Initializing...');
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('notification_logo'),
      iOS: DarwinInitializationSettings(),
    );
    await _notificationsPlugin.initialize(initializationSettings);
    debugPrint('[NotificationService] Plugin initialized.');

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    debugPrint('[NotificationService] Notification channel created.');
  }

  Future<void> scheduleEventNotification(
    String title,
    DateTime eventDateTime, {
    String? payload,
  }) async {
    final reminderTimeInMinutes = await _settingsManager.getReminderTimeInMinutes();
    final tz.TZDateTime eventTZDateTime = tz.TZDateTime.from(eventDateTime.toUtc(), tz.local);
    final tz.TZDateTime scheduledDate = eventTZDateTime.subtract(Duration(minutes: reminderTimeInMinutes));

    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      try {
        await _notificationsPlugin.zonedSchedule(
          eventDateTime.hashCode,
          title,
          'Your event "$title" starts soon!',
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              icon: 'notification_logo',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        debugPrint('[NotificationService] Notification scheduled for "$title" at $scheduledDate.');
      } catch (e) {
        debugPrint('[NotificationService] Error scheduling notification for "$title": $e');
      }
    } else {
      debugPrint('[NotificationService] Event "$title" is in the past; no notification scheduled.');
    }
  }

  Future<void> cancelAllNotifications() async {
    debugPrint('[NotificationService] Canceling all notifications...');
    await _notificationsPlugin.cancelAll();
    debugPrint('[NotificationService] All notifications have been canceled.');
  }

  Future<void> rescheduleAllNotifications() async {
    debugPrint('[NotificationService] Re-scheduling all notifications...');
    try {
      final timetableRepository = GetIt.I<TimeTableManager>();
      final events = timetableRepository.eventsData;

      for (final day in events) {
        final date = day['date'] as String;
        final eventsList = day['events'] as List<dynamic>;

        for (final event in eventsList) {
          final eventMap = Map<String, dynamic>.from(event as Map);
          final time = eventMap['time'] as String;
          final eventDateTime = timetableRepository.parseDateTimeFromCache(date, time);

          if (eventDateTime != null && eventDateTime.isAfter(DateTime.now())) {
            await scheduleEventNotification(
              eventMap['description'] ?? 'Event',
              eventDateTime,
              payload: eventMap['type'] ?? 'General',
            );
          }
        }
      }
      debugPrint('[NotificationService] All notifications re-scheduled successfully.');
    } catch (e) {
      debugPrint('[NotificationService] Error re-scheduling notifications: $e');
    }
  }
}
