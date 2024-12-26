import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/widgets/html_based/hiperlink_widgets.dart';

/// A widget that processes HTML unordered lists (<ul>) and list items (<li>).
class CustomListWidget extends StatelessWidget {
  final Bs4Element content;

  /// Creates a CustomListWidget to render list items.
  const CustomListWidget({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out list items with style="list-style-type: none;"
    final listItems = content.findAll('li').where((li) {
      final style = li.attributes['style'];
      return style == null || !style.contains('list-style-type: none;');
    }).toList();

    // Filter out empty or effectively empty list items
    final filteredItems = listItems.where((li) {
      final cleanText = li.text.replaceAll(RegExp(r'<!--.*?-->'), '').trim();
      return cleanText.isNotEmpty;
    }).toList();

    if (filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filteredItems.map((li) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10.0), // Align the circle vertically
                  child: Icon(Icons.circle, size: 8, color: Colors.grey),
                ),
                const SizedBox(width: 8), // Add space between the circle and text
                Expanded(
                  child: buildTextWithHyperlinks(li, theme, context),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
