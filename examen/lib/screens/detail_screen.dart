import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/character_model.dart';
import '../providers/character_provider.dart';

class DetailScreen extends StatefulWidget {
  final Character character;
  const DetailScreen({required this.character, super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  void _checkFavorite() async {
    final provider = Provider.of<CharacterProvider>(context, listen: false);
    bool isFav = await provider.isFavorite(widget.character.id);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  void _toggleFavorite() async {
    final provider = Provider.of<CharacterProvider>(context, listen: false);
    
    await provider.toggleFavorite(widget.character);
    
    //Actualizar estado visual
    bool newIsFav = await provider.isFavorite(widget.character.id);
    if (mounted) {
      setState(() => _isFavorite = newIsFav);
      
      //Mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite 
                ? '${widget.character.name} agregado a favoritos' 
                : '${widget.character.name} eliminado de favoritos',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.character;

    return Scaffold(
      appBar: AppBar(
        title: Text(char.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite, 
            tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: char.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(char.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  _buildInfoRow('Estado', char.status),
                  _buildInfoRow('Ocupación', char.occupation),
                  _buildInfoRow('Género', char.gender),
                  _buildInfoRow('Edad', char.age),
                  const Divider(height: 30),
                  const Text('Frases célebres:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  if (char.phrases != null && char.phrases!.isNotEmpty)
                    Text('"${char.phrases!.first}"', style: const TextStyle(fontStyle: FontStyle.italic))
                  else
                    const Text('No hay frases registradas.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'Desconocido')),
        ],
      ),
    );
  }
}