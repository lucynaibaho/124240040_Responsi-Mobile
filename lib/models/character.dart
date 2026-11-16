class Character {
  const Character({
    required this.id,
    this.name = '',
    this.title = '',
    this.summary = '',
    this.status = '',
    this.species = '',
    this.image = '',
    this.url = '',
    this.newsSite = '',
    this.publishedAt = '',
    this.author = '',
  });

  final int id;
  final String name;
  final String title;
  final String summary;
  final String status;
  final String species;
  final String image;
  final String url;
  final String newsSite;
  final String publishedAt;
  final String author;

  String get displayTitle => (title.isNotEmpty ? title : name).trim();

  factory Character.fromJson(Map<String, dynamic> json) {
    final titleValue = (json['title'] ?? json['name'] ?? '').toString();
    final imageValue =
        (json['image_url'] ?? json['imageUrl'] ?? json['image'] ?? '')
            .toString();
    final newsSiteValue = (json['news_site'] ?? json['newsSite'] ?? '')
        .toString();
    final publishedAtValue = (json['published_at'] ?? json['publishedAt'] ?? '')
        .toString();
    final authorsValue = json['authors'];
    final authorValue =
        json['author']?.toString() ??
        (authorsValue is List
            ? authorsValue
                  .whereType<Map<String, dynamic>>()
                  .map((author) => author['name']?.toString() ?? '')
                  .where((name) => name.isNotEmpty)
                  .join(', ')
            : '');

    return Character(
      id: int.tryParse('${json['id']}') ?? 0,
      name: titleValue,
      title: titleValue,
      summary: (json['summary'] ?? json['content'] ?? '').toString(),
      status: publishedAtValue,
      species: newsSiteValue,
      image: imageValue,
      url: (json['url'] ?? '').toString(),
      newsSite: newsSiteValue,
      publishedAt: publishedAtValue,
      author: authorValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': displayTitle,
    'summary': summary,
    'image_url': image,
    'url': url,
    'news_site': newsSite,
    'published_at': publishedAt,
    'author': author,
  };
}
