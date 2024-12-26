import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/Theme.dart';

class SubDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final GestureTapCallback? onTap;
  final bool isSelected;
  final Color? iconColor;

  const SubDrawerTile({
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
        margin: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall / 4),
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
          horizontal: AppDimensions.paddingMedium - AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : backgroundColor.withOpacity(0.5),
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
              size: 18,
              color: isSelected
                  ? iconThemeColor
                  : (iconColor ?? iconThemeColor)?.withOpacity(0.6),
            ),
            SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? textColor
                      : textColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
