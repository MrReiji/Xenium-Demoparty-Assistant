import 'package:demoparty_assistant/models/voting_entry_model.dart';
import 'package:flutter/material.dart';

class VotingResultCard extends StatelessWidget {
  final VotingEntry entry;
  final VoidCallback onImageTap;

  const VotingResultCard({required this.entry, required this.onImageTap, Key? key}) : super(key: key);

  String _cleanAuthor(String author) {
    // Usuń prefiks "by " (case-insensitive) z początku tekstu
    return author.toLowerCase().startsWith("by ") ? author.substring(3).trim() : author.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3), width: 1.5),
      ),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Obrazek
            GestureDetector(
              onTap: onImageTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  entry.imageUrl.toString(),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.error,
                    height: 120,
                    width: 120,
                    child: Icon(Icons.broken_image, size: 50, color: theme.colorScheme.onError),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Informacje tekstowe
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ranking
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: theme.colorScheme.primary, size: 24),
                      const SizedBox(width: 8.0),
                      Text(
                        "Rank: #${entry.rank}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Tytuł
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.title, color: theme.colorScheme.secondary, size: 24),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          "Title: ${entry.title}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Autor
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: theme.colorScheme.tertiaryContainer ?? Colors.blueGrey, size: 24),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          "Author: ${_cleanAuthor(entry.author)}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
