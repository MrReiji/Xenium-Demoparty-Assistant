import 'package:demoparty_assistant/data/manager/streams/streams_manager.dart';
import 'package:demoparty_assistant/views/screens/video_player_screen.dart';
import 'package:demoparty_assistant/views/widgets/video/universal_video_player.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';

/// Displays a list of live and archived streams with search functionality.
class StreamsScreen extends StatefulWidget {
  @override
  _StreamsScreenState createState() => _StreamsScreenState();
}

class _StreamsScreenState extends State<StreamsScreen> {
  // Manages fetching and handling streams data (live and archive).
  final StreamsManager _streamsManager = StreamsManager();

  // Lists for storing fetched streams and filtered streams.
  List<Map<String, String>> streams = [];
  List<Map<String, String>> filteredStreams = [];

  // Stores live stream data, if available.
  Map<String, String>? liveStream;

  // Tracks loading and error states.
  bool isLoading = true;
  String? errorMessage;

  // Controller for the search input field.
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStreams(); // Fetch streams on initialization.
    searchController.addListener(filterStreams); // Listen for search input changes.
  }

  /// Fetches streams from the manager and updates the UI.
  /// If [forceRefresh] is true, forces a re-fetch of data.
  Future<void> fetchStreams({bool forceRefresh = false}) async {
    setState(() {
      isLoading = true; // Show loading spinner.
      errorMessage = null; // Clear previous errors.
    });

    try {
      // Fetch live and archived streams.
      liveStream = await _streamsManager.fetchLiveStream();
      streams = await _streamsManager.fetchArchiveStreams();
      filteredStreams = List.from(streams); // Initialize filtered list.
    } catch (e) {
      // Handle fetch errors and store the error message.
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false); // Stop loading spinner.
    }
  }

  /// Filters the streams list based on the search query.
  void filterStreams() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredStreams = streams.where((stream) {
        return stream['title']!.toLowerCase().contains(query); // Check if title matches the query.
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchStreams(forceRefresh: true), // Refresh streams on button press.
          ),
        ],
      ),
      drawer: AppDrawer(currentPage: 'Streams'), // App drawer for navigation.
      body: isLoading
          ? const LoadingWidget(
              title: "Loading Streams",
              message: "Please wait while we fetch the latest streams.",
            ) // Show loading indicator if data is loading.
          : errorMessage != null
              ? ErrorDisplayWidget(
                  title: "Error Loading Streams",
                  message: errorMessage!, // Display error message if there's an issue.
                  onRetry: () => fetchStreams(forceRefresh: true), // Retry fetching on error.
                )
              : _buildContent(theme), // Show content if data is successfully loaded.
    );
  }

  /// Builds the main content of the streams screen.
  Widget _buildContent(ThemeData theme) {
    return Column(
      children: [
        // Search input field for filtering streams.
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search streams',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        // List of live and archived streams.
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: (liveStream != null ? 1 : 0) + filteredStreams.length, // Include live stream if available.
            itemBuilder: (context, index) {
              // Display live stream card if it's the first item.
              if (liveStream != null && index == 0) {
                return _buildLiveStreamCard(theme);
              }
              // Display archived stream card for other items.
              final stream = filteredStreams[index - (liveStream != null ? 1 : 0)];
              return _buildStreamCard(theme, stream);
            },
          ),
        ),
      ],
    );
  }

  /// Builds the card widget for the live stream.
  Widget _buildLiveStreamCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: InkWell(
        onTap: () {
          if (liveStream != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(liveStream!['title']!)),
                  body: UniversalVideoPlayer(
                    videoUrl: liveStream!['url']!, // URL for the live stream.
                    isEmbedded: false, // Fullscreen playback for live streams.
                  ),
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1), // Highlight live stream.
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                liveStream!['title']!, // Display live stream title.
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                liveStream!['description']!, // Display live stream description.
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the card widget for stream.
  Widget _buildStreamCard(ThemeData theme, Map<String, String> stream) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                title: stream['title']!,
                date: stream['date']!,
                url: stream['url']!, // URL for the stream.
              ),),);},
        child: Container( padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(15),),
          child: Row( crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream['title']!, // Display stream title.
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface,),
                      maxLines: 2, overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: 5),
                        Text(
                          stream['date']!, // Display stream date.
                          style: theme.textTheme.bodySmall?.copyWith( color: theme.colorScheme.onSurface,),),
                        const SizedBox(width: 10),
                        Icon(Icons.timer,
                            size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: 5),
                        Text(
                          stream['duration']!, // Display stream duration.
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),),],),],),),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 25, backgroundColor: theme.colorScheme.primary,
                // Play button
                child: Icon(
                  Icons.play_arrow, color: theme.colorScheme.onPrimary,
                  size: 30, ),),], ),),),);}

  @override
  void dispose() {
    searchController.dispose(); // Clean up search controller on widget disposal.
    super.dispose();
  }
}
