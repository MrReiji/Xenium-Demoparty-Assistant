import 'package:demoparty_assistant/data/manager/streams/streams_manager.dart';
import 'package:demoparty_assistant/views/screens/video_player_screen.dart';
import 'package:demoparty_assistant/views/widgets/video/universal_video_player.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';

/// Displays live and archived streams with a search feature.
class StreamsScreen extends StatefulWidget {
  @override
  _StreamsScreenState createState() => _StreamsScreenState();
}

class _StreamsScreenState extends State<StreamsScreen> {
  final StreamsManager _streamsManager = StreamsManager();
  List<Map<String, String>> streams = [];
  List<Map<String, String>> filteredStreams = [];
  Map<String, String>? liveStream;
  bool isLoading = true;
  String? errorMessage;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStreams();
    searchController.addListener(_filterStreams);
  }

  Future<void> fetchStreams({bool forceRefresh = false}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      liveStream = await _streamsManager.fetchLiveStream();
      streams = await _streamsManager.fetchArchiveStreams();
      filteredStreams = List.from(streams);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterStreams() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredStreams = streams.where((stream) {
        return stream['title']!.toLowerCase().contains(query);
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
            onPressed: () => fetchStreams(forceRefresh: true),
          ),
        ],
      ),
      drawer: AppDrawer(currentPage: 'Streams'),
      body: isLoading
          ? const LoadingWidget(
              title: "Loading Streams",
              message: "Please wait while we fetch the latest streams.",
            )
          : errorMessage != null
              ? ErrorDisplayWidget(
                  title: "Error Loading Streams",
                  message: errorMessage!,
                  onRetry: () => fetchStreams(forceRefresh: true),
                )
              : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      children: [
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: (liveStream != null ? 1 : 0) + filteredStreams.length,
            itemBuilder: (context, index) {
              if (liveStream != null && index == 0) {
                return _buildLiveStreamCard(theme);
              }
              final stream = filteredStreams[index - (liveStream != null ? 1 : 0)];
              return _buildStreamCard(theme, stream);
            },
          ),
        ),
      ],
    );
  }

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
                    videoUrl: liveStream!['url']!,
                    isEmbedded: false, // Fullscreen for streams
                  ),
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                liveStream!['title']!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                liveStream!['description']!,
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
                url: stream['url']!,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream['title']!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: 5),
                        Text(
                          stream['date']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.timer,
                            size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: 5),
                        Text(
                          stream['duration']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 25,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.play_arrow,
                  color: theme.colorScheme.onPrimary,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
