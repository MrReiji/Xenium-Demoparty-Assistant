import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:get_it/get_it.dart';
import '../manager/settings/settings_manager.dart';

/// Manages caching of data and images using Hive.
class CacheService {
  late Box<dynamic> _dataBox;
  late Box<dynamic> _imageBox;

  // Default Time-to-Live (TTL) in seconds.
  int _defaultTTL = 3600;

  // Access to settings manager for cache-related configurations.
  final SettingsManager _settingsManager = GetIt.I<SettingsManager>();

  /// Initializes Hive boxes for caching data and images.
  Future<void> initialize() async {
    debugPrint("[CacheService] Initializing cache boxes...");
    _dataBox = await Hive.openBox('global_cache');
    _imageBox = await Hive.openBox('images_cache');
    debugPrint("[CacheService] Cache boxes initialized: global_cache and images_cache.");
  }

  /// Retrieves the current global TTL.
  int getCurrentTTL() => _defaultTTL;

  /// Sets the global TTL for all cache entries.
  Future<void> setGlobalTTL(int ttl) async {
    _defaultTTL = ttl;
    await _updateTTL(_dataBox, ttl);
    await _updateTTL(_imageBox, ttl);
    debugPrint("[CacheService] Global TTL set to $ttl seconds.");
  }

  /// Updates the TTL for all entries in the specified cache box.
  Future<void> _updateTTL(Box<dynamic> box, int ttl) async {
    for (final key in box.keys) {
      final cachedItem = box.get(key);
      if (cachedItem is Map) {
        cachedItem['expiry'] = DateTime.now()
            .add(Duration(seconds: ttl))
            .toIso8601String();
        await box.put(key, cachedItem);
      }
    }
  }

  /// Clears all data and image cache entries.
  Future<void> clearAllCache() async {
    await _dataBox.clear();
    await _imageBox.clear();
    debugPrint("[CacheService] All caches cleared.");
  }

  /// Checks if caching is enabled based on user settings.
  Future<bool> isCacheEnabled() async {
    return await _settingsManager.isCacheEnabled();
  }

  /// Retrieves cached data or fetches fresh data using the provided fetcher function.
  Future<dynamic> getDataOrFetch(String key, Future<dynamic> Function() fetcher) async {
    if (await isCacheEnabled()) {
      final cachedData = getData(key);
      if (cachedData != null) {
        debugPrint("[CacheService] Returning cached data for key: $key");
        return cachedData;
      }
    }

    debugPrint("[CacheService] Fetching fresh data for key: $key");
    final data = await fetcher();
    if (await isCacheEnabled()) {
      await setData(key, data);
    }
    return data;
  }

  /// Retrieves cached data for the specified key.
  dynamic getData(String key) {
    final cachedItem = _dataBox.get(key);
    if (cachedItem != null && !_isExpired(cachedItem['expiry'])) {
      return cachedItem['data'];
    }
    _dataBox.delete(key); // Remove expired data.
    return null;
  }

  /// Stores data in the cache with an optional custom TTL.
  Future<void> setData(String key, dynamic value, [int? ttl]) async {
    final expiry = DateTime.now()
        .add(Duration(seconds: ttl ?? _defaultTTL))
        .toIso8601String();
    await _dataBox.put(key, {'data': value, 'expiry': expiry});
  }

  /// Retrieves a cached image for the specified key.
  Uint8List? getImage(String key) {
    final cachedItem = _imageBox.get(key);
    if (cachedItem != null && !_isExpired(cachedItem['expiry'])) {
      return cachedItem['data'];
    }
    _imageBox.delete(key); // Remove expired image.
    return null;
  }

  /// Fetches an image, either from the cache or the network.
  Future<Uint8List?> fetchImage(String url, [int? ttl]) async {
    final cachedImage = getImage(url);
    if (cachedImage != null) {
      return cachedImage;
    }
    return await cacheImage(url, ttl);
  }

  /// Caches an image fetched from the provided URL.
  Future<Uint8List?> cacheImage(String url, [int? ttl]) async {
    if (!_shouldCacheImage(url)) {
      debugPrint("[CacheService] Skipping caching for irrelevant image: $url");
      return null;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        final compressedData = compressImage(imageData);
        final expiry = DateTime.now()
            .add(Duration(seconds: ttl ?? _defaultTTL))
            .toIso8601String();
        await _imageBox.put(url, {'data': compressedData, 'expiry': expiry});
        debugPrint("[CacheService] Image cached successfully for URL: $url");
        return compressedData;
      } else {
        debugPrint("[CacheService] Failed to fetch image. HTTP status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[CacheService] Error fetching image: $e");
    }
    return null;
  }

  /// Determines whether an image should be cached based on its URL.
  bool _shouldCacheImage(String url) {
    final excludedPatterns = ['/plugins/'];
    return !excludedPatterns.any((pattern) => url.toLowerCase().contains(pattern));
  }

  /// Compresses an image to reduce storage size while maintaining quality.
  Uint8List compressImage(Uint8List imageData) {
    final image = img.decodeImage(imageData);
    if (image != null) {
      return Uint8List.fromList(img.encodeJpg(image, quality: 80));
    }
    debugPrint("[CacheService] Failed to compress image.");
    return imageData;
  }

  /// Checks if a cached item has expired.
  bool _isExpired(String? expiry) {
    return expiry != null && DateTime.now().isAfter(DateTime.parse(expiry));
  }

  /// Removes a specific key from the cache.
  Future<void> removeKey(String key) async {
    if (_dataBox.containsKey(key)) {
      await _dataBox.delete(key);
      debugPrint("[CacheService] Key removed from data cache: $key");
    }
    if (_imageBox.containsKey(key)) {
      await _imageBox.delete(key);
      debugPrint("[CacheService] Key removed from image cache: $key");
    }
  }
}
