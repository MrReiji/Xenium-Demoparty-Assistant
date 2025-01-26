import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

/// Service for interacting with the native Android calendar.
class NativeCalendarService {
  /// Adds an event to the native calendar using Android intents.
  Future<void> addEventToNativeCalendar({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    String? location,
    bool allDay = false,
  }) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.INSERT',
        data: 'content://com.android.calendar/events',
        type: "vnd.android.cursor.dir/event",
        arguments: <String, dynamic>{
          'title': title,
          'allDay': allDay,
          'beginTime': start.millisecondsSinceEpoch,
          'endTime': end.millisecondsSinceEpoch,
          'description': description ?? '',
          'eventLocation': location ?? '',
          'hasAlarm': 1,
        },
      );

      await intent.launchChooser("Choose an app to save the event");
    } catch (e) {
      debugPrint('Error while adding event to native calendar: $e');
    }
  }
}
