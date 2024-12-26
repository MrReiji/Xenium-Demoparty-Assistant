import 'package:demoparty_assistant/data/manager/generic_content/generic_content_manager.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:demoparty_assistant/views/Theme.dart';

class GenericContentScreen extends StatefulWidget {
  final String url;
  final String title;
  final String currentPage;

  const GenericContentScreen({
    required this.url,
    required this.title,
    required this.currentPage,
    Key? key,
  }) : super(key: key);

  @override
  _GenericContentScreenState createState() => _GenericContentScreenState();
}

class _GenericContentScreenState extends State<GenericContentScreen> {
  late final GenericContentManager _contentManager;
  late Future<List<Widget>> _contentFuture;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _contentManager = GenericContentManager();
    _loadContent();
  }

  /// Loads content from the manager with error handling.
  void _loadContent({bool forceRefresh = false}) {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    _contentFuture = _contentManager
        .fetchContent(widget.url, forceRefresh: forceRefresh)
        .catchError((error) {
      ErrorHelper.handleError(error);
      setState(() => errorMessage = ErrorHelper.getErrorMessage(error));
      return <Widget>[];
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  /// Refreshes the content.
  Future<void> _refreshContent() async {
    _loadContent(forceRefresh: true);
    await _contentFuture;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!isLoading) {
                _refreshContent();
              }
            },
            tooltip: "Refresh Content",
          ),
        ],
      ),
      drawer: AppDrawer(currentPage: widget.currentPage),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        child: FutureBuilder<List<Widget>>(
          future: _contentFuture,
          builder: (context, snapshot) {
            if (isLoading) {
              return const LoadingWidget(
                title: "Loading Content",
                message: "Please wait while we fetch the latest content for you.",
              );
            } else if (errorMessage != null) {
              return ErrorDisplayWidget(
                title: "Error Loading Content",
                message: errorMessage!,
                onRetry: () => _loadContent(forceRefresh: true),
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return ErrorDisplayWidget(
                title: "No Content Available",
                message: "There is currently no content to display for this section.",
              );
            } else if (snapshot.hasError) {
              return ErrorDisplayWidget(
                title: "Error Loading Content",
                message: ErrorHelper.getErrorMessage(snapshot.error ?? "Unknown error"),
                onRetry: () => _loadContent(forceRefresh: true),
              );
            } else if (snapshot.hasData) {
              final contentWidgets = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contentWidgets,
                ),
              );
            } else {
              return ErrorDisplayWidget(
                title: "Unexpected Error",
                message: "An unknown error occurred. Please try refreshing the content.",
                onRetry: () => _loadContent(forceRefresh: true),
              );
            }
          },
        ),
      ),
    );
  }
}
