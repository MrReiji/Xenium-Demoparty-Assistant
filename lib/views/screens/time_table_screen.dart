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

class _TimeTableScreenState extends State<TimeTableScreen> with AutomaticKeepAliveClientMixin {
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
      setState(() => errorMessage = null);
      await _manager.loadOnboardingDates();
      await _manager.fetchTimetable(forceRefresh: forceRefresh);
      _dayData = List.from(_manager.eventsData); // Copy original data for filtering.
      setState(() {});
    } catch (e) {
      setState(() => errorMessage = e.toString());
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
              ?.where((event) => event.values.any((value) =>
                  value.toString().toLowerCase().contains(query)))
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
      appBar: AppBar(
        title: const Text("TimeTable"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reset search field and reload data.
              _searchController.clear();
              setState(() {
                _dataFuture = _initializeData(forceRefresh: true);
              });
            },
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
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _dayData.length,
              itemBuilder: (context, index) {
                final day = _dayData[index];
                final dayDate = day['date'] ?? 'Unknown date';
                final events = day['events'] as List? ?? [];
                return _buildDayDataWidget(dayDate, events);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a widget for a specific day's events.
  /// If there are no events, displays a message instead.
  Widget _buildDayDataWidget(String dayDate, List events) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayDate,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          if (events.isEmpty)
            _buildNoEventsMessage(theme)
          else
            Column(
              children: events.map<Widget>((event) {
                final eventMap = Map<String, dynamic>.from(event);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: EventCard(
                    time: eventMap['time'] ?? '',
                    icon: IconData(eventMap['icon'] ?? 0xe3c9, fontFamily: eventMap['fontFamily'] ?? 'MaterialIcons'),
                    title: eventMap['description'] ?? '',
                    color: Color(eventMap['color'] ?? 0xFFCCCCCC),
                    label: eventMap['type'] ?? '',
                    addToCalendar: () => _manager.addEventToCalendar(
                      dayDate,
                      eventMap['time'] ?? '',
                      eventMap['description'] ?? '',
                      eventMap['type'] ?? '',
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Builds a user-friendly message when there are no events for a specific day.
  Widget _buildNoEventsMessage(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            color: theme.colorScheme.primary.withOpacity(0.8),
            size: 28,
          ),
          const SizedBox(width: 8.0),
          Text(
            "No events scheduled for this day",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
