import 'package:demoparty_assistant/data/manager/time_table/time_table_manager.dart';
import 'package:demoparty_assistant/views/widgets/cards/event_card.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:get_it/get_it.dart';

/// Displays the timetable with events grouped by day.
/// Allows searching for events and refreshing the data.
class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({Key? key}) : super(key: key);

  @override
  _TimeTableScreenState createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen>
    with AutomaticKeepAliveClientMixin {
  late final TimeTableManager _manager;
  late Future<void> _dataFuture;
  List<Map<String, dynamic>> _dayData = [];
  String? errorMessage;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _manager = GetIt.instance<TimeTableManager>();
    _dataFuture = _initializeData();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Initializes timetable data by fetching events from the manager.
  /// Optionally forces a data refresh.
  Future<void> _initializeData({bool forceRefresh = false}) async {
    try {
      // Loads the start and end dates of the demoparty.
      await _manager.loadStartEndDates();

      // Fetches timetable data from the server or cache.
      await _manager.fetchTimetable(forceRefresh: forceRefresh);

      // Stores fetched data for use in filtering and rendering.
      _dayData = List.from(_manager.eventsData);

      setState(() {}); // Updates the UI with the loaded data.
    } catch (e) {
      setState(() => errorMessage = e.toString()); // Displays error messages.
    }
  }

  /// Applies a search filter to the timetable data.
  void _applyFilter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // Reset to original data if the search field is empty.
        _dayData = List.from(_manager.eventsData);
      } else {
        // Filter each day's events based on the search query.
        _dayData = _manager.eventsData.map((day) {
          final dayDate = day['date'] ?? 'Unknown date';
          final filteredEvents = (day['events'] as List?)
              ?.where((event) => event.values.any(
                  (value) => value.toString().toLowerCase().contains(query)))
              .toList();
          return {
            'date': dayDate,
            'events': filteredEvents ?? [],
          };
        }).toList();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  /// Builds the main structure of the timetable screen.
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar:

          /// App Bar with navigation title and refresh functionality.
          AppBar(
        title: const Text("TimeTable"), // Displays the title of the screen.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh icon.
            onPressed: () {
              _searchController.clear(); // Clears the search filter input.
              setState(() {
                _dataFuture = _initializeData(
                    forceRefresh: true); // Reloads timetable data.
              });
            },

            /// Tooltip for the refresh button to inform users it refreshes the timetable.
            /// Tooltip displayed when the user long-presses the button.
            tooltip: "Refresh Timetable",
          ),
        ],
      ),
      drawer: AppDrawer(currentPage: "TimeTable"),
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
              title: "Loading Timetable",
              message: "Please wait while we fetch the latest timetable data.",
            );
          } else if (errorMessage != null) {
            return ErrorDisplayWidget(
              title: "Error Loading Timetable",
              message: errorMessage!,
              onRetry: () => setState(() {
                _dataFuture = _initializeData(forceRefresh: true);
              }),
            );
          }

          return _buildTimeTableContent(theme);
        },
      ),
    );
  }

  /// Builds the content of the timetable, including the search field and list of events.
  Widget _buildTimeTableContent(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child:

              /// Search field for filtering events dynamically.
              TextField(
            controller: _searchController, // Manages user input.
            decoration: InputDecoration(
              labelText: 'Search', // Placeholder text for the search field.
              prefixIcon: const Icon(
                  Icons.search), // Search icon to indicate functionality.
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0), // Rounded borders.
              ),
            ),
            onChanged: (query) =>
                _applyFilter(), // Updates the filtered event list on input.
          ),
        ),
        Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                // Reset search field and reload data.
                _searchController.clear();
                setState(() {
                  _dataFuture = _initializeData(forceRefresh: true);
                });
                await _dataFuture;
              },
              child:

                  /// Scrollable list of events grouped by date.
                  ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0), // Adds horizontal padding for alignment.
                itemCount:
                    _dayData.length, // Total number of date groups to display.
                itemBuilder: (context, index) {
                  final day = _dayData[
                      index]; // Retrieves the data for the current day.
                  final dayDate = day['date'] ??
                      'Unknown date'; // Retrieves the date header for the day.
                  final events = day['events'] as List? ??
                      []; // Retrieves the list of events for the day.
                  return _buildDayDataWidget(
                      dayDate, events); // Builds the UI for the day's events.
                },
              )),
        ),
      ],
    );
  }

  /// Builds the UI for a specific day's events.
  /// Displays a fallback message if no events are available.
  Widget _buildDayDataWidget(String dayDate, List events) {
    final theme =
        Theme.of(context); // Retrieves the current app theme for styling.
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 16.0), // Adds spacing below the day's events.
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligns content to the left.
        children: [
          Text(
            dayDate, // Displays the date header (e.g., Friday (2024-12-13)).
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface, // Sets the text color.
              fontWeight: FontWeight.bold, // Uses bold font for emphasis.
            ),
          ),
          const SizedBox(height: 8.0), // Adds spacing below the date header.
          if (events.isEmpty)
            _buildNoEventsMessage(
                theme) // Calls a method to display a fallback message for no events.
          else
            Column(
              children: events.map<Widget>((event) {
                final eventMap =
                    Map<String, dynamic>.from(event); // Parses event data.
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0), // Adds spacing between event cards.
                  child: EventCard(
                    time: eventMap['time'] ?? '', // Event's start time.
                    icon: IconData(eventMap['icon'],
                        fontFamily: eventMap['fontFamily']), // Event type icon.
                    title: eventMap['description'] ?? '', // Event title.
                    color: Color(eventMap[
                        'color']), // Background color for the event type.
                    label: eventMap['type'] ?? '', // Event type label.
                    addToCalendar: () => _manager.addEventToCalendar(
                      dayDate,
                      eventMap['time'] ?? '',
                      eventMap['description'] ?? '',
                      eventMap['type'] ?? '',
                    ), // Adds the event to the user's personal calendar.
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Displays a fallback message when no events are scheduled for a day.
  Widget _buildNoEventsMessage(ThemeData theme) {
    return Container(
      width: double.infinity, // Spans the full width of the parent container.
      decoration: BoxDecoration(
        color: theme.colorScheme.surface
            .withOpacity(0.1), // Sets a light background color.
        borderRadius: BorderRadius.circular(12.0), // Adds rounded corners.
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 16.0, horizontal: 12.0), // Adds internal padding.
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers the content horizontally.
        children: [
          Icon(
            Icons.event_busy, // Icon representing no events.
            color: theme.colorScheme.primary
                .withOpacity(0.8), // Matches the theme color.
            size: 28, // Icon size.
          ),
          const SizedBox(
              width: 8.0), // Adds spacing between the icon and the text.
          Text(
            "No events scheduled for this day", // Informative message text.
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface
                  .withOpacity(0.9), // Sets the text color.
              fontWeight:
                  FontWeight.w500, // Uses medium font weight for emphasis.
            ),
          ),
        ],
      ),
    );
  }
}
