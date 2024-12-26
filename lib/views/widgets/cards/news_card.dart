// NewsCard.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:demoparty_assistant/views/screens/news_article_screen.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/models/news_model.dart';

/// A widget representing a card view for a news article.
///
/// Displays the article's image, title, and categories. 
/// Tapping the card navigates to the article's full details.
class NewsCard extends StatelessWidget {
  /// The [NewsModel] instance containing news article data.
  final NewsModel news;

  /// Constructs a [NewsCard] widget with the provided [news] data.
  const NewsCard({required this.news, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the app's theme.

    return GestureDetector(
      onTap: () {
        // Navigates to the NewsArticleScreen with the article's details.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsArticleScreen(
              title: news.title,
              image: news.imageUrl,
              articleUrl: news.articleUrl,
            ),),);},
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium, // Vertical padding for spacing.
          horizontal: AppDimensions.paddingMedium, // Horizontal padding for spacing.
        ),
        elevation: AppDimensions.elevation / 2, // Light shadow effect.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius), // Rounded corners.
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start.
          children: [
            // Article image with rounded corners.
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius * 2),
              child: AspectRatio(
                aspectRatio: 7 / 5, // Maintain image aspect ratio.
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl, // Network image URL.
                  fit: BoxFit.fill, // Fill the container without distortion.
                  placeholder: (context, url) => const CircularProgressIndicator(), // Loading indicator.
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image, // Fallback icon for failed image loading.
                    color: theme.colorScheme.error,
                    size: 40.0,
                  ),
                ),),),
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium), // Content padding.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Displays categories as styled labels.
                  Wrap(
                    spacing: AppDimensions.paddingSmall, // Horizontal spacing between categories.
                    runSpacing: AppDimensions.paddingSmall / 2, // Vertical spacing for wrapped rows.
                    children: news.categories.map((category) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall, // Horizontal padding inside labels.
                          vertical: AppDimensions.paddingSmall / 2, // Vertical padding inside labels.
                        ),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.7), // Semi-transparent background.
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadius / 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Compact the row to fit content.
                          children: [
                            Icon(
                              Icons.label, // Icon representing a category label.
                              color: theme.iconTheme.color!.withOpacity(0.8), // Icon color from theme.
                              size: 16.0, // Icon size.
                            ),
                            SizedBox(width: AppDimensions.paddingSmall / 2), // Spacing between icon and text.
                            Text(
                              category, // Category name.
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.bold, // Bold category text.
                              ),),],),);}).toList(),),
                  SizedBox(height: AppDimensions.paddingSmall), // Space between categories and title.
                  // Displays the article title.
                  Text(
                    news.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface, // Text color from theme.
                    ),),],),),],),),
    );
  }
}
