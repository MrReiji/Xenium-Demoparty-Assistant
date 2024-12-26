import 'package:cached_network_image/cached_network_image.dart';
import 'package:demoparty_assistant/data/manager/news/news_article_manager.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/universal/errors/error_display_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/universal/loading/loading_widget.dart';
import 'package:get_it/get_it.dart';

/// The NewsArticleScreen displays the full content of a selected news article.
/// 
/// This screen is designed to show the article's title, image, publication date, and
/// full content. It also includes error handling and refresh functionality to 
/// enhance user experience.
class NewsArticleScreen extends StatefulWidget {
  // Required fields to display the article.
  final String title; // The title of the news article.
  final String image; // The URL of the article's main image.
  final String articleUrl; // The URL to fetch the article content.

  // Constructor to initialize the widget with the required parameters.
  const NewsArticleScreen({
    required this.title,
    required this.image,
    required this.articleUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<NewsArticleScreen> createState() => _NewsArticleScreenState();
}

/// The state class for managing the article content and handling UI updates.
class _NewsArticleScreenState extends State<NewsArticleScreen> {
  // Manager for fetching article data using the GetIt dependency injection.
  final NewsArticleManager _newsArticleManager = GetIt.I<NewsArticleManager>();

  // List of widgets that represent the content of the article.
  List<Widget> _articleWidgets = [];

  // The publication date of the article, if available.
  String? _publishDate;

  // Error message to display in case fetching the article content fails.
  String? _errorMessage;

  // Loading state to indicate whether the content is being fetched.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Automatically fetch article content when the screen is initialized.
    _fetchArticleContent();
  }

  /// Fetches the article content from the provided URL.
  ///
  /// - [forceRefresh]: If `true`, forces a refresh to fetch the latest data from the server.
  Future<void> _fetchArticleContent({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true; // Update the state to show the loading indicator.
      _errorMessage = null; // Clear any previous error messages.
    });

    try {
      // Fetch the article content using the manager.
      final data = await _newsArticleManager.fetchArticleContent(
        widget.articleUrl,
        forceRefresh: forceRefresh,
      );

      // Update the state with the fetched content.
      setState(() {
        _publishDate = data['publishDate']; // Set the publication date.
        _articleWidgets = data['articleWidgets']; // Set the article content widgets.
      });
    } catch (e) {
      // Handle any errors using the ErrorHelper utility.
      ErrorHelper.handleError(e);

      setState(() {
        // Set the error message to display a user-friendly message to the user.
        _errorMessage = ErrorHelper.getErrorMessage(e);
      });
    } finally {
      // Stop the loading state regardless of success or failure.
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the app's theme to maintain a consistent UI design.
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar provides a consistent navigation and action bar.
      appBar: AppBar(
        title: Text(widget.title), // Display the title of the article in the AppBar.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh icon for reloading content.
            onPressed: () => _fetchArticleContent(forceRefresh: true), // Reload content on tap.
            tooltip: "Refresh Content", // Tooltip for accessibility.
          ),
        ],
      ),
      // Main body of the screen.
      body: _isLoading
          ? const LoadingWidget(
              title: "Loading Article",
              message: "Fetching the full article content. Please wait...",
            ) // Display a loading indicator while fetching the content.
          : _errorMessage != null
              ? ErrorDisplayWidget(
                  title: "Error Loading Article", // Title for the error message.
                  message: _errorMessage!, // Display the error message.
                  onRetry: () => _fetchArticleContent(forceRefresh: true), // Retry fetching on error.
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0), // Add consistent padding.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start.
                    children: [
                      // Display the article image if the URL is not empty.
                      if (widget.image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0), // Round the corners of the image.
                          child: CachedNetworkImage(
                            imageUrl: widget.image, // Load the image from the given URL.
                            fit: BoxFit.cover, // Ensure the image covers its container.
                            placeholder: (context, url) => const CircularProgressIndicator(), // Show a loading indicator while the image loads.
                            errorWidget: (context, url, error) => Icon(
                              Icons.broken_image, // Fallback icon for failed image loading.
                              size: 100, // Icon size.
                              color: theme.colorScheme.error, // Error color from the theme.
                            ),
                          ),
                        ),
                      const SizedBox(height: 16.0), // Add spacing below the image.
                      Text(
                        widget.title, // Display the title of the article.
                        style: theme.textTheme.headlineMedium, // Use headline style for the title.
                      ),
                      // Display the publication date if available.
                      if (_publishDate != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Published on: $_publishDate", // Show the publication date.
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6), // Dimmed text color.
                            ),
                          ),
                        ),
                      const Divider(), // Add a divider for visual separation.
                      // Display the article content if available.
                      if (_articleWidgets.isNotEmpty)
                        ..._articleWidgets // Spread operator to add content widgets dynamically.
                      else
                        const Text("No content available."), // Fallback text for empty content.
                    ],
                  ),
                ),
    );
  }
}
