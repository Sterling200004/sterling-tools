import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemonData;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final VoidCallback onPlaySound;

  const PokemonCard({
    super.key,
    required this.pokemonData,
    required this.audioPlayer,
    required this.isPlaying,
    required this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    final types = pokemonData['types']
            ?.map<String>((t) => t['type']['name'].toString())
            .toList() ??
        [];
    final abilities = pokemonData['abilities']
            ?.map<String>((a) => a['ability']['name'].toString())
            .toList() ??
        [];
    final stats = pokemonData['stats'] ?? [];
    final sprites = pokemonData['sprites'] ?? {};
    final imageUrl = sprites['other']?['official-artwork']?['front_default'] ??
        sprites['front_default'];

    return Column(
      children: [
        // Primero la imagen
        _buildImageCard(imageUrl),
        const SizedBox(height: 24),
        
        // Luego la información
        _buildInfoCard(types, abilities, stats),
        const SizedBox(height: 24),
        
        // Finalmente el botón de sonido
        if (pokemonData['cries'] != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isPlaying ? null : onPlaySound,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isPlaying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.volume_up),
              label: Text(
                isPlaying ? 'Reproduciendo...' : 'Escuchar sonido',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(
      List<String> types, List<String> abilities, List<dynamic> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${pokemonData['name'] ?? ''}'.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: #${pokemonData['id'] ?? ''}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 24),

            // Tipos
            const Text(
              'Tipo(s):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: types
                  .map((type) => Chip(
                        label: Text(type),
                        backgroundColor: _getTypeColor(type),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Experiencia base
            const Text(
              'Experiencia base:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${pokemonData['base_experience'] ?? 'N/A'} XP',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Habilidades
            const Text(
              'Habilidades:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: abilities
                  .map(
                    (ability) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• ${ability.replaceAll('-', ' ')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Estadísticas
            const Text(
              'Estadísticas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...stats.map<Widget>((stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stat['stat']['name'].toString().replaceAll('-', ' ')}: ${stat['base_stat']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      LinearProgressIndicator(
                        value: stat['base_stat'] / 200,
                        backgroundColor: Colors.grey[300],
                        color: _getStatColor(stat['stat']['name']),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String? imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 100),
              )
            else
              const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16),
            Text(
              '${pokemonData['name'] ?? ''}'.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final colors = {
      'normal': Colors.brown[200],
      'fire': Colors.red[400],
      'water': Colors.blue[400],
      'electric': Colors.yellow[600],
      'grass': Colors.green[400],
      'ice': Colors.cyan[200],
      'fighting': Colors.orange[800],
      'poison': Colors.purple[400],
      'ground': Colors.amber[600],
      'flying': Colors.indigo[200],
      'psychic': Colors.pink[400],
      'bug': Colors.lightGreen[500],
      'rock': Colors.brown[400],
      'ghost': Colors.deepPurple[400],
      'dragon': Colors.indigo[800],
      'dark': Colors.brown[800],
      'steel': Colors.blueGrey[400],
      'fairy': Colors.pink[200],
    };
    return colors[type] ?? Colors.grey;
  }

  Color _getStatColor(String statName) {
    final colors = {
      'hp': Colors.green,
      'attack': Colors.red,
      'defense': Colors.blue,
      'special-attack': Colors.purple,
      'special-defense': Colors.blue[800],
      'speed': Colors.amber,
    };
    return colors[statName] ?? Colors.grey;
  }
}
