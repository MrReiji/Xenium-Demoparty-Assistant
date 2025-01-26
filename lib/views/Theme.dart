import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Gradient background for the entire app
const appGradientBackground = LinearGradient(
  colors: [backgroundColorStart, backgroundColorEnd],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Background colors for different contexts
const backgroundColorStart = Color(0xFF212121); // Dark gradient start
const backgroundColorEnd = Color(0xFF191919); // Dark gradient end
const bgColorScreen = Color(0xFFFFFFFF); // Light screen background

// Primary and Secondary colors
const primaryColor = Color.fromRGBO(249, 99, 50, 1.0); // Primary brand color
const secondaryColor = Color.fromRGBO(68, 68, 68, 1.0); // Secondary brand color

// Text colors for various contexts
const textColorPrimary = Color(0xFF2C2C2C); // Primary text color for light theme
const textColorSecondary = Color(0xFF1D1D35); // Secondary text color
const textColorLight = Color(0xFFF5FCF9); // Light text for dark backgrounds
const mutedTextColor =
    Color.fromRGBO(136, 152, 170, 1.0); // Muted text color for secondary elements
const labelColor =
    Color.fromRGBO(254, 36, 114, 1.0); // Color for labels and highlights

// Button colors
const buttonColor =
    Color.fromRGBO(156, 38, 176, 1.0); // General button color
const buttonActiveColor =
    Color.fromRGBO(249, 99, 50, 1.0); // Color for active button states

// Input field colors
const inputColor =
    Color.fromRGBO(220, 220, 220, 1.0); // Default input field background
const inputSuccessColor =
    Color.fromRGBO(27, 230, 17, 1.0); // Input validation success color
const inputErrorColor =
    Color.fromRGBO(255, 54, 54, 1.0); // Input validation error color
const placeholderColor =
    Color.fromRGBO(159, 165, 170, 1.0); // Placeholder text color

// State colors
const errorColor =
    Color.fromRGBO(255, 54, 54, 1.0); // Error messages and elements
const warningColor = Color(0xFFF3BB1C); // Warnings
const successColor =
    Color.fromRGBO(24, 206, 15, 1.0); // Success messages and elements

// Tab and switch colors
const tabsColor = Color.fromRGBO(222, 222, 222,
    0.3); // Background color for inactive tabs
const switchOnColor =
    Color.fromRGBO(249, 99, 50, 1.0); // Switch active color
const switchOffColor =
    Color.fromRGBO(137, 137, 137, 1.0); // Switch inactive color

// Shadow and border colors
const shadowColor =
    Colors.black54; // General shadow color for elevation effects
const borderColor =
    Color.fromRGBO(231, 231, 231, 1.0); // Default border color for elements

// Colors for specific event types, used to visually differentiate
const eventColor = Color(0xFF4A90E2); // Soft blue for general events
const seminarColor = Color(0xFF9C27B0); // Purple for seminars
const concertColor = Color(0xFFE53935); // Red for concerts
const deadlineColor = Color(0xFFFFA726); // Orange for deadlines
const compoColor = Color(0xFF26A69A); // Teal for competitions

// Drawer section colors based on app palette
const aboutPartyColor = Color(0xFFF64021); // Bright Orange-Red for "About the Party"
const newsColor = Color(0xFFF2002B); // Vivid Red for "News"
const timetableColor = Color(0xFF496DDB); // Vivid Blue for "Timetable"
const competitionsColor = Color(0xFFF98016); // Bright Orange for "Competitions"
const getInvolvedColor = Color(0xFF7209B7); // Vivid Purple for "Get Involved"
const locationColor = Color(0xFF00CC66); // Bright Green for "Location"
const contactColor = Color(0xFFA01A7D); // Magenta for "Contact"
const usersColor = Color(0xFFFCC00B); // Bright Yellow for "Users"
const authorizationColor = Color(0xFF00A8E8); // Bright Cyan for "Authorization"
const votingColor = Color(0xFF2ECC71); // Emerald Green for "Voting"
const streamsColor = Color(0xFF9C27B0); // Rich Purple for "Streams"
const settingsColor = Color(0xFF4A5568); // Slate Gray for "Settings"



// Neutral and informational colors
const neutralColor = Color.fromRGBO(255, 255, 255, 0.2);
const infoColor =
    Color.fromRGBO(44, 168, 255, 1.0); // Informational highlights
const timeColor = Color.fromRGBO(154, 154, 154, 1.0); // Time display color
const priceColor =
    Color.fromRGBO(234, 213, 251, 1.0); // Price display color

// Dimension constants for consistent spacing and sizing
class AppDimensions {
  static const double paddingXXSmall = 2.0; // paddingSmall / 4
  static const double paddingXSmall = 4.0;  // paddingSmall / 2
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 32.0;
  static const double borderRadius = 15.0;
  static const double elevation = 10.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double drawerIconButtonWidth = 40.0;

  static const double dividerHeight = 1.0;
  static const double dividerThickness = 1.0;

  static const double eventCardIconContainerHeight = 45.0;
  static const double shadowBlurRadius = 5.0;

  static const double headingFontSize1 = 32.0;
  static const double headingFontSize2 = 28.0;
  static const double headingFontSize3 = 24.0;
  static const double headingFontSize4 = 20.0;
  static const double headingFontSize5 = 16.0;

  static const double appBarHeight = 56.0; // Default AppBar height in Flutter
  static const double paragraphFontSize = 16.0;
  static const double textLineHeight = 1.6;

  get betweenFields => null;
}

// Opacity constants
class AppOpacities {
  static const double iconOpacityHigh = 0.82;
  static const double iconOpacityMedium = 0.6;
  static const double iconOpacityLow = 0.32;

  static const double textOpacityHigh = 0.8;
  static const double textOpacityMedium = 0.7;
  static const double textOpacityLow = 0.6;

  static const int linkAlpha = 200; // For color with alpha value
}

// Offset constants
class AppOffsets {
  static const Offset shadowOffset = Offset(0, 4);
}

// Light theme configuration
ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColorScreen,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: AppDimensions.elevation,
      backgroundColor: bgColorScreen,
      titleTextStyle: GoogleFonts.anta(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: textColorPrimary,
      ),
      iconTheme: IconThemeData(color: textColorPrimary),
      surfaceTintColor: secondaryColor,
    ),
    iconTheme: IconThemeData(color: textColorPrimary),
    textTheme: GoogleFonts.antaTextTheme(
      Theme.of(context).textTheme.copyWith(
            displayLarge: TextStyle(
                fontSize: 55.0,
                fontWeight: FontWeight.bold,
                color: textColorPrimary),
            displayMedium: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: textColorPrimary),
            displaySmall: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: textColorPrimary),
            headlineLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: textColorPrimary),
            headlineMedium: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: textColorPrimary),
            titleLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: textColorPrimary),
            bodyLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
                color: textColorPrimary),
            bodyMedium: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: textColorPrimary),
            labelLarge: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: textColorPrimary),
            labelMedium: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: textColorPrimary),
            labelSmall: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: textColorPrimary),
            headlineSmall: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: textColorPrimary),
            titleMedium: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: textColorPrimary),
            titleSmall: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: textColorPrimary),
            bodySmall: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
                color: textColorPrimary),
          ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    dividerTheme: DividerThemeData(
      color: mutedTextColor,
      thickness: 1.0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: bgColorScreen,
      selectedItemColor: primaryColor.withOpacity(0.7),
      unselectedItemColor: textColorPrimary.withOpacity(0.32),
      selectedIconTheme: IconThemeData(color: primaryColor),
      showUnselectedLabels: true,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: BorderSide(color: primaryColor),
      ),
      labelStyle: TextStyle(color: textColorPrimary),
      hintStyle: TextStyle(color: mutedTextColor),
    ),
  );
}

