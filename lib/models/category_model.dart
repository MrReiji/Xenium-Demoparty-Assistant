/// Represents a category with a name and a URL.
class Category {
  final String name;
  final Uri url;

  Category({
    required this.name,
    required this.url,
  });

  /// Creates a `Category` from a JSON map.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      url: Uri.parse(json['url'] as String),
    );
  }

  /// Converts this `Category` to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url.toString(),
    };
  }
}