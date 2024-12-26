import 'package:demoparty_assistant/data/manager/time_table/time_table_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
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

/// Schedules a notification for an event.
///
/// This method calculates the notification time based on user preferences
/// and schedules a local notification for the event.
Future<void> scheduleEventNotification(
  String title,
  DateTime eventDateTime, {
  String? payload,
}) async {
  // Retrieve the user's reminder time setting (in minutes).
  final reminderTimeInMinutes = await _settingsManager.getReminderTimeInMinutes();

  // Convert the event's DateTime to the local timezone.
  final tz.TZDateTime eventTZDateTime = tz.TZDateTime.from(eventDateTime.toUtc(), tz.local);

  // Calculate the time to display the notification by subtracting the reminder time.
  final tz.TZDateTime scheduledDate = eventTZDateTime.subtract(Duration(minutes: reminderTimeInMinutes));

  // Only schedule the notification if the calculated time is in the future.
  if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
    try {
      // Schedule the notification using the local notifications plugin.
      await _notificationsPlugin.zonedSchedule(
        eventDateTime.hashCode, // Unique ID for the notification.
        title, // Title of the notification.
        'Your event "$title" starts soon!', // Body text of the notification.
        scheduledDate, // Time to display the notification.
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId, // Notification channel ID.
            _channelName, // Notification channel name.
            channelDescription: _channelDescription, // Channel description.
            importance: Importance.max, // High-priority notification.
            priority: Priority.high,
            playSound: true,
            icon: 'notification_logo', // Custom notification icon.
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true, // Display an alert for the notification.
            presentSound: true, // Play a sound when the notification is delivered.
            presentBadge: true, // Update the app badge count.
            sound: 'default', // Use the default system sound.
            badgeNumber: 1, // Increment the app's badge count by 1.
            subtitle: 'Upcoming Event', // Add a subtitle to the notification.
            threadIdentifier: 'event_notifications', // Group notifications in the same thread.
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload, // Optional data to include with the notification.
      );
    } catch (e, stackTrace) {
      // Handle any errors during notification scheduling.
      // Throw an exception with the error and stack trace for better debugging.
      throw Exception('Error scheduling notification for "$title": $e\nStack trace: $stackTrace');
    }
    } else {
    // Throw an exception if the event is in the past and no notification is scheduled.
    throw Exception('Event "$title" is in the past; no notification scheduled.');
    }
}


  /// Cancels all scheduled notifications.
  ///
  /// This method cancels all notifications that have been scheduled
  /// using the local notifications plugin.
  Future<void> cancelAllNotifications() async {
    // Cancel all notifications.
    await _notificationsPlugin.cancelAll();
  }

  /// Reschedules all notifications for upcoming events.
  ///
  /// This method retrieves all events from the timetable repository,
  /// parses their date and time, and schedules notifications for them
  /// if they are in the future.
  Future<void> rescheduleAllNotifications() async {
    try {
      // Retrieve the timetable repository instance.
      final timetableRepository = GetIt.I<TimeTableManager>();
      
      // Get the list of events from the repository.
      final events = timetableRepository.eventsData;

      // Iterate through each day's events.
      for (final day in events) {
        final date = day['date'] as String;
        final eventsList = day['events'] as List<dynamic>;

        // Iterate through each event in the day's events list.
        for (final event in eventsList) {
          final eventMap = Map<String, dynamic>.from(event as Map);
          final time = eventMap['time'] as String;
          
          // Parse the event's date and time to a DateTime object.
          final eventDateTime = timetableRepository.parseDateTime(date, time);

          // Schedule a notification if the event is in the future.
          if (eventDateTime != null && eventDateTime.isAfter(DateTime.now())) {
            await scheduleEventNotification(
              eventMap['description'], // Event description.
              eventDateTime, // Event date and time.
              payload: eventMap['type'], // Event type.
            );
          }
        }
      }
    } catch (e) {
      // Log any errors that occur during the rescheduling process.
      debugPrint('[NotificationService] Error re-scheduling notifications: $e');
    }
  }
}

