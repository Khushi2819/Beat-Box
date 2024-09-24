class Song {
  final String title;
  final String description;
  final String url;
  final String coverUrl;

  Song({
    required this.title,
    required this.description,
    required this.url,
    required this.coverUrl,
  });

  // Method to convert a map to a Song object
  factory Song.fromMap(Map<String, dynamic> data) {
    return Song(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      url: data['url'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
    );
  }

  // Method to convert a Song object to a map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'coverUrl': coverUrl,
    };
  }
}
