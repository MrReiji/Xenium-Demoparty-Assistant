import 'package:demoparty_assistant/data/manager/news/news_manager.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/models/news_model.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:demoparty_assistant/views/widgets/cards/news_card.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:get_it/get_it.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsState();
}

class _NewsState extends State<NewsScreen> {
  late Future<List<NewsModel>> _newsFuture;
  final NewsManager _newsManager = GetIt.I<NewsManager>();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  /// Fetches news articles with error handling.
  Future<void> _fetchNews({bool forceRefresh = false}) async {
    setState(() => errorMessage = null);

    try {
      _newsFuture = _newsManager.fetchNews(forceRefresh: forceRefresh);
      await _newsFuture;
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() => errorMessage = ErrorHelper.getErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Demoparty News"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchNews(forceRefresh: true),
            tooltip: "Refresh News",
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: "News"),
      body: FutureBuilder<List<NewsModel>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
              title: "Loading News",
              message: "Fetching the latest news articles. Please wait...",
            );
          }
          if (errorMessage != null) {
            return ErrorDisplayWidget(
              title: "Error Loading News",
              message: errorMessage!,
              onRetry: () => _fetchNews(forceRefresh: true),
            );
          }
          if (snapshot.hasError) {
            return ErrorDisplayWidget(
              title: "Unexpected Error",
              message: ErrorHelper.getErrorMessage(snapshot.error ?? "Unknown error occurred."),
              onRetry: () => _fetchNews(forceRefresh: true),
            );
          }

          final newsList = snapshot.data ?? [];
          if (newsList.isEmpty) {
            return ErrorDisplayWidget(
              title: "No News Available",
              message: "No news articles are currently available. Please check back later.",
              onRetry: () => _fetchNews(forceRefresh: true),
            );
          }

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) => NewsCard(news: newsList[index]),
          );
        },
      ),
    );
  }
}
