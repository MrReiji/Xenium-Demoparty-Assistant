import 'dart:convert';
import 'package:flutter/services.dart';

/// Generic function to load and parse JSON from assets.
/// 
/// - [path]: The path to the JSON file in the assets folder.
/// 
/// Returns a dynamic object (either a `List` or `Map`).
Future<dynamic> loadJson(String path) async {
  try {
    final String response = await rootBundle.loadString(path);
    return json.decode(response);
  } catch (e) {
    throw Exception("Error loading JSON from $path: $e");
  }
}
