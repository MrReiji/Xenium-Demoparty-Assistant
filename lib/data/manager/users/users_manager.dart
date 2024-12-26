import 'dart:convert';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

/// Manages the fetching and caching of user data from the website,
/// including country statistics calculation.
class UsersManager {
  final CacheService _cacheService = GetIt.I<CacheService>();
  final SettingsManager _settingsManager = GetIt.I<SettingsManager>();

  // Cache key for storing users data.
  static const String _cacheKey = 'users_list';

  /// Fetches the list of users and their associated country statistics.
  ///
  /// - [forceRefresh]: If true, bypasses the cache and fetches fresh data.
  ///
  /// Returns a map containing:
  /// - `users`: A list of user details (`name`, `country`, `countryCode`).
  /// - `countryStats`: A map of country names to the count of users from each country.
  Future<Map<String, dynamic>> fetchUsersWithStats({bool forceRefresh = false}) async {
    final isCacheEnabled = await _settingsManager.isCacheEnabled();

    // Attempt to retrieve data from the cache if enabled and not forcing refresh.
    if (isCacheEnabled && !forceRefresh) {
      final cachedUsers = _cacheService.getData(_cacheKey);
      if (cachedUsers != null) {
        debugPrint("[UsersManager] Returning cached users and statistics.");
        try {
          final decodedData = jsonDecode(cachedUsers);

          // Validate the structure of the cached data.
          if (decodedData is Map<String, dynamic> &&
              decodedData['users'] is List &&
              decodedData['countryStats'] is Map) {
            return {
              'users': List<Map<String, String>>.from(
                decodedData['users'].map((user) => Map<String, String>.from(user)),
              ),
              'countryStats': Map<String, int>.from(decodedData['countryStats']),
            };
          } else {
            debugPrint("[UsersManager] Cached data structure is invalid. Refetching.");
          }
        } catch (e) {
          debugPrint("[UsersManager] Error decoding cached data: $e");
        }
      }
    }

    debugPrint("[UsersManager] Fetching users from remote source.");
    final List<Map<String, String>> users = [];
    final Map<String, int> countryStats = {};

    try {
      // Fetch user data from the remote source.
      final response = await http.get(Uri.parse('https://party.xenium.rocks/visitors'));

      if (response.statusCode == 200) {
        final BeautifulSoup soup = BeautifulSoup(response.body);
        final userList = soup.find('ul', class_: 'list-unstyled');
        final userItems = userList?.findAll('li') ?? [];

        // Parse user details from the HTML response.
        for (var item in userItems) {
          final name = item.text.trim();
          final flagElement = item.find('i', class_: 'flag-');
          final countryCode = flagElement?.className.split('-').last ?? '';
          final countryName = flagElement?.attributes['title'] ?? '';

          if (name.isNotEmpty && countryName.isNotEmpty) {
            users.add({
              'name': name,
              'country': countryName,
              'countryCode': countryCode,
            });

            // Update country statistics.
            countryStats[countryName] = (countryStats[countryName] ?? 0) + 1;
          }
        }

        // Cache the fetched data if caching is enabled.
        if (isCacheEnabled) {
          await _cacheService.setData(
            _cacheKey,
            jsonEncode({
              'users': users,
              'countryStats': countryStats,
            }),
          );
          debugPrint("[UsersManager] Users data successfully cached.");
        }
      } else {
        throw Exception("Failed to fetch users. HTTP Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[UsersManager] Error fetching users: $e");
      rethrow;
    }

    return {
      'users': users,
      'countryStats': countryStats,
    };
  }
}
