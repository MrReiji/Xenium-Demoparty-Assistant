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

  /// Loads onboarding dates from a local JSON file.
  Future<void> loadOnboardingDates() async {
    try {
      debugPrint('[TimeTableManager] Loading onboarding dates...');
      final jsonString = await rootBundle.loadString('assets/data/onboarding_data.json');
      final jsonData = json.decode(jsonString);

      if (jsonData.containsKey('startDate') && jsonData.containsKey('endDate')) {
        startDate = DateTime.tryParse(jsonData['startDate']);
        endDate = DateTime.tryParse(jsonData['endDate']);

        if (startDate == null || endDate == null) {
          throw FormatException('Invalid date format in onboarding data.');
        }
        debugPrint('[TimeTableManager] Onboarding dates loaded: startDate=$startDate, endDate=$endDate.');
      } else {
        throw FormatException('Onboarding data is missing required keys.');
      }
    } catch (e) {
      ErrorHelper.handleError(e);
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
  }

  /// Fetches timetable data from the server or cache.
  ///
  /// - [applyOffset]: Whether to apply a date offset.
  /// - [forceRefresh]: Whether to bypass the cache and fetch fresh data.
  Future<void> fetchTimetable({bool applyOffset = true, bool forceRefresh = false}) async {
    const cacheKey = 'timetable_data';
    debugPrint('[TimeTableManager] Fetching timetable data...');

    final isCacheEnabled = await _cacheService.isCacheEnabled();
    if (isCacheEnabled && !forceRefresh) {
      final cachedData = _cacheService.getData(cacheKey);
      if (cachedData != null) {
        debugPrint('[TimeTableManager] Using cached timetable data.');
        try {
          eventsData = (cachedData as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _scheduleNotificationsForCachedData();
          return;
        } catch (e) {
          ErrorHelper.handleError(e);
          throw Exception(ErrorHelper.getErrorMessage(e));
        }
      }
    }

    try {
      final response = await http.get(Uri.parse('https://party.xenium.rocks/timetable'));
      if (response.statusCode == 200) {
        debugPrint('[TimeTableManager] Raw HTML response fetched.');
        final document = BeautifulSoup(response.body);
        final days = document.findAll('h2');
        final tables = document.findAll('.events');

        if (days.isEmpty || tables.isEmpty) {
          throw FormatException('No timetable data found in server response.');
        }

        eventsData = _processTimetableData(days, tables, applyOffset);

        if (eventsData.isNotEmpty && isCacheEnabled) {
          await _cacheService.setData(cacheKey, eventsData.map((e) => Map<String, dynamic>.from(e)).toList());
          debugPrint('[TimeTableManager] Timetable data successfully fetched and cached.');
        } else if (eventsData.isEmpty) {
          throw Exception('Processed timetable data is empty.');
        }
      } else {
        throw HttpException('HTTP ${response.statusCode}: Failed to fetch timetable data.');
      }
    } catch (e) {
      ErrorHelper.handleError(e);
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
  }

  /// Schedules notifications for cached timetable data.
  void _scheduleNotificationsForCachedData() {
    debugPrint('[TimeTableManager] Scheduling notifications for cached data...');
    for (final day in eventsData) {
      final date = day['date'] as String;
      final events = day['events'] as List<dynamic>;

      for (final event in events) {
        final eventMap = Map<String, dynamic>.from(event as Map);
        final time = eventMap['time'] as String;
        final eventDateTime = parseDateTimeFromCache(date, time);
        if (eventDateTime != null && eventDateTime.isAfter(DateTime.now())) {
          _notificationService.scheduleEventNotification(
            eventMap['description'] ?? 'Event',
            eventDateTime,
            payload: eventMap['type'] ?? 'General',
          );
        }
      }
    }
  }

  /// Parses a date and time string from cached data.
  DateTime? parseDateTimeFromCache(String date, String time) {
    try {
      final dateMatch = RegExp(r'\((\d{4}-\d{2}-\d{2})\)').firstMatch(date);
      if (dateMatch != null) {
        final dateStr = dateMatch.group(1)!;
        final parsedDate = DateTime.parse(dateStr);
        final timeParts = time.split(':');
        return DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      }
    } catch (e) {
      ErrorHelper.handleError(e);
    }
    return null;
  }

  /// Processes timetable data from the HTML document.
  List<Map<String, dynamic>> _processTimetableData(
    List<Bs4Element> days,
    List<Bs4Element> tables,
    bool applyOffset,
  ) {
    try {
      final weekdayToDateMap = _generateDateMap();

      return List.generate(days.length, (i) {
        final dayName = days[i].text.trim();
        DateTime? parsedDate = weekdayToDateMap[dayName];

        if (parsedDate == null) {
          debugPrint('[TimeTableManager] Warning: No matching date for day name: $dayName');
          return null; // Ignore unmatched days
        }

        if (applyOffset) parsedDate = parsedDate.add(Duration(days: dateOffset));

        final formattedDate =
            "${DateFormat('EEEE').format(parsedDate)} (${DateFormat('yyyy-MM-dd').format(parsedDate)})";
        final eventRows = tables[i].findAll('tr');
        String lastKnownTime = '';

        final events = eventRows.map<Map<String, dynamic>>((row) {
          final rawTime = row.children[0].text.trim();
          final time = rawTime.isNotEmpty ? rawTime : lastKnownTime;
          if (rawTime.isNotEmpty) lastKnownTime = rawTime;

          final eventData = {
            'time': time,
            'type': row.children[1].text.trim(),
            'description': row.children[2].text.trim(),
            'icon': getIconForType(row.children[1].text.trim()).codePoint,
            'fontFamily': getIconForType(row.children[1].text.trim()).fontFamily,
            'color': getColorForType(row.children[1].text.trim()).value,
          };

          _scheduleNotificationForEvent(parsedDate!, time, eventData);
          return eventData;
        }).toList();

        return {
          'date': formattedDate,
          'events': events,
        };
      }).whereType<Map<String, dynamic>>().toList(); // Filter null values
    } catch (e) {
      ErrorHelper.handleError(e);
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
  }

  /// Schedules a notification for an individual event.
  void _scheduleNotificationForEvent(DateTime date, String time, Map<String, dynamic> eventData) {
    try {
      final timeParts = time.split(':');
      final eventDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      _notificationService.scheduleEventNotification(
        eventData['description'] ?? 'Event',
        eventDateTime,
        payload: eventData['type'] ?? 'General',
      );
      debugPrint('[TimeTableManager] Notification scheduled for event "${eventData['description']}" at $eventDateTime.');
    } catch (e) {
      ErrorHelper.handleError(e);
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

  /// Adds an event to the native calendar.
  Future<void> addEventToCalendar(String date, String time, String description, String type) async {
    final match = RegExp(r'\((\d{4}-\d{2}-\d{2})\)').firstMatch(date);
    if (match != null) {
      final dateStr = match.group(1)!;
      final parsedDate = DateTime.parse(dateStr);
      final timeParts = time.split(':');
      final eventStartTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      await _nativeCalendarService.addEventToNativeCalendar(
        title: description,
        start: eventStartTime,
        end: eventStartTime.add(const Duration(hours: 1)),
        description: type,
        location: 'Default Location',
        allDay: false,
      );
      debugPrint('[TimeTableManager] Event added to calendar: $description at $eventStartTime.');
    }
  }
}
