import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/views/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/utils/functions/loadJson.dart';
import 'package:demoparty_assistant/utils/navigation/app_router_paths.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  Map<String, dynamic>? onboardingData;

  @override
  void initState() {
    super.initState();
    _loadOnboardingData();
  }

  // Load JSON data and update the state using the loadJson utility
  Future<void> _loadOnboardingData() async {
    try {
      final data = await loadJson('assets/data/onboarding_data.json');
      setState(() {
        onboardingData = data;
      });
    } catch (e) {
      print('Error loading onboarding data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load onboarding data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show a loading spinner if data is not yet loaded
    if (onboardingData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    // Extract data from the loaded JSON
    final imageUrl = onboardingData!['imageUrl'];
    final eventTitle = onboardingData!['eventTitle'];
    final year = onboardingData!['year'];
    final eventType = onboardingData!['eventType'];
    final themeDescription = onboardingData!['themeDescription'];
    final themeName = onboardingData!['theme'];
    final city = onboardingData!['city'];
    final country = onboardingData!['country'];
    final startDate = onboardingData!['startDate'];
    final endDate = onboardingData!['endDate'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: appGradientBackground,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Main image with circular shape and shadow, using CachedNetworkImage for caching
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withOpacity(0.5),
                        blurRadius: 10.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: theme.colorScheme.error,
                      ),
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.6,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingLarge),

                // Event title, year, and type
                Text(
                  "$eventTitle $year\n$eventType",
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    letterSpacing: 1,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.paddingLarge),

                // Theme description and specific theme name
                Text(
                  "$themeDescription: $themeName",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.paddingLarge),

                // Event details (location and date)
                Column(
                  children: [
                    Text(
                      "$city, $country",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      "$startDate - $endDate",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.paddingLarge),

                // "GET STARTED" button
                PrimaryButton(
                  text: "GET STARTED",
                  press: () {
                    context.go(AppRouterPaths.timeTable);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
