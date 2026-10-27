import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/character_model.dart';
import '../providers/character_provider.dart';
import '../services/auth_service.dart';
import '../widgets/state_handler.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo Los Simpson'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                context.read<CharacterProvider>().refreshForCurrentUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // RF-03: Búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar personaje (Página actual)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
            ),
          ),
          
          // RF-06: Manejo de estados
          Expanded(
            child: StateHandler(
              state: provider.state,
              errorMessage: provider.errorMessage,
              emptyMessage: 'No se encontraron personajes con ese nombre en esta página.',
              onRetry: () => provider.refreshForCurrentUser(),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemCount: provider.characters
                  .where((character) => character.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                  .length,
                itemBuilder: (context, index) {
                  final filteredCharacters = provider.characters
                    .where((character) => character.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                    .toList();
                  final char = filteredCharacters[index];
                  return _CharacterCard(character: char);
                },
              ),
            ),
          ),

          // RF-04: Paginación
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.yellow.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Anterior'),
                ),
                Text('Página ${provider.currentPage} de ${provider.totalPages}', 
                     style: const TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Siguiente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//catálogo
class _CharacterCard extends StatelessWidget {
  final Character character;
  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(character: character)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: character.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(character.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Estado: ${character.status ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                  Text('Ocupación: ${character.occupation ?? 'N/A'}', style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}