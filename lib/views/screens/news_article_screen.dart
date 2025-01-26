import 'package:demoparty_assistant/data/manager/news/news_article_manager.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:get_it/get_it.dart';

class NewsArticleScreen extends StatefulWidget {
  final String title;
  final String image;
  final String articleUrl;

  const NewsArticleScreen({
    required this.title,
    required this.image,
    required this.articleUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<NewsArticleScreen> createState() => _NewsArticleScreenState();
}

class _NewsArticleScreenState extends State<NewsArticleScreen> {
  final NewsArticleManager _newsArticleManager = GetIt.I<NewsArticleManager>();
  List<Widget> _articleWidgets = [];
  String? _publishDate;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArticleContent();
  }

  /// Fetches the full content of the article with error handling.
  Future<void> _fetchArticleContent({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _newsArticleManager.fetchArticleContent(
        widget.articleUrl,
        forceRefresh: forceRefresh,
      );
      setState(() {
        _publishDate = data['publishDate'];
        _articleWidgets = data['articleWidgets'];
      });
    } catch (e) {
      ErrorHelper.handleError(e);
      setState(() {
        _errorMessage = ErrorHelper.getErrorMessage(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchArticleContent(forceRefresh: true),
            tooltip: "Refresh Content",
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(
              title: "Loading Article",
              message: "Fetching the full article content. Please wait...",
            )
          : _errorMessage != null
              ? ErrorDisplayWidget(
                  title: "Error Loading Article",
                  message: _errorMessage!,
                  onRetry: () => _fetchArticleContent(forceRefresh: true),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 100,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      Text(widget.title, style: theme.textTheme.headlineMedium),
                      if (_publishDate != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Published on: $_publishDate",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      const Divider(),
                      if (_articleWidgets.isNotEmpty)
                        ..._articleWidgets
                      else
                        const Text("No content available."),
                    ],
                  ),
                ),
    );
  }
}
