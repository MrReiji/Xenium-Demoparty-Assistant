// NewsCard.dart
import 'package:demoparty_assistant/views/screens/news_article_screen.dart';
import 'package:flutter/material.dart';
import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/models/news_model.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news;

  const NewsCard({required this.news, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsArticleScreen(
              title: news.title,
              image: news.imageUrl,
              articleUrl: news.articleUrl,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
          horizontal: AppDimensions.paddingMedium,
        ),
        elevation: AppDimensions.elevation / 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadius * 2),
              child: AspectRatio(
                aspectRatio: 7 / 5,
                child: Image.network(
                  news.imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppDimensions.paddingSmall,
                    runSpacing: AppDimensions.paddingSmall / 2,
                    children: news.categories.map((category) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                          vertical: AppDimensions.paddingSmall / 2,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.7),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.borderRadius / 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label,
                              color: theme.iconTheme.color!.withOpacity(0.8),
                              size: 16.0,
                            ),
                            SizedBox(width: AppDimensions.paddingSmall / 2),
                            Text(
                              category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    news.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
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
