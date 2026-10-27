class Character {
  final int id;
  final String name;
  final String? status;
  final String? occupation;
  final String? gender;
  final String? age;
  final String? portraitPath;
  final List<String>? phrases;

  Character({
    required this.id,
    required this.name,
    this.status,
    this.occupation,
    this.gender,
    this.age,
    this.portraitPath,
    this.phrases,
  });

  // Construcción de la URL de la imagen según el PDF
  String get imageUrl {
    if (portraitPath == null || portraitPath!.isEmpty) return '';
    // El PDF indica: https://cdn.thesimpsonsapi.com/500 + portrait_path
    return 'https://cdn.thesimpsonsapi.com/500$portraitPath';
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    // Manejo seguro de nulos y tipos de datos (RT-01)
    List<String>? parsedPhrases;
    if (json['phrases'] != null) {
      if (json['phrases'] is List) {
        parsedPhrases = List<String>.from(json['phrases']);
      } else if (json['phrases'] is String) {
        parsedPhrases = [json['phrases']];
      }
    }

    return Character(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Desconocido',
      status: json['status'],
      occupation: json['occupation'],
      gender: json['gender'],
      age: json['age']?.toString(), // A veces viene como número o string
      portraitPath: json['portrait_path'],
      phrases: parsedPhrases,
    );
  }
}