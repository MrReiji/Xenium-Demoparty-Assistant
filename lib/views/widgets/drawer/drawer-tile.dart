import 'package:demoparty_assistant/views/Theme.dart';
import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title; // Title of the drawer tile
  final IconData icon; // Icon to be displayed in the drawer tile
  final GestureTapCallback? onTap; // Callback function when the tile is tapped
  final bool isSelected; // Indicates if the tile is selected
  final Color? iconColor; // Custom color for the icon

  const DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final primaryColor = theme.primaryColor; // Primary color from the theme
    final backgroundColor = theme.scaffoldBackgroundColor; // Background color from the theme
    final iconThemeColor = theme.iconTheme.color; // Icon color from the theme
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black; // Text color from the theme

    return GestureDetector(
      onTap: onTap, // Handle tap event
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall / 2), // Vertical margin
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall * 1.5, // Vertical padding
          horizontal: AppDimensions.paddingMedium, // Horizontal padding
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.3) // Background color when selected
              : backgroundColor.withOpacity(0.05), // Background color when not selected
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius), // Rounded corners
          border: Border.all(
            color: isSelected
                ? primaryColor // Border color when selected
                : textColor.withOpacity(0.1), // Border color when not selected
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20, // Icon size
              color: isSelected
                  ? iconThemeColor // Icon color when selected
                  : (iconColor ?? iconThemeColor)?.withOpacity(0.8), // Icon color when not selected
            ),
            SizedBox(width: AppDimensions.paddingSmall * 1.5), // Spacing between icon and text
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? textColor // Text color when selected
                      : textColor.withOpacity(0.8), // Text color when not selected
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}


