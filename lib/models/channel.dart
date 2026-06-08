class Channel {
  final String name;
  final String logo;
  final String url;
  final String? category;

  Channel({
    required this.name,
    required this.logo,
    required this.url,
    this.category,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      name: json['name'] ?? 'Unknown',
      logo: json['logo'] ?? '',
      url: json['url'] ?? '',
      category: json['category'],
    );
  }
}
