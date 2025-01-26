import 'package:demoparty_assistant/views/Theme.dart';
import 'package:flutter/material.dart';


class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.press,
    this.color = primaryColor,
    this.padding = const EdgeInsets.all(AppDimensions.paddingMedium),
  });

  final String text;
  final VoidCallback press;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return MaterialButton(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      padding: padding,
      color: color,
      minWidth: double.infinity,
      onPressed: press,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: theme.textTheme.headlineLarge!.fontSize),
      ),
    );
  }
}
