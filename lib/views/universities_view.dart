import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import '../widgets/university_card.dart';

class UniversitiesView extends StatefulWidget {
  const UniversitiesView({super.key});

  @override
  State<UniversitiesView> createState() => _UniversitiesViewState();
}

class _UniversitiesViewState extends State<UniversitiesView> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  List<dynamic> _universities = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _visibleCount = 5;
  final int _increment = 5;

  @override
  void dispose() {
    _countryController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _fetchUniversities() async {
    if (!_isValidInput(_countryController.text)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _universities = [];
      _visibleCount = 5;
      _filterController.clear();
    });

    try {
      final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=${_countryController.text.trim().replaceAll(' ', '+')}'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isEmpty) {
          setState(() => _errorMessage = 'No se encontraron universidades para este país');
          return;
        }
        setState(() => _universities = data);
      } else {
        setState(() => _errorMessage = 'Error al buscar universidades (Código ${response.statusCode})');
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

  List<dynamic> get _filteredUniversities {
    if (_filterController.text.isEmpty) return _universities;
    
    return _universities.where((univ) => 
      univ['name'].toString().toLowerCase().contains(_filterController.text.toLowerCase()) ||
      (univ['domains'] != null && univ['domains'].any((domain) => 
        domain.toString().toLowerCase().contains(_filterController.text.toLowerCase())
      )) ||
      (univ['web_pages'] != null && univ['web_pages'].any((web) => 
        web.toString().toLowerCase().contains(_filterController.text.toLowerCase())
      ))
    ).toList();
  }

  bool _isValidInput(String input) {
    if (input.isEmpty) return false;
    if (input.length < 3 || input.length > 50) return false;
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(input);
  }

  bool get _isButtonEnabled {
    return _isValidInput(_countryController.text);
  }

  void _resetSearch() {
    setState(() {
      _universities = [];
      _errorMessage = '';
      _visibleCount = 5;
      _filterController.clear();
    });
    _countryController.clear();
  }

  void _showMoreUniversities() {
    setState(() {
      _visibleCount += _increment;
      if (_visibleCount > _filteredUniversities.length) {
        _visibleCount = _filteredUniversities.length;
      }
    });
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
        title: const Text('Universidades por País'),
        actions: [
          if (_universities.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetSearch,
              tooltip: 'Limpiar búsqueda',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Buscar Universidades',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa un país en inglés para buscar sus universidades. Entre 3 y 50 caracteres, solo letras.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _countryController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nombre del país (en inglés)',
                hintText: 'Ejemplo: Dominican Republic',
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
                suffixIcon: _countryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _resetSearch,
                      )
                    : null,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                LengthLimitingTextInputFormatter(50),
              ],
              textCapitalization: TextCapitalization.words,
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
                onPressed: _isButtonEnabled && !_isLoading ? _fetchUniversities : null,
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
                        'Mostrar universidades',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            
            if (_universities.isEmpty && !_isLoading && _countryController.text.isEmpty)
              Opacity(
                opacity: 0.5,
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.school, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Sin resultados',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else if (_universities.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de filtrado (NUEVO)
                  TextField(
                    controller: _filterController,
                    onChanged: (_) => setState(() {
                      _visibleCount = 5; // Resetear el contador al filtrar
                    }),
                    decoration: InputDecoration(
                      labelText: 'Filtrar universidades',
                      hintText: 'Por nombre, dominio o sitio web',
                      prefixIcon: const Icon(Icons.filter_alt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      suffixIcon: _filterController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _filterController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    '${_filteredUniversities.length} de ${_universities.length} universidades',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  ..._filteredUniversities.take(_visibleCount).map((university) => UniversityCard(
                    name: university['name'] ?? 'Nombre no disponible',
                    domains: List<String>.from(university['domains'] ?? []),
                    webPages: List<String>.from(university['web_pages'] ?? []),
                    cardColor: isDarkMode ? Colors.grey[800]! : Colors.white,
                  )),
                  
                  if (_visibleCount < _filteredUniversities.length)
                    Center(
                      child: TextButton(
                        onPressed: _showMoreUniversities,
                        child: Text(
                          'Mostrar más (${_filteredUniversities.length - _visibleCount} restantes)',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}