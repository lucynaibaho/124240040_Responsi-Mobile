class Episode {
  const Episode({
    required this.id,
    required this.name,
    this.airDate = '',
    this.episode = '',
  });

  final int id;
  final String name;
  final String airDate;
  final String episode;

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      airDate: (json['air_date'] ?? '').toString(),
      episode: (json['episode'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'air_date': airDate,
    'episode': episode,
  };
}
