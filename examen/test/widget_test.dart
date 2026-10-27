
import 'package:flutter_test/flutter_test.dart';
import 'package:examen/models/character_model.dart';

void main() {
  test('Character.fromJson parses the character data used by the app', () {
    final character = Character.fromJson({
      'id': 1,
      'name': 'Homer Simpson',
      'age': 39,
      'portrait_path': '/characters/1.jpg',
      'phrases': ['D’oh!'],
    });

    expect(character.id, 1);
    expect(character.name, 'Homer Simpson');
    expect(character.age, '39');
    expect(
      character.imageUrl,
      'https://cdn.thesimpsonsapi.com/500/characters/1.jpg',
    );
    expect(character.phrases, ['D’oh!']);
  });
}
