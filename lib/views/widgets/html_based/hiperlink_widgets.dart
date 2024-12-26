import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds a RichText widget with support for hyperlinks, with padding based on the element type.
Widget buildTextWithHyperlinks(Bs4Element element, ThemeData theme, BuildContext context) {
  final textStyle = theme.textTheme.bodyMedium?.copyWith(
    fontSize: 16,
    height: 1.6,
    color: theme.colorScheme.onSurface,
  );

  // Skip elements that are comments or effectively empty
  final cleanText = element.text.replaceAll(RegExp(r'<!--.*?-->'), '').trim();
  if (cleanText.isEmpty) {
    return const SizedBox.shrink();
  }

  final linkElements = element.findAll('a');

  if (linkElements.isEmpty) {
    // Render plain text if no hyperlinks are present
    return Padding(
      padding: _getPaddingForElement(element),
      child: Text(
        cleanText,
        style: textStyle,
      ),
    );
  }

  // Process element with hyperlinks
  final spans = <TextSpan>[];
  String remainingText = cleanText;

  for (final link in linkElements) {
    final linkText = link.text.trim();
    final linkHref = link.attributes['href'] ?? '';

    // Check if the link contains obfuscated email
    final obfuscatedEmailSpan = link.find('span', class_: '__cf_email__');
    final decodedEmail = obfuscatedEmailSpan != null
        ? decodeCloudflareEmail(obfuscatedEmailSpan.attributes['data-cfemail']!)
        : null;

    final splitIndex = remainingText.indexOf(linkText);

    if (splitIndex != -1) {
      // Add text before the hyperlink
      final textBeforeLink = remainingText.substring(0, splitIndex).trim();
      if (textBeforeLink.isNotEmpty) {
        spans.add(TextSpan(
          text: textBeforeLink + ' ',
          style: textStyle,
        ));
      }

      if (decodedEmail != null) {
        // Add decoded email hyperlink
        spans.add(TextSpan(
          text: decodedEmail + ' ',
          style: textStyle?.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Clipboard.setData(ClipboardData(text: decodedEmail));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied $decodedEmail to clipboard')),
              );
            },
        ));
      } else {
        // Add regular hyperlink
        spans.add(TextSpan(
          text: linkText + ' ',
          style: textStyle?.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final url = Uri.parse(linkHref);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
        ));
      }

      // Update the remaining text
      remainingText = remainingText.substring(splitIndex + linkText.length);
    }
  }

  // Add remaining text after the last hyperlink
  if (remainingText.trim().isNotEmpty) {
    spans.add(TextSpan(
      text: remainingText.trim(),
      style: textStyle,
    ));
  }

  return Padding(
    padding: _getPaddingForElement(element),
    child: RichText(
      text: TextSpan(children: spans),
    ),
  );
}


/// Decodes obfuscated emails protected by Cloudflare's `data-cfemail`.
String decodeCloudflareEmail(String obfuscatedEmail) {
  final xorKey = int.parse(obfuscatedEmail.substring(0, 2), radix: 16);
  final buffer = StringBuffer();

  for (var i = 2; i < obfuscatedEmail.length; i += 2) {
    final charCode = int.parse(obfuscatedEmail.substring(i, i + 2), radix: 16) ^ xorKey;
    buffer.write(String.fromCharCode(charCode));
  }

  return buffer.toString();
}

/// Returns padding based on the HTML element type.
EdgeInsets _getPaddingForElement(Bs4Element element) {
  switch (element.name) {
    case 'p':
      return const EdgeInsets.only(bottom: 12.0); // Larger padding for paragraphs
    case 'li':
      return const EdgeInsets.symmetric(vertical: 2.0); // Smaller padding for list items
    default:
      return const EdgeInsets.all(8.0); // Default padding for other elements
  }
}
