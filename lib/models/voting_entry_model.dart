/// Represents a voting entry with details about rank, title, author, and image.
class VotingEntry {
  final int rank;
  final String title;
  final String author;
  final Uri imageUrl;

  VotingEntry({
    required this.rank,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  /// Creates a `VotingEntry` from a JSON map.
  factory VotingEntry.fromJson(Map<String, dynamic> json) {
    return VotingEntry(
      rank: json['rank'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      imageUrl: Uri.parse(json['imageUrl'] as String),
    );
  }

  /// Converts this `VotingEntry` to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'title': title,
      'author': author,
      'imageUrl': imageUrl.toString(),
    };
  }
}