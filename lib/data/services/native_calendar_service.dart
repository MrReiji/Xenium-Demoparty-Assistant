// ignore_for_file: deprecated_member_use

import 'package:android_intent_plus/android_intent.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Service to add events to the native calendar on Android and iOS.
class NativeCalendarService {

  /// Adds an event to the calendar using platform-specific methods.
  ///
  /// Parameters:
  /// - [title]: Event title, e.g., "Breakfast", "Team Meeting".
  /// - [start]: Start date and time of the event.
  /// - [end]: End date and time of the event.
  /// - [description]: Event notes, e.g., "Seminar, Concert, Competition".
  /// - [location]: Event location (optional).
  /// - [allDay]: True for all-day events, defaults to `false`.
  Future<void> addEventToNativeCalendar({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    String? location,
    bool allDay = false,
  }) async {
    try {
      if (Platform.isAndroid) {
        // Android: Use intent to insert an event into the calendar.
        final intent = AndroidIntent(
          action: 'android.intent.action.INSERT',
          data: 'content://com.android.calendar/events',
          type: "vnd.android.cursor.dir/event",
          arguments: {
            'title': title,
            'allDay': allDay,
            'beginTime': start.millisecondsSinceEpoch,
            'endTime': end.millisecondsSinceEpoch,
            'description': description,
            'eventLocation': location,
            'hasAlarm': 1,
          },
        );
        await intent.launchChooser("Choose an app to save the event");
      } else if (Platform.isIOS) {
        // iOS: Use URL schemes to open the calendar app.
        final url =
            'calshow://?title=${Uri.encodeComponent(title)}&notes=${Uri.encodeComponent(description ?? '')}'
            '&location=${Uri.encodeComponent(location ?? '')}'
            '&start=${Uri.encodeComponent(start.toIso8601String())}&end=${Uri.encodeComponent(end.toIso8601String())}';

        if (await canLaunch(url)) {
          await launch(url);
        } else {
          final error = 'Could not launch iOS calendar URL.';
          ErrorHelper.handleError(Exception(error));
          throw Exception(error);
        }
      } else {
        // Unsupported platforms: log and handle the error using ErrorHelper.
        final error = 'This platform is not supported for adding calendar events.';
        ErrorHelper.handleError(Exception(error));
        throw Exception(error);
      }
    } catch (e) {
      // Use ErrorHelper to handle and display error messages.
      ErrorHelper.handleError(e);
      final errorMessage = ErrorHelper.getErrorMessage(e);
      debugPrint('Error adding event: $errorMessage');
    }
  }

}
