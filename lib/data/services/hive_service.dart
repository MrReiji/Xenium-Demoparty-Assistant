import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// HiveService is responsible for initializing Hive for local storage.
/// 
/// This service provides a method to initialize Hive with the application's
/// document directory, ensuring that the local storage is set up correctly
/// for the app's use.
///
/// Methods:
/// - `initialize`: A static method that initializes Hive with the application's
///   document directory. This method should be called at the start of the
///   application to ensure Hive is properly set up.
///
/// The `getApplicationDocumentsDirectory` function is provided by the
/// path_provider package. It returns the directory where the application
/// can store files that are persistent and private to the app. This is
/// typically used for storing user-generated content or app-specific data.
class HiveService {
  /// Initializes Hive with the application's document directory.
  static Future<void> initialize() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    debugPrint("[HiveService] Hive initialized at ${appDocDir.path}");
  }
}

