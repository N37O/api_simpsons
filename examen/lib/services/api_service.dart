import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';

class ApiService {
  final String baseUrl = 'https://thesimpsonsapi.com/api/characters';

  
  Future<Map<String, dynamic>> fetchCharacters(int page) async {
    final response = await http.get(Uri.parse('$baseUrl?page=$page'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> resultsJson = data['results'] ?? [];
      List<Character> characters = resultsJson
          .map((json) => Character.fromJson(json))
          .toList();
      
      int totalPages = data['pages'] ?? 1; 
      
      return {
        'characters': characters,
        'totalPages': totalPages,
      };
    } else {
      throw Exception('Error al cargar los personajes. Código: ${response.statusCode}');
    }
  }
}