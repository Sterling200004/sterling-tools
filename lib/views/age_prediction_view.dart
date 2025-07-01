import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import '../widgets/age_prediction_card.dart';

class AgePredictionView extends StatefulWidget {
  const AgePredictionView({super.key});

  @override
  State<AgePredictionView> createState() => _AgePredictionViewState();
}

class _AgePredictionViewState extends State<AgePredictionView> {
  final TextEditingController _nameController = TextEditingController();
  int _age = 0;
  String _ageGroup = '';
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _predictAge() async {
    if (!_isValidInput(_nameController.text)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _age = 0;
      _ageGroup = '';
    });

    try {
      final response = await http
          .get(
            Uri.parse(
                'https://api.agify.io/?name=${_nameController.text.trim()}'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['age'] == null) {
          setState(() =>
              _errorMessage = 'No se pudo determinar la edad para este nombre');
          return;
        }

        final age = data['age'] as int;
        String ageGroup;

        if (age < 13) {
          ageGroup = 'Niño';
        } else if (age < 25) {
          ageGroup = 'Joven';
        } else if (age < 60) {
          ageGroup = 'Adulto';
        } else {
          ageGroup = 'Anciano';
        }

        setState(() {
          _age = age;
          _ageGroup = ageGroup;
        });
      } else if (response.statusCode == 429) {
        setState(() => _errorMessage =
            'Límite de solicitudes alcanzado. Intenta más tarde.');
      } else {
        setState(() => _errorMessage =
            'Error en el servidor (Código ${response.statusCode})');
      }
    } on TimeoutException {
      setState(() =>
          _errorMessage = 'Tiempo de espera agotado. Intenta nuevamente.');
    } on SocketException {
      setState(
          () => _errorMessage = 'Problema de conexión. Verifica tu internet.');
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
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
      _age = 0;
      _ageGroup = '';
      _errorMessage = '';
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
        title: const Text('Predicción de Edad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Descubre la edad probable',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa un nombre y nuestro sistema predecirá la edad aproximada '
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
                      _errorMessage.contains('Verifica')
                          ? Icons.warning_amber
                          : Icons.error_outline,
                      color: _errorMessage.contains('Verifica')
                          ? Colors.orange
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: _errorMessage.contains('Verifica')
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
                onPressed: _isButtonEnabled && !_isLoading ? _predictAge : null,
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
                        'Determinar edad',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            AgeCard(
              age: _age,
              ageGroup: _ageGroup,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
