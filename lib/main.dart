import 'package:demoparty_assistant/data/services/service_core.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/utils/navigation/router.dart';

/// The main entry point of the application.
///
/// This function ensures all core services and dependencies are initialized
/// before the application starts.
Future<void> main() async {
  // Ensure Flutter's widgets binding is initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services, managers, and dependencies.
  await ServiceCore.initialize();

  // Run the Flutter application.
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// This widget configures the app's routing, theming, and basic settings,
/// and acts as the top-level container for the entire app.
class MyApp extends StatelessWidget {
  /// Constructs the [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Configure app-level routing with a router delegate and information parser.
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,

      // Application title used by the operating system.
      title: 'Demoparty Assistant',

      // Set light and dark themes for the app.
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),

      // Specify the theme mode to use (e.g., light, dark, or system default).
      themeMode: ThemeMode.dark,

      // Disable the debug banner in the top-right corner during development.
      debugShowCheckedModeBanner: false,
    );
  }
}
