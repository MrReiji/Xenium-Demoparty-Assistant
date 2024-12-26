import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/views/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/utils/functions/loadJson.dart';
import 'package:demoparty_assistant/utils/navigation/app_router_paths.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

/// This widget represents the onboarding screen of the application.
/// It loads onboarding data from a JSON file and displays it to the user.
/// The screen includes an image, event details, and a "GET STARTED" button
/// that navigates to the timetable screen.
class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  /// Holds the onboarding data loaded from the JSON file.
  Map<String, dynamic>? onboardingData;

  @override
  void initState() {
    super.initState();
    loadOnboardingData();
  }

  /// Function responsible for loading JSON data.
  /// This function fetches data asynchronously from a JSON file and updates the widget's state.
  Future<void> loadOnboardingData() async {
    try {
      // Fetching data from the JSON file
      final data = await loadJson('assets/data/onboarding_data.json');
      setState(() {
        onboardingData = data; // Updating the state after data is loaded
      });
    } catch (e) {
      // Handling errors during loading
      if (mounted) {
        // Ensures the widget is still part of the widget tree.
        // Prevents calling 'setState' on a widget that has been removed (e.g., after navigation).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load onboarding data')), // Informing the user
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
            padding:
                EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Main image with circular shape and shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape
                        .circle, // Ensures the image is displayed in a circular shape
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withOpacity(
                            0.5), // Adds a soft shadow around the image
                        blurRadius:
                            10.0, // Controls the blur intensity of the shadow
                        offset: Offset(0,
                            4), // Positions the shadow slightly below the image
                      ),
                    ],
                  ),
                  child: ClipOval(
                    // Ensures the image fits perfectly into the circular container
                    child:

                        /// Displays the event's theme image with caching
                        CachedNetworkImage(
                      imageUrl: imageUrl, // URL address fetched from JSON
                      placeholder: (context, url) => CircularProgressIndicator(
                        color: theme.colorScheme
                            .primary, // Spinner during image loading
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons
                            .error, // Error icon displayed if image loading fails
                        color: theme.colorScheme.error,
                      ),
                      fit: BoxFit
                          .fill, // Ensures the image covers the entire circular area
                      width: MediaQuery.of(context)
                          .size
                          .width, // Sets dynamic width based on screen size
                      height: MediaQuery.of(context).size.width *
                          0.6, // Sets dynamic height relative to width
                    ),
                  ),
                ),

                SizedBox(height: AppDimensions.paddingLarge),

                // Event title, year, and type
                Text(
                  // Displaying the event title, year, and type in a visually prominent style
                  "$eventTitle $year\n$eventType",
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme
                        .onSurface, // Ensuring contrast with background
                    letterSpacing:
                        1, // Slightly increased letter spacing for better readability
                    height: 1.2, // Line height for proper vertical spacing
                  ),
                  textAlign: TextAlign
                      .center, // Center-aligning the text for a balanced look
                ),
                SizedBox(
                    height:
                        AppDimensions.paddingLarge), // Spacing between sections

                // Theme description and specific theme name
                Text(
                  // Displaying the theme description followed by the specific theme name
                  "$themeDescription: $themeName",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color
                        ?.withOpacity(0.7), // Subtle color styling
                    fontStyle: FontStyle
                        .italic, // Italicized text to emphasize the theme
                  ),
                  textAlign:
                      TextAlign.center, // Center-aligning for aesthetic appeal
                ),

                SizedBox(
                    height:
                        AppDimensions.paddingLarge), // Spacing between sections
                        
                // Event details (location and date)
                Column(
                  children: [
                    // Location details (city and country)
                    Text(
                      "$city, $country",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(
                            0.7), // Subtle styling for secondary info
                      ),
                      textAlign:
                          TextAlign.center, // Center-aligning location details
                    ),
                    SizedBox(
                        height: AppDimensions
                            .paddingSmall), // Small spacing between location and date
                    // Event dates (start and end)
                    Text(
                      "$startDate - $endDate",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(
                            0.6), // Even subtler color for tertiary info
                      ),
                      textAlign:
                          TextAlign.center, // Center-aligning date details
                    ),
                  ],
                ),


                SizedBox(height: AppDimensions.paddingLarge),

                PrimaryButton(
                  text: "GET STARTED", // Button text
                  press: () {
                    context.go(AppRouterPaths.settings); // Navigation to the timetable screen
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
