class NewsModel {
  final String title;
  final String content;
  final String fullContent;
  final String imageUrl;
  final String articleUrl;
  final List<String> categories;

  NewsModel({
    required this.title,
    required this.content,
    required this.fullContent,
    required this.imageUrl,
    required this.articleUrl,
    required this.categories,
  });

  /// Factory constructor to create `NewsModel` from JSON.
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'],
      content: json['content'],
      fullContent: json['fullContent'] ?? '',
      imageUrl: json['imageUrl'],
      articleUrl: json['articleUrl'],
      categories: List<String>.from(json['categories']),
    );
  }

  /// Converts `NewsModel` to JSON for caching purposes.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'fullContent': fullContent,
      'imageUrl': imageUrl,
      'articleUrl': articleUrl,
      'categories': categories,
    };
  }
}