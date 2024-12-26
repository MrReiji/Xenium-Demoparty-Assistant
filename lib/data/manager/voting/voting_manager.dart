import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:demoparty_assistant/utils/errors/error_helper.dart'; // Import ErrorHelper for handling errors.

/// Manages voting-related operations, including fetching voting data
/// and opening the voting tool in the browser.
class VotingManager {
  // URL for fetching live voting data from the PartyMeister system.
  static const String liveVotingDataUrl = 'https://party.xenium.rocks/pm_competition/vote/live';

  // URL for opening the voting page in a browser.
  static const String votingWebPageUrl = 'https://party.xenium.rocks/frontend/default/en/voting/live';

  // Secure storage instance for retrieving session cookies.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Retrieves the session cookie from secure storage and prepares request headers.
  ///
  /// Throws an exception if the session cookie is missing or expired.
  Future<Map<String, String>> _getSessionHeaders() async {
    try {
      final sessionCookie = await _storage.read(key: 'session_cookie');
      if (sessionCookie == null || sessionCookie.isEmpty) {
        throw Exception("Session expired. Please log in again.");
      }
      return {"Cookie": sessionCookie};
    } catch (error) {
      ErrorHelper.handleError(error);
      throw Exception(ErrorHelper.getErrorMessage(error));
    }
  }

  /// Fetches competition and voting entries data from the server.
  ///
  /// Returns a map containing:
  /// - `competition`: Information about the competition.
  /// - `entries`: A list of formatted entries with titles and positions.
  ///
  /// Throws an exception if the fetch fails or the server responds with an error.
  Future<Map<String, dynamic>> fetchLiveVotingEntries() async {
    try {
      final headers = await _getSessionHeaders();
      final response = await http.get(Uri.parse(liveVotingDataUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final competition = data['competition'];
        final entries = (data['entries'] as List<dynamic>).map((entry) {
          return {
            "title": entry['name'] ?? "Unknown",
            "position": "#${entry['sort_position'] ?? 'No Position'}",
          };
        }).toList();

        return {
          "competition": competition,
          "entries": entries,
        };
      } else {
        throw HttpException("Failed to fetch voting data (HTTP ${response.statusCode})");
      }
    } catch (error) {
      ErrorHelper.handleError(error);
      throw Exception(ErrorHelper.getErrorMessage(error));
    }
  }

  /// Opens the voting tool URL in the default browser.
  ///
  /// Throws an exception if the URL cannot be launched.
  Future<void> launchVotingWebPage() async {
    try {
      final Uri votingUri = Uri.parse(votingWebPageUrl);

      if (await canLaunchUrl(votingUri)) {
        await launchUrl(votingUri);
      } else {
        throw Exception("Could not launch $votingWebPageUrl");
      }
    } catch (error) {
      ErrorHelper.handleError(error);
      throw Exception(ErrorHelper.getErrorMessage(error));
    }
  }
}
