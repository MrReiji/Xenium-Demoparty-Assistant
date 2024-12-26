import 'package:flutter/material.dart';

/// A reusable widget for displaying a loading state with optional title and message.
class LoadingWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? customSpinner;

  const LoadingWidget({
    Key? key,
    this.title,
    this.message,
    this.customSpinner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom spinner or default CircularProgressIndicator
            customSpinner ??
                CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
            if (title != null) ...[
              const SizedBox(height: 20),
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
