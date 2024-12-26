import 'dart:convert'; // For JSON operations.
import 'package:flutter/services.dart'; // For loading assets.

/// Loads a JSON file from assets and returns it as a Dart object.
Future<dynamic> loadJson(String path) async {
  try {
    final String response = await rootBundle.loadString(path); // Load the file as a string.
    return json.decode(response); // Parse and return the JSON as a Map or List.
  } catch (e) {
    throw Exception("Error loading JSON from $path: $e"); // Handle errors.
  }
}