// Dark theme configuration
ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorEnd,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: AppDimensions.elevation,
      backgroundColor: backgroundColorEnd,
      titleTextStyle: GoogleFonts.anta(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: textColorLight,
      ),
      iconTheme: IconThemeData(color: textColorLight),
      surfaceTintColor: backgroundColorEnd,
    ),
    iconTheme: IconThemeData(color: textColorLight),
    textTheme: GoogleFonts.antaTextTheme(
      Theme.of(context).textTheme.copyWith(
            displayLarge: TextStyle(
                fontSize: 55.0,
                fontWeight: FontWeight.bold,
                color: textColorLight),
            displayMedium: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: textColorLight),
            displaySmall: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: textColorLight),
            headlineLarge: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                color: textColorLight),
            headlineMedium: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: textColorLight),
            titleLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: textColorLight),
            bodyLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
                color: textColorLight),
            bodyMedium: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: textColorLight),
            labelLarge: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: textColorLight),
            labelMedium: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: textColorLight),
            labelSmall: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: textColorLight),
            headlineSmall: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: textColorLight),
            titleMedium: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: textColorLight),
            titleSmall: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: textColorLight),
            bodySmall: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
                color: textColorLight),
          ),
    ),
    colorScheme: ColorScheme.dark().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    dividerTheme: DividerThemeData(
      color: mutedTextColor,
      thickness: 1.0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColorEnd,
      selectedItemColor: textColorLight.withOpacity(0.7),
      unselectedItemColor: textColorLight.withOpacity(0.32),
      selectedIconTheme: IconThemeData(color: primaryColor),
      showUnselectedLabels: true,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundColorEnd,
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(color: textColorLight, fontSize: 16.0),
      hintStyle: TextStyle(color: placeholderColor, fontSize: 16.0),
    ),
  );
}
