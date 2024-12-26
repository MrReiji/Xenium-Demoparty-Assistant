import 'package:cached_network_image/cached_network_image.dart';
import 'package:demoparty_assistant/models/voting_entry_model.dart';
import 'package:flutter/material.dart';

/// A custom card widget for displaying voting results.
/// This widget shows details about a voting entry, including: its image, rank, title, and author.
class VotingResultCard extends StatelessWidget {
  final VotingEntry entry; // Data for the voting entry.
  final VoidCallback onImageTap; // Callback for image tap interaction.

  /// Constructs a [VotingResultCard] with the given [entry] and [onImageTap] callback.
  const VotingResultCard({required this.entry, required this.onImageTap, Key? key}) : super(key: key);

  /// Cleans the author field by removing the "by " prefix, if present.
  /// Ensures consistent formatting for author names.
  String _cleanAuthor(String author) => author.toLowerCase().startsWith("by ") ? author.substring(3).trim() : author.trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the app's theme for consistent styling.

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Adds spacing around the card.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Gives the card rounded corners.
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3), width: 1.5), // Subtle border with primary color.
      ),
      elevation: 6, // Adds shadow for depth.
      child: Container(
        padding: const EdgeInsets.all(16.0), // Adds padding inside the card.
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Sets the background color based on the theme.
          borderRadius: BorderRadius.circular(20), // Matches the card's rounded corners.
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)), // Creates a slightly visible border.
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns items at the start of the row.
          children: [
            GestureDetector(
              onTap: onImageTap, // Calls the provided callback when the image is tapped.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0), // Rounds the corners of the image.
                child: CachedNetworkImage(
                  imageUrl: entry.imageUrl.toString(), // Loads the image from the provided URL.
                  height: 120, // Sets a fixed height for the image.
                  width: 120, // Sets a fixed width for the image.
                  fit: BoxFit.cover, // Ensures the image fills its container proportionally.
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceVariant, // Placeholder background color.
                    height: 120,
                    width: 120,
                    child: const Center(child: CircularProgressIndicator()), // Shows a loading spinner.
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.error, // Background color for error state.
                    height: 120,
                    width: 120,
                    child: Icon(Icons.broken_image, size: 50, color: theme.colorScheme.onError), // Displays an error icon.
                  ),),),),
            const SizedBox(width: 16.0), // Adds spacing between the image and the text section.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns text content to the start.
                children: [
                  Row(children: [
                    Icon(Icons.emoji_events, color: theme.colorScheme.primary, size: 24), // Trophy icon for rank.
                    const SizedBox(width: 8.0), // Adds spacing between the icon and the text.
                    Text("Rank: #${entry.rank}", style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: theme.colorScheme.primary)) // Displays the rank.
                  ]),
                  const SizedBox(height: 12.0), // Adds spacing between sections.
                  Row(children: [
                    Icon(Icons.title, color: theme.colorScheme.secondary, size: 24), // Icon for the title.
                    const SizedBox(width: 8.0), // Adds spacing between the icon and the text.
                    Expanded(child: Text("Title: ${entry.title}", style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))) // Displays the title.
                  ]),
                  const SizedBox(height: 12.0), // Adds spacing between sections.
                  Row(children: [
                    Icon(Icons.person, color: theme.colorScheme.tertiaryContainer, size: 24), // Icon for the author.
                    const SizedBox(width: 8.0), // Adds spacing between the icon and the text.
                    Expanded(child: Text("Author: ${_cleanAuthor(entry.author)}", style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8)))) // Displays the cleaned author name.
                  ]),],),),],),),);
  }
}
