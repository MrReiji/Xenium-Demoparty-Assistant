import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:demoparty_assistant/utils/errors/error_helper.dart';

/// A manager responsible for handling live and archived streams.
/// Provides methods to fetch live stream metadata and archived stream details.
class StreamsManager {
  /// Fetches live stream metadata from the specified URL.
  ///
  /// Returns a map containing:
  /// - `title`: The title of the live stream.
  /// - `description`: A description of the live stream.
  /// - `url`: The URL of the live stream video.
  ///
  /// Returns `null` if the required data is not available or an error occurs.
  Future<Map<String, String>?> fetchLiveStream() async {
    try {
      final response = await http.get(Uri.parse('https://scenesat.com/video/1'));

      if (response.statusCode == 200) {
        final BeautifulSoup soup = BeautifulSoup(response.body);

        // Extract metadata from the HTML response.
        final title = soup.find('meta', attrs: {'property': 'og:title'})?.attributes['content'];
        final description = soup.find('meta', attrs: {'property': 'og:description'})?.attributes['content'];
        final videoElement = soup.find('video', class_: 'fp-engine');
        final videoUrl = videoElement?.attributes['src'];

        if (title != null && description != null && videoUrl != null) {
          // Handle `blob:` prefix in video URLs if present.
          final resolvedUrl = videoUrl.startsWith('blob:') ? videoUrl.substring(5) : videoUrl;

          return {
            'title': title,
            'description': description,
            'url': resolvedUrl,
          };
        }
      } else {
        debugPrint('[StreamsManager] Failed to fetch live stream: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[StreamsManager] Error fetching live stream: $e');
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
    return null;
  }

  /// Fetches archived stream metadata from the specified URL.
  ///
  /// Returns a list of maps, each containing:
  /// - `title`: The title of the archived stream.
  /// - `date`: The date the stream was recorded.
  /// - `duration`: The duration of the stream.
  /// - `url`: The URL of the archived stream video.
  ///
  /// Duplicates are filtered based on title and URL.
  Future<List<Map<String, String>>> fetchArchiveStreams() async {
    List<Map<String, String>> streams = [];
    try {
      final response = await http.get(Uri.parse('https://scenesat.com/videoarchive'));

      if (response.statusCode == 200) {
        final BeautifulSoup soup = BeautifulSoup(response.body);
        final streamElements = soup.findAll('div', class_: 'row');

        for (var element in streamElements) {
          // Extract individual stream metadata.
          final titleElement = element.find('dd');
          final dateElement = element.find('dt');
          final urlElement = element.find('span', class_: 'playersrc')?.attributes['data-url'];

          if (titleElement != null && dateElement != null && urlElement != null) {
            final stream = {
              'title': titleElement.text.trim(),
              'date': dateElement.text.split('[').first.trim(),
              'duration': dateElement.text.split('[').last.replaceAll(']', '').trim(),
              'url': urlElement,
            };

            // Avoid duplicate entries based on title and URL.
            if (!streams.any((s) => s['title']?.toLowerCase() == stream['title']?.toLowerCase() && s['url'] == stream['url'])) {
              streams.add(stream);
            }
          }
        }
      } else {
        debugPrint('[StreamsManager] Failed to fetch archive streams: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[StreamsManager] Error fetching archive streams: $e');
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
    return streams;
  }
}
