import 'package:demoparty_assistant/data/manager/news/news_article_manager.dart';
import 'package:demoparty_assistant/data/manager/news/news_manager.dart';
import 'package:demoparty_assistant/data/manager/time_table/time_table_manager.dart';
import 'package:demoparty_assistant/data/manager/voting/voting_manager.dart';
import 'package:demoparty_assistant/data/manager/voting/voting_results_manager.dart';
import 'package:demoparty_assistant/data/services/hive_service.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:demoparty_assistant/data/services/notification_service.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:demoparty_assistant/data/services/native_calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// A core service initializer responsible for setting up all
/// required services, managers, and repositories using the GetIt locator.
final GetIt locator = GetIt.instance;

class ServiceCore {
  /// Initializes the core services and dependencies of the application.
  ///
  /// This includes setting up Hive for local storage, registering all managers
  /// and services in the [locator], and ensuring all services are ready.
  static Future<void> initialize() async {
    debugPrint("[ServiceCore] Starting initialization...");

    // Initialize timezone data.
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
    debugPrint("[ServiceCore] Timezones initialized and local set to 'Europe/Warsaw'.");

    // Initialize Hive for local storage.
    debugPrint("[ServiceCore] Initializing Hive...");
    await HiveService.initialize();
    debugPrint("[ServiceCore] Hive initialized.");

    // Register SettingsManager first, as it is a dependency for CacheService.
    locator.registerLazySingleton(() => SettingsManager());
    debugPrint("[ServiceCore] SettingsManager registered.");

    // Initialize CacheService and register it.
    final cacheService = CacheService();
    await cacheService.initialize();
    locator.registerSingleton<CacheService>(cacheService);
    debugPrint("[ServiceCore] CacheService initialized and registered.");

    // Register other core services.
    locator.registerLazySingleton(() => NotificationService());
    locator.registerLazySingleton(() => NativeCalendarService());
    locator.registerLazySingleton(() => NewsArticleManager());
    locator.registerLazySingleton(() => NewsManager());
    locator.registerLazySingleton(() => const FlutterSecureStorage());
    debugPrint("[ServiceCore] Core services registered.");

    // Register voting managers.
    locator.registerLazySingleton(() => VotingManager());
    locator.registerLazySingleton(() => VotingResultsManager());
    debugPrint("[ServiceCore] Voting managers registered.");

    // Register TimeTableManager with its dependencies.
    locator.registerLazySingleton<TimeTableManager>(() {
      return TimeTableManager(
        locator<CacheService>(),
        locator<NotificationService>(),
        locator<NativeCalendarService>(),
      );
    });
    debugPrint("[ServiceCore] TimeTableManager registered with dependencies.");

    // Ensure all services and managers are fully initialized before proceeding.
    await locator.allReady();
    debugPrint("[ServiceCore] All services and repositories initialized successfully.");
  }
}
