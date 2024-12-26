import 'dart:convert';
import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/data/services/native_calendar_service.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:demoparty_assistant/data/services/notification_service.dart';
import 'package:demoparty_assistant/utils/functions/getColorForType.dart';
import 'package:demoparty_assistant/utils/functions/getIconForType.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Manages the timetable data, including fetching, caching, notification scheduling, and event processing.
class TimeTableManager {
  final CacheService _cacheService;
  final NotificationService _notificationService;
  final NativeCalendarService _nativeCalendarService;

  // List to store timetable events.
  List<Map<String, dynamic>> eventsData = [];

  /// Base URL for the timetable server.
  final String timetableUrl = 'https://party.xenium.rocks';
  final cacheKey = 'timetable_data'; // Cache key for locally stored timetable data.


  // Start and end dates of the onboarding process.
  DateTime? startDate;
  DateTime? endDate;

  // Offset for date adjustment.
  int dateOffset = DateTime.now().difference(DateTime(2024, 8, 29)).inDays;

  /// Constructor for dependency injection.
  TimeTableManager(
    this._cacheService,
    this._notificationService,
    this._nativeCalendarService,
  );

/// Loads dates from a local JSON file.
/// Throws an error if required keys are missing or date formats are invalid.
Future<void> loadStartEndDates() async {
  try {
    // Load the JSON file containing onboarding data.
    final jsonString = await rootBundle.loadString('assets/data/onboarding_data.json');
    final jsonData = json.decode(jsonString);

    // Check if both 'startDate' and 'endDate' keys are present in the JSON.
    if (jsonData.containsKey('startDate') && jsonData.containsKey('endDate')) {
      // Parse the start and end dates from the JSON data.
      startDate = DateTime.tryParse(jsonData['startDate']);
      endDate = DateTime.tryParse(jsonData['endDate']);

      // Validate the parsed dates to ensure they are in the correct format.
      if (startDate == null || endDate == null) {
        throw FormatException('Invalid date format in onboarding data.');
      }
    } else {
      // Throw an error if required keys are missing from the JSON file.
      throw FormatException('Onboarding data is missing required keys.');
    }
  } catch (e) {
    // Handle any errors that occur during file reading or parsing.
    ErrorHelper.handleError(e);
    throw Exception(ErrorHelper.getErrorMessage(e));
  }
}




/// Fetches timetable data from the server or cache.
/// Uses cached data if available unless a forced refresh is requested. 
/// Otherwise, fetches data from the server and optionally caches it.
Future<void> fetchTimetable({bool applyOffset = true, bool forceRefresh = false}) async {
  // Check for cached data if caching is enabled and refresh is not forced.
  final isCacheEnabled = await _cacheService.isCacheEnabled();
  if (isCacheEnabled && !forceRefresh) {
    final cachedData = _cacheService.getData(cacheKey);
    if (cachedData != null) {
      try {
        eventsData = (cachedData as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(); // Converts cached data into usable format.
        scheduleEventNotificationCache(); // Schedule notifications for cached events.
        return; // Exit as cached data is successfully used.
      } catch (e) {
        ErrorHelper.handleError(e); // Handles cache-related errors.
        throw Exception(ErrorHelper.getErrorMessage(e));
      }
    }
  }
  // Fetch data from the server if cache is unavailable or refresh is forced.
  try {
    final response = await http.get(Uri.parse(timetableUrl)); // Fetch timetable data.
    if (response.statusCode == 200) {
      final document = BeautifulSoup(response.body); // Parses the HTML response.
      final days = document.findAll('h2'); // Day headers in the timetable.
      final tables = document.findAll('.events'); // Event data grouped by day.

      if (days.isEmpty || tables.isEmpty) {
        throw FormatException('No timetable data found in server response.');
      }
      eventsData = _processTimetableData(days, tables, applyOffset); // Process raw data.

      // Schedule notifications for fetched data.
      for (final day in eventsData) {
        final dateStr = day['date'] as String;
        final events = day['events'] as List<dynamic>;

        final parsedDate = parseDateTime(dateStr);
        if (parsedDate != null) {
          for (final event in events) {
            final eventMap = Map<String, dynamic>.from(event as Map);
            final time = eventMap['time'] as String;
            scheduleEventNotification(parsedDate, time, eventMap); // Schedule the notification.
          }
        }
      }
      // Cache processed data if enabled and available.
      if (eventsData.isNotEmpty && isCacheEnabled) {
        await _cacheService.setData(
          cacheKey,
          eventsData.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      } else if (eventsData.isEmpty) {
        throw Exception('Processed timetable data is empty.');
      }
    } else {
      throw HttpException('HTTP ${response.statusCode}: Failed to fetch timetable data.');
    }
  } catch (e) {
    ErrorHelper.handleError(e); // Handles network or parsing errors.
    throw Exception(ErrorHelper.getErrorMessage(e));
  }
}


  // /// Schedules notifications for cached timetable data.
  // void _prepareAndScheduleNotificationsForCachedData() {
  //   debugPrint('[TimeTableManager] Scheduling notifications for cached data...');
  //   for (final day in eventsData) {
  //     final date = day['date'] as String;
  //     final events = day['events'] as List<dynamic>;

  //     for (final event in events) {
  //       final eventMap = Map<String, dynamic>.from(event as Map);
  //       final time = eventMap['time'] as String;
  //       final eventDateTime = parseDateTimeFromCache(date, time);
  //       if (eventDateTime != null && eventDateTime.isAfter(DateTime.now())) {
  //         _notificationService.scheduleEventNotification(
  //           eventMap['description'] ?? 'Event',
  //           eventDateTime,
  //           payload: eventMap['type'] ?? 'General',
  //         );
  //       }
  //     }
  //   }
  // }

  /// Parses a date string and an optional time string into a DateTime object.
DateTime? parseDateTime(String date, [String? time]) {
  try {
    // Extract the date using a regex pattern.
    final dateMatch = RegExp(r'\((\d{4}-\d{2}-\d{2})\)').firstMatch(date);
    if (dateMatch != null) {
      final dateStr = dateMatch.group(1)!;
      final parsedDate = DateTime.parse(dateStr); // Converts to DateTime.
      if (time != null) {
        final timeParts = time.split(':');
        return DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      } else {
        return parsedDate; // Return date without time if time is not provided.
      }
    }
  } catch (e) {
    ErrorHelper.handleError(e);
  }
  return null; // Return null if parsing fails.
}

/// Processes timetable data from the HTML document.
///
/// Extracts and organizes event data grouped by day from the provided HTML structure.
/// This method processes days, table data, and optionally applies date offsets.
List<Map<String, dynamic>> _processTimetableData(
  List<Bs4Element> days,
  List<Bs4Element> tables,
  bool applyOffset,
) {
  try {
    // Generate a map of weekday names to their corresponding dates.
    final weekdayToDateMap = _generateDateMap();

    // Process each day in the timetable data.
    return List.generate(days.length, (i) {
      // Extract and trim the day's name.
      final dayName = days[i].text.trim();
      DateTime? parsedDate = weekdayToDateMap[dayName];

      // Skip unmatched days and log a warning.
      if (parsedDate == null) {
        debugPrint('[TimeTableManager] Warning: No matching date for day name: $dayName');
        return null;
      }

      // Apply date offset if required.
      if (applyOffset) parsedDate = parsedDate.add(Duration(days: dateOffset));

      // Format the date for display.
      final formattedDate =
          "${DateFormat('EEEE').format(parsedDate)} (${DateFormat('yyyy-MM-dd').format(parsedDate)})";

      // Extract all event rows for the current day.
      final eventRows = tables[i].findAll('tr');
      String lastKnownTime = '';
      // Process individual event rows.
      final events = eventRows.map<Map<String, dynamic>>((row) {
        // Extract the time from the first column; use the last known time if empty.
        final rawTime = row.children[0].text.trim();
        final time = rawTime.isNotEmpty ? rawTime : lastKnownTime;
        if (rawTime.isNotEmpty) lastKnownTime = rawTime;

        // Create a map for event data with type, description, and styling.
        return {
          'time': time,
          'type': row.children[1].text.trim(),
          'description': row.children[2].text.trim(),
          'icon': getIconForType(row.children[1].text.trim()).codePoint,
          'fontFamily': getIconForType(row.children[1].text.trim()).fontFamily,
          'color': getColorForType(row.children[1].text.trim()).value,
        };
      }).toList();

      // Return the formatted date and associated events.
      return {
        'date': formattedDate,
        'events': events,
      };
    }).whereType<Map<String, dynamic>>().toList(); // Filter null values
  } catch (e) {
    // Handle any errors during data processing.
    ErrorHelper.handleError(e);
    throw Exception(ErrorHelper.getErrorMessage(e));
  }
}

  /// Schedules notifications for events.
void scheduleEventNotification(DateTime date, String time, Map<String, dynamic> eventData) {
  try {
    // Convert time string to a DateTime object.
    final timeParts = time.split(':');
    final eventDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    // Schedule notification only for future events.
    if (eventDateTime.isAfter(DateTime.now())) {
      _notificationService.scheduleEventNotification(
        eventData['description'] ?? 'Event',
        eventDateTime,
        payload: eventData['type'] ?? 'General',
      );

    }
  } catch (e) {
    ErrorHelper.handleError(e);
  }
}

/// Schedules notifications for all cached timetable events.
void scheduleEventNotificationCache() {
  // Iterate through each day's events in the cached data.
  for (final day in eventsData) {
    final dateStr = day['date'] as String; // Extract the date string.
    final events = day['events'] as List<dynamic>; // Extract the list of events.

    // Parse the date from the cached date string.
    final parsedDate = parseDateTime(dateStr);
    if (parsedDate != null) {
      // Iterate through each event and schedule a notification.
      for (final event in events) {
        final eventMap = Map<String, dynamic>.from(event as Map); // Convert event to a map.
        final time = eventMap['time'] as String; // Extract the event time.
        scheduleEventNotification(parsedDate, time, eventMap); // Schedule the notification.
      }
    }
  }
}

  /// Generates a map of weekday names to dates.
  Map<String, DateTime> _generateDateMap() {
    if (startDate == null || endDate == null) {
      throw Exception('Onboarding dates are not loaded.');
    }

    final map = <String, DateTime>{};
    var currentDate = startDate!;
    while (!currentDate.isAfter(endDate!)) {
      final weekday = DateFormat('EEEE').format(currentDate);
      map[weekday] = currentDate;
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return map;
  }

/// Adds an event to the user's personal calendar.
/// Dynamically calculates the event's end time based on its duration.
Future<void> addEventToCalendar(String date, String time, String description, String type) async {
  // Extract the actual date from formatted strings like "Friday (2024-12-13)".
  final match = RegExp(r'\((\d{4}-\d{2}-\d{2})\)').firstMatch(date);
  if (match != null) {
    final dateStr = match.group(1)!; // Extracted date string.
    final parsedDate = DateTime.parse(dateStr); // Converts to DateTime.
    final timeParts = time.split(':'); // Splits time into hours and minutes.

    // Constructs the start time for the event.
    final eventStartTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    // Calculate the end time dynamically based on event type.
    final eventEndTime = _calculateEventEndTime(eventStartTime, eventType: type);

    // Adds the event to the native calendar.
    await _nativeCalendarService.addEventToNativeCalendar(
      title: description,
      start: eventStartTime,
      end: eventEndTime,
      description: type,
      allDay: false,
    );
  }
}

/// Calculates the end time of an event based on its type.
/// 
/// - [startTime]: The start time of the event.
/// - [eventType]: Optional event type to determine the duration.
/// 
/// Returns a [DateTime] object representing the end time.
DateTime _calculateEventEndTime(DateTime startTime, {String? eventType}) {
  // Define default durations for specific event types.
  final eventDurations = {
    'Workshop': const Duration(hours: 2),
    'Presentation': const Duration(hours: 1, minutes: 30),
    'Meeting': const Duration(hours: 1),
  };

  // Use the predefined duration if available; otherwise, default to 1 hour.
  final duration = eventDurations[eventType] ?? const Duration(hours: 1);
  return startTime.add(duration);
}

}
