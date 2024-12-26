import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:demoparty_assistant/views/widgets/html_based/custom_list_widget.dart';
import 'package:demoparty_assistant/views/widgets/html_based/image_grid_widget.dart';
import 'package:demoparty_assistant/views/widgets/html_based/text_column_widget.dart';
import 'package:demoparty_assistant/utils/errors/error_helper.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

/// A manager responsible for fetching, caching, and processing HTML content from a given URL.
///
/// Features:
/// - Fetches HTML content from a given URL.
/// - Parses the HTML to generate widgets.
/// - Caches fetched data for improved performance.
class GenericContentManager {
  // Dependencies for cache handling and settings management
  final CacheService _cacheService =
      GetIt.I<CacheService>(); // Manages cached data.
  final SettingsManager _settingsManager =
      GetIt.I<SettingsManager>(); // Handles application settings.

  /// Fetches content for a specified URL.
  ///
  /// This function uses caching when enabled and parses the HTML content to create a list of widgets.
  ///
  /// - [url]: The target URL to fetch content from.
  /// - [forceRefresh]: If true, bypasses the cache and fetches fresh content.
  ///
  /// Returns a list of widgets constructed based on the parsed HTML.
  Future<List<Widget>> fetchContent(String url,
      {bool forceRefresh = false}) async {
    final isCacheEnabled =
        await _settingsManager.isCacheEnabled(); // Check if caching is enabled.
    debugPrint(
        "[GenericContentManager] Fetching content for URL: $url | Force refresh: $forceRefresh | Cache enabled: $isCacheEnabled");

    try {
      // Attempt to load cached data if caching is enabled and refresh is not forced.
      if (isCacheEnabled && !forceRefresh) {
        final cachedHtml = _cacheService.getData(url); // Retrieve cached data.
        if (cachedHtml != null) {
          debugPrint(
              "[GenericContentManager] Returning cached HTML content for URL: $url");
          return _parseHtmlInOrder(BeautifulSoup(cachedHtml),
              isCacheEnabled: true); // Parse the cached HTML.
        }
      }

      // Fetch fresh data from the network if cache is unavailable or disabled.
      final response = await fetchHtmlContent(url);
      if (response != null) {
        final soup = BeautifulSoup(response); // Parse the raw HTML content.

        // Cache the response data if caching is enabled.
        if (isCacheEnabled) {
          await _cacheService.setData(url, response);
        }

        return _parseHtmlInOrder(soup,
            isCacheEnabled: isCacheEnabled); // Parse and return widgets.
      } else {
        throw Exception(
            "Failed to fetch content for $url: No response received.");
      }
    } catch (e) {
      // Handle errors and rethrow them with user-friendly messages.
      ErrorHelper.handleError(e);
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
  }

  /// Fetches raw HTML content from the specified URL.
  ///
  /// - [url]: The target URL to fetch HTML content from.
  ///
  /// Returns the raw HTML content as a string or throws an exception on failure.
  Future<String?> fetchHtmlContent(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)); // Perform an HTTP GET request.
      debugPrint(
          "[GenericContentManager] HTTP status for $url: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response
            .body; // Return the response body if the request was successful.
      } else {
        throw HttpException(
            "HTTP ${response.statusCode}: Failed to fetch content from $url"); // Throw an exception for non-200 responses.
      }
    } on http.ClientException catch (e) {
      // Handle network errors specifically.
      throw SocketException("Network error occurred: $e");
    } catch (e) {
      // Handle unexpected errors.
      throw Exception("Unexpected error occurred while fetching $url: $e");
    }
  }

  /// Parses HTML content to create a list of widgets based on its structure.
  ///
  /// This function identifies specific classes or elements in the HTML and generates corresponding widgets.
  ///
  /// - [soup]: The parsed HTML document.
  /// - [isCacheEnabled]: A flag indicating if caching is enabled for this session.
  ///
  /// Returns a list of widgets built from the parsed HTML content.
  List<Widget> _parseHtmlInOrder(BeautifulSoup soup,
      {required bool isCacheEnabled}) {
    try {
      List<Widget> widgets = []; // List to store generated widgets.
      final elements =
          soup.findAll('div'); // Find all <div> elements in the HTML.

      for (var element in elements) {
        final className =
            element.attributes['class'] ?? ''; // Get the class attribute.
        if (className.contains('wpb_text_column')) {
          widgets.add(TextColumnWidget(content: element));
        } else if (className.contains('row portfolio-items') ||
            className.contains('flickity-viewport')) {
          final imageUrls = _extractImageUrls(element);
          widgets.add(ImageGridWidget(
            images: isCacheEnabled ? _fetchOrCacheImages(imageUrls) : imageUrls,
          ));
        } else if (element.find('ul') != null) {
          // Handle unordered lists inside the HTML.
          final ulElement = element.find('ul', class_: 'wpb_wrapper');
          if (ulElement != null) {
            widgets.add(CustomListWidget(content: ulElement));
          }
        }
      }

      if (widgets.isEmpty) {
        // Throw an exception if no valid widgets are generated.
        throw Exception(
            "The parsed content contains no valid sections to display.");
      }

      return widgets; // Return the list of generated widgets.
    } catch (e) {
      // Handle errors during parsing and rethrow with user-friendly messages.
      ErrorHelper.handleError(e);
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
  }

  /// Extracts image URLs from an HTML element.
  ///
  /// This function scans for <img> tags within a given element and collects their `src` attributes.
  ///
  /// - [element]: The HTML element to extract image URLs from.
  ///
  /// Returns a list of image URLs or throws an exception on failure.
  List<String> _extractImageUrls(Bs4Element element) {
    try {
      return element
          .findAll('img') // Find all <img> elements.
          .map((img) =>
              img.attributes['src'] ?? '') // Extract the `src` attribute.
          .where((src) => src.isNotEmpty) // Filter out empty URLs.
          .toList();
    } catch (e) {
      // Handle errors during image extraction.
      throw Exception(
          "Failed to extract image URLs: ${ErrorHelper.getErrorMessage(e)}");
    }
  }

  /// Fetches cached images or returns raw URLs if caching is disabled.
  ///
  /// This function retrieves cached images when available or falls back to raw image URLs.
  ///
  /// - [imageUrls]: A list of image URLs to fetch or cache.
  ///
  /// Returns a list of either cached images or raw URLs.
  List<dynamic> _fetchOrCacheImages(List<String> imageUrls) {
    try {
      return imageUrls.map((url) {
        final cachedImage = _cacheService
            .getImage(url); // Retrieve the cached image if available.
        return cachedImage ?? url; // Return the cached image or the raw URL.
      }).toList();
    } catch (e) {
      // Handle errors during image fetching or caching.
      throw Exception(
          "Failed to retrieve cached images: ${ErrorHelper.getErrorMessage(e)}");
    }
  }
}
