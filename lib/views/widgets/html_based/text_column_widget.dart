import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:demoparty_assistant/views/widgets/html_based/heading_widget.dart';
import 'package:flutter/material.dart';
import 'custom_list_widget.dart';
import 'package:demoparty_assistant/views/widgets/html_based/hiperlink_widgets.dart';

/// A widget that processes HTML content with paragraphs (<p>), headings (<h1> to <h6>),
/// unordered lists (<ul>), and hyperlinks (<a>).
class TextColumnWidget extends StatelessWidget {
  final Bs4Element content;

  /// Creates a TextColumnWidget for processing and rendering HTML content.
  const TextColumnWidget({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Generate widgets from the content tree
    final widgets = _generateWidgetsFromContent(content, theme, context);

    // Return the final column widget
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  /// Recursively processes the content tree and generates widgets.
  List<Widget> _generateWidgetsFromContent(Bs4Element element, ThemeData theme, BuildContext context) {
    final widgets = <Widget>[];

    for (final child in element.children) {
      final tagName = child.name?.toLowerCase();

      if (tagName == 'p') {
        widgets.add(buildTextWithHyperlinks(child, theme, context));
      } else if (tagName == 'ul') {
        widgets.add(CustomListWidget(content: child));
      } else if (tagName != null && RegExp(r'^h[1-6]$').hasMatch(tagName)) {
        // Process headings
        final level = int.tryParse(tagName.substring(1)) ?? 6; // Extract level from 'h1', 'h2', etc.
        widgets.add(HeadingWidget(
          text: child.text.trim(),
          level: level,
        ));
      } else if (tagName == 'div') {
        // Recursively process div containers
        widgets.addAll(_generateWidgetsFromContent(child, theme, context));
      } else {
        print('Unsupported element: $tagName');
      }
    }

    return widgets;
  }
}
