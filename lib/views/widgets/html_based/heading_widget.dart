// HeadingWidget.dart
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/Theme.dart';

class HeadingWidget extends StatelessWidget {
  final String text;
  final int level;

  const HeadingWidget({required this.text, required this.level, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle style;
    switch (level) {
      case 1:
        style = theme.textTheme.displayLarge!.copyWith(
          fontSize: AppDimensions.headingFontSize1,
        );
        break;
      case 2:
        style = theme.textTheme.displayMedium!.copyWith(
          fontSize: AppDimensions.headingFontSize2,
        );
        break;
      case 3:
        style = theme.textTheme.displaySmall!.copyWith(
          fontSize: AppDimensions.headingFontSize3,
        );
        break;
      case 4:
        style = theme.textTheme.headlineMedium!.copyWith(
          fontSize: AppDimensions.headingFontSize4,
        );
        break;
      case 5:
        style = theme.textTheme.headlineSmall!.copyWith(
          fontSize: AppDimensions.headingFontSize5,
        );
        break;
      default:
        style = theme.textTheme.bodyLarge!;
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
