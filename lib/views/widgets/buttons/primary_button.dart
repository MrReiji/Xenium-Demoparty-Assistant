import 'package:demoparty_assistant/views/Theme.dart'; // Custom theme styles
import 'package:flutter/material.dart'; // Core Flutter library

/// A reusable custom button with consistent styling.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key, // Widget's unique identifier
    required this.text, // Button label
    required this.press, // Function executed on button press
    this.color = primaryColor, // Default button color
    this.padding = const EdgeInsets.all(AppDimensions.paddingMedium), // Default padding
  });

  final String text; // Text displayed on the button
  final VoidCallback press; // Callback triggered on press
  final Color color; // Background color of the button
  final EdgeInsets padding; // Internal padding of the button

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context); // Accessing theme for consistent styling

    return MaterialButton(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)), // Rounded corners
      ),
      padding: padding, // Button padding
      color: color, // Button background color
      minWidth: double.infinity, // Full-width button
      onPressed: press, // Trigger action on button press
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white, // White text color for contrast
          fontSize: theme.textTheme.headlineLarge!.fontSize, // Dynamic font size
        ),
      ),
    );
  }
}

