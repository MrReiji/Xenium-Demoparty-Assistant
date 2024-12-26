import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/models/news_model.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Manager responsible for fetching and managing news articles.
/// Handles data retrieval from remote sources, caching, and error management.
class NewsManager {
  // Dependency injection for cache and settings services.
  final CacheService _cacheService = GetIt.I<CacheService>();
  final SettingsManager _settingsManager = GetIt.I<SettingsManager>();

  // Base URL for fetching news articles.
  static const String _baseUrl = 'https://2024.xenium.rocks/category/wiesci';

  // Cache key used for storing and retrieving cached news data.
  static const String _cacheKey = 'news_list';

  /// Fetches a list of news articles from a remote source.
  ///
  /// - [forceRefresh]: If set to true, bypasses the cache and fetches fresh data.
  ///
  /// Returns a [Future] that resolves to a list of [NewsModel] instances.
  /// Throws an [Exception] if data retrieval fails.
  Future<List<NewsModel>> fetchNews({bool forceRefresh = false}) async {
    // Check if caching is enabled through settings.
    final bool isCacheEnabled = await _settingsManager.isCacheEnabled();

    try {
      // Attempt to retrieve cached data if caching is enabled and refresh is not forced.
      if (isCacheEnabled && !forceRefresh) {
        final dynamic cachedData = _cacheService.getData(_cacheKey);
        if (cachedData != null) {
          debugPrint("[NewsManager] Returning cached news.");
          return (cachedData as List)
              .map((json) => NewsModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      debugPrint("[NewsManager] Fetching news from remote source.");
      final List<NewsModel> newsList = [];
      int page = 1;

      // Loop through paginated news pages until no more articles are found.
      while (true) {
        final String url = '$_baseUrl/page/$page/';

        try {
          final http.Response response = await http.get(Uri.parse(url));

          // Check for HTTP success status.
          if (response.statusCode != 200) {
            debugPrint(
                "[NewsManager] Received status code \${response.statusCode} for URL: $url. Stopping pagination.");
            break;
          }

          final BeautifulSoup soup = BeautifulSoup(response.body);
          final List<Bs4Element> articles =
              soup.findAll('article', class_: 'masonry-blog-item');

          // Exit the loop if no articles are found on the current page.
          if (articles.isEmpty) {
            debugPrint(
                "[NewsManager] No articles found on page $page. Ending pagination.");
            break;
          }

          // Process each article and add it to the news list.
          for (var article in articles) {
            final String title =
                article.find('h3', class_: 'title')?.text.trim() ?? 'No title';
            final String articleUrl =
                article.find('a', class_: 'entire-meta-link')?.attributes['href'] ??
                    '';
            final String imageUrl =
                article.find('span', class_: 'post-featured-img')?.find('img')
                        ?.attributes['src'] ??
                    '';
            final List<String> categories = article
                .findAll('span', class_: 'meta-category')
                .expand((span) => span.findAll('a').map((a) => a.text.trim()))
                .toList();
            final String content =
                article.find('p', class_: 'excerpt')?.text ?? '';

            newsList.add(NewsModel(
              title: title,
              content: content,
              imageUrl: imageUrl,
              articleUrl: articleUrl,
              categories: categories,
            ));
          }

          debugPrint(
              "[NewsManager] Processed page $page with \${articles.length} articles.");
          page++;
        } catch (e) {
          // Handle errors specific to each page.
          ErrorHelper.handleError(e);
          debugPrint(
              "[NewsManager] Error occurred while processing page $page: \${e.toString()}.");
          break; // Stop pagination on error.
        }
      }

      // Cache the fetched data if caching is enabled.
      if (isCacheEnabled) {
        await _cacheService.setData(
          _cacheKey,
          newsList.map((news) => news.toJson()).toList(),
        );
        debugPrint("[NewsManager] Cached \${newsList.length} news articles.");
      }

      return newsList;
    } catch (e) {
      // Handle general errors during the news fetching process.
      ErrorHelper.handleError(e);
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
  }
}
