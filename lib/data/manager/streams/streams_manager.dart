import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:demoparty_assistant/utils/errors/error_helper.dart';

/// Manages live and archived streams by fetching and parsing metadata.
class StreamsManager {
  // Base URLs for live and archive streams.
  static const String liveStreamUrl = 'https://scenesat.com/video/1';
  static const String archiveStreamsUrl = 'https://scenesat.com/videoarchive';

  /// Fetches metadata for the live stream.
  ///
  /// Returns:
  /// - A map containing:
  ///   - `title`: Title of the live stream.
  ///   - `description`: Description of the live stream.
  ///   - `url`: Video URL of the live stream.
  ///
  /// Throws:
  /// - An exception with a user-friendly message if the fetch fails or metadata is missing.
  Future<Map<String, String>?> fetchLiveStream() async {
    try {
      final response = await http.get(Uri.parse(liveStreamUrl));

      if (response.statusCode == 200) {
        final BeautifulSoup soup = BeautifulSoup(response.body);

        // Extract metadata from the HTML response.
        final title = soup.find('meta', attrs: {'property': 'og:title'})?.attributes['content'];
        final description = soup.find('meta', attrs: {'property': 'og:description'})?.attributes['content'];
        final videoElement = soup.find('video', class_: 'fp-engine');
        final videoUrl = videoElement?.attributes['src'];

        if (title != null && description != null && videoUrl != null) {
          // Remove the `blob:` prefix if present in the video URL.
          final resolvedUrl = videoUrl.startsWith('blob:') ? videoUrl.substring(5) : videoUrl;

          return {
            'title': title,
            'description': description,
            'url': resolvedUrl,
          };
        }
      } else {
        // Handle non-200 HTTP status codes.
        final errorMessage =
            '[StreamsManager] Failed to fetch live stream: HTTP ${response.statusCode}';
        debugPrint(errorMessage);
        throw HttpException(ErrorHelper.getErrorMessage(HttpException(errorMessage)));
      }
    } catch (e) {
      // Handle other exceptions using ErrorHelper.
      debugPrint('[StreamsManager] Error fetching live stream: $e');
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
    return null; // Return `null` if the required metadata is not found.
  }

  /// Fetches metadata for archived streams.
  ///
  /// Returns:
  /// - A list of maps, each containing:
  ///   - `title`: Title of the archived stream.
  ///   - `date`: Date the stream was recorded.
  ///   - `duration`: Duration of the stream.
  ///   - `url`: Video URL of the archived stream.
  ///
  /// Throws:
  /// - An exception with a user-friendly message if the fetch fails or no valid data is found.
  Future<List<Map<String, String>>> fetchArchiveStreams() async {
    List<Map<String, String>> streams = [];
    try {
      final response = await http.get(Uri.parse(archiveStreamsUrl));

      if (response.statusCode == 200) {
        final BeautifulSoup soup = BeautifulSoup(response.body);
        final streamElements = soup.findAll('div', class_: 'row');

        for (var element in streamElements) {
          // Extract metadata for each stream entry.
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

            // Add the stream if no duplicate exists based on title and URL.
            if (!streams.any((s) =>
                s['title']?.toLowerCase() == stream['title']?.toLowerCase() &&
                s['url'] == stream['url'])) {
              streams.add(stream);
            }
          }
        }
      } else {
        // Handle non-200 HTTP status codes.
        final errorMessage =
            '[StreamsManager] Failed to fetch archive streams: HTTP ${response.statusCode}';
        debugPrint(errorMessage);
        throw HttpException(ErrorHelper.getErrorMessage(HttpException(errorMessage)));
      }
    } catch (e) {
      // Handle other exceptions using ErrorHelper.
      debugPrint('[StreamsManager] Error fetching archive streams: $e');
      throw Exception(ErrorHelper.getErrorMessage(e));
    }
    return streams; // Return the list of archived streams.
  }
}
