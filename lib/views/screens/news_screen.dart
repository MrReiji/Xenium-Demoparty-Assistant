import 'package:demoparty_assistant/data/manager/news/news_manager.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/models/news_model.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:demoparty_assistant/views/widgets/cards/news_card.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:get_it/get_it.dart';

/// The NewsScreen displays a list of news articles related to demoparties.
/// It uses the NewsManager to fetch articles and handles errors gracefully.
class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsState();
}

class _NewsState extends State<NewsScreen> {
  late Future<List<NewsModel>> _newsFuture; // Holds the future result of news fetching.
  final NewsManager _newsManager = GetIt.I<NewsManager>(); // Dependency-injected manager for fetching news.
  String? errorMessage; // Stores error messages for display.

  @override
  void initState() {
    super.initState();
    _fetchNews(); // Fetch news when the screen initializes.
  }

  /// Fetches news articles and handles potential errors.
  ///
  /// - [forceRefresh]: If `true`, forces the news manager to refresh data.
  Future<void> _fetchNews({bool forceRefresh = false}) async {
    setState(() => errorMessage = null); // Clear previous error messages.

    try {
      // Fetch news using the manager, with an option to force a refresh.
      _newsFuture = _newsManager.fetchNews(forceRefresh: forceRefresh);
      await _newsFuture; // Wait for the news to be fetched.
    } catch (e) {
      // Log and display a user-friendly error message using ErrorHelper.
      ErrorHelper.handleError(e);
      setState(() => errorMessage = ErrorHelper.getErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demoparty News"), // Screen title.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchNews(forceRefresh: true), // Refresh news on button click.
            tooltip: "Refresh News",
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: "News"), // Side navigation drawer.
      body: FutureBuilder<List<NewsModel>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          // Show loading widget while data is being fetched.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
              title: "Loading News",
              message: "Fetching the latest news articles. Please wait...",
            );
          }

          // Display error message if fetching news failed.
          if (errorMessage != null) {
            return ErrorDisplayWidget(
              title: "Error Loading News",
              message: errorMessage!,
              onRetry: () => _fetchNews(forceRefresh: true), // Retry fetching news.
            );
          }

          // Handle unexpected errors during the FutureBuilder operation.
          if (snapshot.hasError) {
            return ErrorDisplayWidget(
              title: "Unexpected Error",
              message: ErrorHelper.getErrorMessage(snapshot.error ?? "Unknown error occurred."),
              onRetry: () => _fetchNews(forceRefresh: true), // Retry fetching news.
            );
          }

          // Check if the fetched news list is empty and show a placeholder message.
          final newsList = snapshot.data ?? [];
          if (newsList.isEmpty) {
            return ErrorDisplayWidget(
              title: "No News Available",
              message: "No news articles are currently available. Please check back later.",
              onRetry: () => _fetchNews(forceRefresh: true), // Retry fetching news.
            );
          }

          // Display the list of news articles.
          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) => NewsCard(news: newsList[index]), // Render each news card.
          );
        },
      ),
    );
  }
}
