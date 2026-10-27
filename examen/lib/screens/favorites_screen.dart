import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CharacterProvider>();
    final favorites = provider.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Personajes favoritos')),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Aún no tienes personajes favoritos.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final id = favorite['id'] as int;
                final name = favorite['name'] as String? ?? 'Desconocido';
                final imageUrl = favorite['image'] as String? ?? '';

                return ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => 
                                const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image, size: 40),
                          ),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Toca el corazón para quitar'),
                  trailing: IconButton(
                    tooltip: 'Quitar de favoritos',
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      
                      await provider.removeFavoriteById(id);
                      
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$name eliminado de favoritos'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}