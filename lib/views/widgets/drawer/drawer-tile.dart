import 'package:demoparty_assistant/views/Theme.dart';
import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final GestureTapCallback? onTap;
  final bool isSelected;
  final Color? iconColor;

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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final iconThemeColor = theme.iconTheme.color;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall / 2),
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall * 1.5,
          horizontal: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.3)
              : backgroundColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : textColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? iconThemeColor
                  : (iconColor ?? iconThemeColor)?.withOpacity(0.8),
            ),
            SizedBox(width: AppDimensions.paddingSmall * 1.5),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? textColor
                      : textColor.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
