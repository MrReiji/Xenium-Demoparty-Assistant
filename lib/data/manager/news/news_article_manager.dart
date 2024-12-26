import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:demoparty_assistant/views/widgets/video/universal_video_player.dart';
import 'package:demoparty_assistant/views/widgets/html_based/text_column_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Manager responsible for fetching and processing news article content.
/// Supports caching, error handling, and dynamic widget generation based on content structure.
class NewsArticleManager {
  final CacheService _cacheService = GetIt.I<CacheService>();

  /// Fetches the full content of a news article from the specified URL.
  ///
  /// - [articleUrl]: The URL of the article to fetch.
  /// - [forceRefresh]: If true, skips cache and fetches fresh content from the network.
  /// Returns a map containing the article's publication date and content widgets.
  Future<Map<String, dynamic>> fetchArticleContent(String articleUrl,
      {bool forceRefresh = false}) async {
    try {
      // Check cache if forceRefresh is not requested
      if (!forceRefresh) {
        final cachedData = _cacheService.getData(articleUrl);
        if (cachedData != null) {
          debugPrint("[NewsArticleManager] Returning cached content for $articleUrl");
          return Map<String, dynamic>.from(cachedData);
        }
      }

      // Fetch article content from the network
      debugPrint("[NewsArticleManager] Fetching content for $articleUrl.");
      final response = await http.get(Uri.parse(articleUrl));

      if (response.statusCode == 200) {
        final soup = BeautifulSoup(response.body);

        // Extract relevant content from the HTML
        String? publishDate = soup.find('span', class_: 'meta-date')?.text.trim();
        String? contentInnerHtml = soup.find('div', class_: 'post-content')?.outerHtml;
        String? videoUrl = soup.find('iframe')?.attributes['src'];

        final data = {
          'publishDate': publishDate,
          'contentInnerHtml': contentInnerHtml,
          'videoUrl': videoUrl,
        };

        // Cache the fetched data
        await _cacheService.setData(articleUrl, data);

        // Generate article widgets for UI rendering
        return {
          'publishDate': publishDate,
          'articleWidgets': _generateArticleWidgets(
            contentInnerHtml: contentInnerHtml,
            videoUrl: videoUrl,
          ),
        };
      } else {
        throw HttpException(
            "HTTP ${response.statusCode}: Failed to fetch content for $articleUrl");
      }
    } catch (e) {
      // Handle and log errors using the error helper
      ErrorHelper.handleError(e);
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
  }

  /// Generates a list of widgets for a news article based on the content structure.
  ///
  /// - [contentInnerHtml]: The HTML content of the article.
  /// - [videoUrl]: The URL of an embedded video, if available.
  /// Returns a list of widgets to render the article content.
  List<Widget> _generateArticleWidgets({
    required String? contentInnerHtml,
    required String? videoUrl,
  }) {
    List<Widget> articleWidgets = [];

    // Check if content is available; otherwise, display a fallback message.
    if (contentInnerHtml == null) {
      debugPrint("[NewsArticleManager] Warning: 'contentInnerHtml' is null.");
      articleWidgets.add(const Text("No content available."));
      return articleWidgets;
    }

    // Parse the HTML content
    final contentInner = BeautifulSoup(contentInnerHtml);

    // Create a TextColumnWidget for displaying the main article text
    final textColumnWidget = TextColumnWidget(content: contentInner.body!);
    articleWidgets.add(textColumnWidget);

    // Add an embedded video player if a video URL is available
    if (videoUrl != null) {
      articleWidgets.insert(
        0,
        UniversalVideoPlayer(
          videoUrl: videoUrl,
          isEmbedded: true,
        ),
      );
    }

    return articleWidgets;
  }
}
