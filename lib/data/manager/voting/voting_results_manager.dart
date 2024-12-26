import 'dart:convert';
import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/models/category_model.dart';
import 'package:demoparty_assistant/models/voting_entry_model.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:demoparty_assistant/utils/errors/error_helper.dart'; // Import ErrorHelper for handling errors.

/// Manages retrieval and caching of voting results and categories.
class VotingResultsManager {
  // Secure storage for user data (session cookies, etc.).
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Cache service for local storage of categories and voting entries.
  final CacheService _cacheService = GetIt.I<CacheService>();

  // Settings manager for checking configurations like caching.
  final SettingsManager _settingsManager = GetIt.I<SettingsManager>();

  // Base URL for the PartyMeister voting system.
  static const String partyBaseUrl = 'https://party.xenium.rocks';

  // Path for fetching voting categories.
  static const String categoriesPath = '/voting';

  // Cache keys for storing categories and voting entries.
  static const String categoriesCacheKey = 'voting_categories';
  static const String votingEntriesCachePrefix = 'voting_entries_';

  /// Retrieves the session cookie from secure storage.
  /// 
  /// - Throws an exception if the session cookie is missing or expired.
  Future<Map<String, String>> _getSessionHeaders() async {
    try {
      final sessionCookie = await _storage.read(key: 'session_cookie');
      if (sessionCookie == null || sessionCookie.isEmpty) {
        throw Exception("Session expired. Please log in again.");
      }
      debugPrint("[VotingResultsManager] Session cookie fetched successfully.");
      return {"Cookie": sessionCookie};
    } catch (error) {
      ErrorHelper.handleError(error); // Log and handle the error.
      throw Exception(ErrorHelper.getErrorMessage(error));
    }
  }

  /// Fetches the list of voting categories, with optional caching.
  /// 
  /// - [forceRefresh]: If true, bypasses cached data and fetches fresh data.
  /// - Returns a list of [Category] objects.
  Future<List<Category>> retrieveVotingCategories({bool forceRefresh = false}) async {
    final isCacheEnabled = await _settingsManager.isCacheEnabled();
    debugPrint("[VotingResultsManager] Cache enabled: $isCacheEnabled");

    // Attempt to fetch from cache if cache is enabled and refresh is not forced.
    if (isCacheEnabled && !forceRefresh) {
      try {
        final cachedCategories = _cacheService.getData(categoriesCacheKey);
        if (cachedCategories != null) {
          debugPrint("[VotingResultsManager] Returning cached categories.");
          final List<dynamic> decodedData = jsonDecode(cachedCategories);
          return decodedData.map((cat) => Category.fromJson(cat as Map<String, dynamic>)).toList();
        }
      } catch (error) {
        ErrorHelper.handleError(error); // Log cache-related errors silently.
      }
    }

    // Fetch categories from the server.
    final url = '$partyBaseUrl$categoriesPath';
    debugPrint("[VotingResultsManager] Fetching categories from: $url");

    try {
      final headers = await _getSessionHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        throw HttpException("Failed to load categories. Status code: ${response.statusCode}");
      }

      // Parse HTML response for categories using BeautifulSoup.
      final soup = BeautifulSoup(response.body);
      final categories = soup.findAll('li').where((li) {
        final ulParent = li.parent;
        return ulParent == null || !ulParent.classes.contains('nav') || !ulParent.classes.contains('navbar-nav');
      }).map((li) {
        final link = li.find('a');
        if (link == null) return null;
        final name = link.text.trim();
        final categoryUrl = '$partyBaseUrl${link.attributes['href']}';
        return Category(name: name, url: Uri.parse(categoryUrl));
      }).whereType<Category>().toList();

      // Cache the fetched categories if caching is enabled.
      if (isCacheEnabled) {
        await _cacheService.setData(categoriesCacheKey, jsonEncode(categories.map((cat) => cat.toJson()).toList()));
      }

      return categories;
    } catch (error) {
      ErrorHelper.handleError(error); // Log and handle server or parsing errors.
      throw Exception(ErrorHelper.getErrorMessage(error));
    }
  }

  /// Fetches voting data for a selected category, with optional caching.
  /// - [url]: The URL for the selected category.
  /// - [forceRefresh]: If true, bypasses cached data and fetches fresh data.
  /// - Returns a list of [VotingEntry] objects.
  Future<List<VotingEntry>> retrieveCategoryVotingResults(String url, {bool forceRefresh = false}) async {
    final isCacheEnabled = await _settingsManager.isCacheEnabled();
    final cacheKey = '$votingEntriesCachePrefix${Uri.parse(url).pathSegments.last}';

    // Attempt to fetch from cache if cache is enabled and refresh is not forced.
    if (isCacheEnabled && !forceRefresh) {
      try {
        final cachedEntries = _cacheService.getData(cacheKey);
        if (cachedEntries != null) {
          debugPrint("[VotingResultsManager] Returning cached voting entries for $url.");
          final List<dynamic> decodedData = jsonDecode(cachedEntries);
          return decodedData.map((entry) => VotingEntry.fromJson(entry as Map<String, dynamic>)).toList();
        }
      } catch (error) {
        ErrorHelper.handleError(error); // Log cache-related errors silently.
      }
    }
    // Fetch voting entries from the server.
    debugPrint("[VotingResultsManager] Fetching voting data for URL: $url");
    try {
      final headers = await _getSessionHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode != 200) {
        throw HttpException("Failed to load voting data. Status code: ${response.statusCode}");
      }
      // Parse HTML response for voting entries using BeautifulSoup.
      final soup = BeautifulSoup(response.body);
      final entries = soup.findAll('div', class_: 'thumbnail image').map((entry) {
        final rankText = entry.find('span', class_: 'label')?.text.replaceAll('#', '') ?? '0';
        final rank = int.tryParse(rankText) ?? 0;
        final title = entry.find('b')?.text ?? 'Unknown';
        final author = entry.find('p')?.text ?? 'Unknown';
        final imageUrl = '$partyBaseUrl${entry.find('img')?.attributes['src']}';
        return VotingEntry(rank: rank, title: title, author: author, imageUrl: Uri.parse(imageUrl));
      }).whereType<VotingEntry>().toList();

      // Cache the fetched voting entries if caching is enabled.
      if (isCacheEnabled) {
        await _cacheService.setData(cacheKey, jsonEncode(entries.map((entry) => entry.toJson()).toList()));
      }

      return entries;
    } catch (error) {
      ErrorHelper.handleError(error); // Log and handle server or parsing errors.
      throw Exception(ErrorHelper.getErrorMessage(error));
    }
  }

}
