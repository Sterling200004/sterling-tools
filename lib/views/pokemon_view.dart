import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/pokemon_card.dart';

class PokemonView extends StatefulWidget {
  const PokemonView({super.key});

  @override
  State<PokemonView> createState() => _PokemonViewState();
}

class _PokemonViewState extends State<PokemonView> {
  final TextEditingController _pokemonController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;
  bool _isPlaying = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _pokemonController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchPokemon() async {
    if (!_isValidInput(_pokemonController.text)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _pokemonData = null;
      _isPlaying = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/${_pokemonController.text.trim().toLowerCase()}'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _pokemonData = data);
        
        // Precargar el sonido
        final cryUrl = data['cries']['latest'] ?? data['cries']['legacy'];
        if (cryUrl != null) {
          await _audioPlayer.setSourceUrl(cryUrl);
        }
      } else if (response.statusCode == 404) {
        setState(() => _errorMessage = 'Pokémon no encontrado');
      } else {
        setState(() => _errorMessage = 'Error al buscar Pokémon (Código ${response.statusCode})');
      }
    } on TimeoutException {
      setState(() => _errorMessage = 'Tiempo de espera agotado. Intenta nuevamente.');
    } on SocketException {
      setState(() => _errorMessage = 'Problema de conexión. Verifica tu internet.');
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playPokemonCry() async {
    if (_pokemonData == null) return;

    setState(() => _isPlaying = true);
    await _audioPlayer.play(UrlSource(_pokemonData!['cries']['latest'] ?? _pokemonData!['cries']['legacy']));
    setState(() => _isPlaying = false);
  }

  bool _isValidInput(String input) {
    if (input.isEmpty) return false;
    if (input.length < 3 || input.length > 30) return false;
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s-]+$').hasMatch(input);
  }

  bool get _isButtonEnabled {
    return _isValidInput(_pokemonController.text);
  }

  void _resetSearch() {
    setState(() {
      _pokemonData = null;
      _errorMessage = '';
      _isPlaying = false;
    });
    _pokemonController.clear();
    _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Buscar Pokémon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Información de Pokémon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa el nombre de un Pokémon para ver sus detalles, imagen y escuchar su sonido.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _pokemonController,
              onChanged: (value) {
                setState(() {
                  // Limpiar resultados cuando el campo de texto está vacío
                  if (value.isEmpty) {
                    _pokemonData = null;
                    _errorMessage = '';
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Nombre del Pokémon',
                hintText: 'Ejemplo: pikachu',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                suffixIcon: _pokemonController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _resetSearch,
                      )
                    : null,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s-]')),
                LengthLimitingTextInputFormatter(30),
              ],
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 16),
            
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonEnabled && !_isLoading ? _fetchPokemon : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Ver detalles del Pokémon',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            
            if (_pokemonData == null && !_isLoading && _pokemonController.text.isEmpty)
              Opacity(
                opacity: 0.5,
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.catching_pokemon, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Sin resultados',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else if (_pokemonData != null)
              PokemonCard(
                pokemonData: _pokemonData!,
                audioPlayer: _audioPlayer,
                isPlaying: _isPlaying,
                onPlaySound: _playPokemonCry,
              ),
          ],
        ),
      ),
    );
  }
}