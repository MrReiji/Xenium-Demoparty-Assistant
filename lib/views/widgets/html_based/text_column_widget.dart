import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/views/widgets/html_based/heading_widget.dart';
import 'package:flutter/material.dart';
import 'custom_list_widget.dart';
import 'package:demoparty_assistant/views/widgets/html_based/hiperlink_widgets.dart';

/// A widget that processes and renders structured HTML content.
class TextColumnWidget extends StatelessWidget {
  final Bs4Element content; // The HTML content to process and render.

  /// Creates a TextColumnWidget for processing and rendering HTML content.
  const TextColumnWidget({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    try {
      // Safely generate widgets from the content tree
      final widgets = _generateWidgetsFromContent(content, theme, context);

      // Return the final column widget with padding for proper layout
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      );
    } catch (e) {
      // Catch any unexpected errors during widget generation
      debugPrint('Error generating widgets from HTML content: $e');
      return _buildErrorWidget(context);
    }
  }

  /// Processes the content tree and generates a list of Flutter widgets.
  ///
  /// This method handles supported HTML elements such as paragraphs, headings, lists, and divs.
  List<Widget> _generateWidgetsFromContent(
      Bs4Element element, ThemeData theme, BuildContext context) {
    final widgets = <Widget>[];

    for (final child in element.children) {
      try {
        final tagName = child.name?.toLowerCase();

        // Handle paragraph elements
        if (tagName == 'p') {
          widgets.add(buildTextWithHyperlinks(child, theme, context));
        }
        // Handle unordered lists
        else if (tagName == 'ul') {
          widgets.add(CustomListWidget(content: child));
        }
        // Handle headings (h1 to h6)
        else if (tagName != null && RegExp(r'^h[1-6]$').hasMatch(tagName)) {
          final level = int.tryParse(tagName.substring(1)) ?? 6;
          widgets.add(HeadingWidget(
            text: child.text.trim(),
            level: level,
          ));
        }
        // Recursively process div elements
        else if (tagName == 'div') {
          widgets.addAll(_generateWidgetsFromContent(child, theme, context));
        } else {
          // Log unsupported tags for debugging without exposing them to production
          debugPrint('Unsupported HTML element encountered: $tagName');
        }
      } catch (e) {
        // Handle errors for specific elements and skip invalid ones
        debugPrint('Error processing element: ${child.name}, Error: $e');
      }
    }

    return widgets;
  }

  /// Builds a fallback widget for error scenarios.
  ///
  /// Displays a user-friendly message when an error occurs.
  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 48.0),
            const SizedBox(height: 8.0),
            const Text(
              'An error occurred while processing the content.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
