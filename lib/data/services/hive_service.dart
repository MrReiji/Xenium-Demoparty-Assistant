import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// HiveService is responsible for initializing Hive for local storage.
class HiveService {
  /// Initializes Hive with the application's document directory.
  static Future<void> initialize() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    debugPrint("[HiveService] Hive initialized at ${appDocDir.path}");
  }
}
