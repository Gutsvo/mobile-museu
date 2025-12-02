class MuseumArt {
  final int id;
  final String title;
  final String image;
  final String author;
  final String description;

  MuseumArt({
    required this.id,
    required this.title,
    required this.image,
    required this.author,
    required this.description,
  });

  factory MuseumArt.fromJson(Map<String, dynamic> json) {
    return MuseumArt(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      author: json['author'] ?? "Autor desconhecido",
      description: json['description'] ?? "Sem descrição.",
    );
  }
}
