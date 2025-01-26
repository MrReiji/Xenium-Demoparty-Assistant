import 'package:demoparty_assistant/data/manager/voting/voting_manager.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:get_it/get_it.dart';

/// Displays the current competition status and voting entries.
class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final VotingManager _manager = GetIt.instance<VotingManager>();

  String competitionStatus = "Unknown";
  List<Map<String, dynamic>> votingEntries = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVotingData();
  }

  /// Fetches voting data and updates the screen state.
  Future<void> _fetchVotingData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _manager.fetchVotingData();
      setState(() {
        competitionStatus = data["competition"] ?? "No live voting at the moment!";
        votingEntries = data["entries"];
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        competitionStatus = "Unknown";
        votingEntries = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Voting"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVotingData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: "Voting"),
      body: isLoading
          ? const LoadingWidget(
              title: "Loading Voting Data",
              message: "Please wait while we fetch the latest voting data.",
            )
          : errorMessage != null
              ? ErrorDisplayWidget(
                  title: "Error Fetching Data",
                  message: errorMessage!,
                  onRetry: _fetchVotingData,
                )
              : _buildContent(theme),
    );
  }

  /// Builds the main content of the screen when no errors occur.
  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSection(theme),
          const SizedBox(height: 20),
          _buildVotingToolButton(theme),
          const SizedBox(height: 20),
          _buildVotingEntries(theme),
        ],
      ),
    );
  }

  /// Builds the voting status display section.
  Widget _buildStatusSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Voting Status:",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          competitionStatus,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 18,
          ),
        ),
        if (competitionStatus == "No live voting at the moment!")
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "There is currently no active competition. Please check back later.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the button to open the external voting tool.
  Widget _buildVotingToolButton(ThemeData theme) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _manager.openVotingTool,
        icon: const Icon(Icons.open_in_browser),
        label: const Text("Go to Voting Tool"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          textStyle: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
      ),
    );
  }

  /// Builds the list of voting entries.
  Widget _buildVotingEntries(ThemeData theme) {
    if (votingEntries.isEmpty) {
      return Center(
        child: Text(
          "No entries available for voting.",
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: votingEntries.length,
      itemBuilder: (context, index) {
        final entry = votingEntries[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              entry["title"]!,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
            ),
            subtitle: Text(
              "Position: ${entry["position"]!}",
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
