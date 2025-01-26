import 'dart:convert';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/models/category_model.dart';
import 'package:demoparty_assistant/models/voting_entry_model.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

/// Manages the retrieval and caching of voting results and categories.
class VotingResultsManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final CacheService _cacheService = GetIt.I<CacheService>();
  final SettingsManager _settingsManager = GetIt.I<SettingsManager>();

  static const String _categoriesCacheKey = 'voting_categories';
  static const String _entriesCacheKeyPrefix = 'voting_entries_';

  /// Retrieves the session cookie from secure storage.
  ///
  /// Throws an exception if the session cookie is missing or expired.
  Future<Map<String, String>> _getHeaders() async {
    final sessionCookie = await _storage.read(key: 'session_cookie');
    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception("Session expired. Please log in again.");
    }
    debugPrint("[VotingResultsManager] Session cookie fetched successfully.");
    return {"Cookie": sessionCookie};
  }

  /// Fetches the list of voting categories, with optional caching.
  ///
  /// - [forceRefresh]: If true, bypasses the cache and fetches fresh data.
  ///
  /// Returns a list of [Category] objects.
  /// Throws an exception if the fetch operation fails.
  Future<List<Category>> fetchCategories({bool forceRefresh = false}) async {
    final isCacheEnabled = await _settingsManager.isCacheEnabled();
    debugPrint("[VotingResultsManager] Cache enabled: $isCacheEnabled");

    // Attempt to fetch from cache if available and not forcing refresh.
    if (isCacheEnabled && !forceRefresh) {
      final cachedCategories = _cacheService.getData(_categoriesCacheKey);
      if (cachedCategories != null) {
        debugPrint("[VotingResultsManager] Returning cached categories.");
        final List<dynamic> decodedData = jsonDecode(cachedCategories);
        return decodedData.map((cat) => Category.fromJson(cat as Map<String, dynamic>)).toList();
      }
    }

    const url = 'https://party.xenium.rocks/voting';
    debugPrint("[VotingResultsManager] Fetching categories from: $url");

    final headers = await _getHeaders();

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode != 200) {
        throw Exception("Failed to load categories. Status code: ${response.statusCode}");
      }

      final soup = BeautifulSoup(response.body);

      // Parse categories from HTML.
      final categories = soup.findAll('li').where((li) {
        final ulParent = li.parent;
        return ulParent == null || !ulParent.classes.contains('nav') || !ulParent.classes.contains('navbar-nav');
      }).map((li) {
        final link = li.find('a');
        if (link == null) return null;
        final name = link.text.trim();
        final url = 'https://party.xenium.rocks${link.attributes['href']}';
        return Category(name: name, url: Uri.parse(url));
      }).whereType<Category>().toList();

      // Cache the categories if caching is enabled.
      if (isCacheEnabled) {
        await _cacheService.setData(
          _categoriesCacheKey,
          jsonEncode(categories.map((cat) => cat.toJson()).toList()),
        );
      }

      return categories;
    } catch (e) {
      debugPrint("[VotingResultsManager] Error fetching categories: $e");
      rethrow;
    }
  }

  /// Fetches voting data for a selected category, with optional caching.
  ///
  /// - [url]: The URL of the category to fetch data from.
  /// - [forceRefresh]: If true, bypasses the cache and fetches fresh data.
  ///
  /// Returns a list of [VotingEntry] objects.
  /// Throws an exception if the fetch operation fails.
  Future<List<VotingEntry>> fetchVotingData(String url, {bool forceRefresh = false}) async {
    final isCacheEnabled = await _settingsManager.isCacheEnabled();
    final cacheKey = '$_entriesCacheKeyPrefix${Uri.parse(url).pathSegments.last}';

    // Attempt to fetch from cache if available and not forcing refresh.
    if (isCacheEnabled && !forceRefresh) {
      final cachedEntries = _cacheService.getData(cacheKey);
      if (cachedEntries != null) {
        debugPrint("[VotingResultsManager] Returning cached voting entries for $url.");
        final List<dynamic> decodedData = jsonDecode(cachedEntries);
        return decodedData.map((entry) => VotingEntry.fromJson(entry as Map<String, dynamic>)).toList();
      }
    }

    debugPrint("[VotingResultsManager] Fetching voting data for URL: $url");

    final headers = await _getHeaders();

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode != 200) {
        throw Exception("Failed to load voting data. Status code: ${response.statusCode}");
      }

      final soup = BeautifulSoup(response.body);

      // Parse voting entries from HTML.
      final entries = soup.findAll('div', class_: 'thumbnail image').map((entry) {
        final rankText = entry.find('span', class_: 'label')?.text?.replaceAll('#', '') ?? '0';
        final rank = int.parse(rankText);
        final title = entry.find('b')?.text ?? 'Unknown';
        final author = entry.find('p')?.text ?? 'Unknown';
        final imageUrl = entry.find('img')?.attributes['src'] ?? '';
        return VotingEntry(
          rank: rank,
          title: title,
          author: author,
          imageUrl: Uri.parse('https://party.xenium.rocks$imageUrl'),
        );
      }).whereType<VotingEntry>().toList();

      // Cache the entries if caching is enabled.
      if (isCacheEnabled) {
        await _cacheService.setData(
          cacheKey,
          jsonEncode(entries.map((entry) => entry.toJson()).toList()),
        );
      }

      return entries;
    } catch (e) {
      debugPrint("[VotingResultsManager] Error fetching voting data: $e");
      rethrow;
    }
  }
}
