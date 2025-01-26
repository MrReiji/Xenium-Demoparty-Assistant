import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Manages voting-related operations, including fetching voting data
/// and opening the voting tool in the browser.
class VotingManager {
  // Endpoint for fetching live voting data.
  static const String votingEndpoint = 'https://party.xenium.rocks/pm_competition/vote/live';
  
  // URL for opening the voting page.
  static const String votingPageUrl = 'https://party.xenium.rocks/frontend/default/en/voting/live';

  // Secure storage instance for retrieving session cookies.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Retrieves the session cookie from secure storage and prepares request headers.
  ///
  /// Throws an exception if the session cookie is missing or expired.
  Future<Map<String, String>> _getHeaders() async {
    final sessionCookie = await _storage.read(key: 'session_cookie');
    if (sessionCookie == null || sessionCookie.isEmpty) {
      throw Exception("Session expired. Please log in again.");
    }
    return {"Cookie": sessionCookie};
  }

  /// Fetches competition and voting entries data from the server.
  ///
  /// Returns a map containing:
  /// - `competition`: Information about the competition.
  /// - `entries`: A list of formatted entries with titles and positions.
  ///
  /// Throws an exception if the fetch fails or the server responds with an error.
  Future<Map<String, dynamic>> fetchVotingData() async {
    final headers = await _getHeaders();

    try {
      final response = await http.get(Uri.parse(votingEndpoint), headers: headers);

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
        throw Exception("Failed to fetch voting data (HTTP ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching voting data: $e");
    }
  }

  /// Opens the voting tool URL in the default browser.
  ///
  /// Throws an exception if the URL cannot be launched.
  Future<void> openVotingTool() async {
    final Uri votingUri = Uri.parse(votingPageUrl);

    if (await canLaunchUrl(votingUri)) {
      await launchUrl(votingUri);
    } else {
      throw Exception("Could not launch $votingPageUrl");
    }
  }
}
