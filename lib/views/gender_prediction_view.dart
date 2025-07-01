import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import '../widgets/gender_card.dart';

class GenderPredictionView extends StatefulWidget {
  const GenderPredictionView({super.key});

  @override
  State<GenderPredictionView> createState() => _GenderPredictionViewState();
}

class _GenderPredictionViewState extends State<GenderPredictionView> {
  final TextEditingController _nameController = TextEditingController();
  String _gender = '';
  double _probability = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _predictGender() async {
    if (!_isValidInput(_nameController.text)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _gender = '';
      _probability = 0.0;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
                'https://api.genderize.io/?name=${_nameController.text.trim()}'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['gender'] == null) {
          setState(() => _errorMessage =
              'No se pudo determinar el género para este nombre');
          return;
        }
        setState(() {
          _gender = data['gender'];
          _probability = (data['probability'] ?? 0.0) * 100;
        });
      } else if (response.statusCode == 429) {
        setState(() => _errorMessage =
            'Límite de solicitudes alcanzado. Intenta más tarde.');
      } else {
        setState(() => _errorMessage =
            'Error en el servidor (Código ${response.statusCode})');
      }
    } on TimeoutException {
      _useLocalPrediction();
      setState(() =>
          _errorMessage = 'Tiempo de espera agotado. Usando predicción local.');
    } on SocketException {
      _useLocalPrediction();
      setState(
          () => _errorMessage = 'Problema de conexión. Verifica tu internet.');
    } catch (e) {
      _useLocalPrediction();
      setState(() => _errorMessage = 'Error inesperado: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _useLocalPrediction() {
    final name = _nameController.text.trim().toLowerCase();
    final femaleEndings = ['a', 'e', 'i', 'á', 'é', 'í'];
    final lastChar = name.isNotEmpty ? name[name.length - 1] : '';

    setState(() {
      _gender = femaleEndings.contains(lastChar) ? 'female' : 'male';
      _probability = 70.0;
    });
  }

  bool _isValidInput(String input) {
    if (input.isEmpty) return false;
    if (input.length < 3 || input.length > 20) return false;
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(input);
  }

  bool get _isButtonEnabled {
    return _isValidInput(_nameController.text);
  }

  void _resetPrediction() {
    setState(() {
      _gender = '';
      _probability = 0.0;
      _errorMessage = '';
    });
    _nameController.clear();
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
        title: const Text('Predicción de Género'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Descubre el género probable',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa un nombre y nuestro sistema predecirá si es masculino o femenino '
              'basado en datos estadísticos. Solo letras, entre 3 y 20 caracteres.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _nameController,
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _resetPrediction();
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Ingresa un nombre',
                hintText: 'Ejemplo: María o Carlos',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                suffixIcon: _nameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _nameController.clear();
                          _resetPrediction();
                        },
                      )
                    : null,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                LengthLimitingTextInputFormatter(20),
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
                      _errorMessage.contains('local')
                          ? Icons.warning_amber
                          : Icons.error_outline,
                      color: _errorMessage.contains('local')
                          ? Colors.orange
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: _errorMessage.contains('local')
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isButtonEnabled && !_isLoading ? _predictGender : null,
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
                        'Determinar género',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            GenderCard(
              gender: _gender,
              probability: _probability,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
