import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final List<String> _cities = [
    'Santo Domingo',
    'Santiago',
    'La Vega',
    'San Pedro de Macorís',
    'Puerto Plata',
    'La Romana',
    'San Cristóbal',
    'Higüey',
    'San Francisco de Macorís',
    'Baní',
    'Azua',
    'Moca',
    'Barahona',
    'Bonao',
    'San Juan de la Maguana',
    'Hato Mayor',
    'Nagua',
    'Salcedo',
    'Jarabacoa',
    'Constanza',
    'Pedernales',
    'El Seibo',
    'Monte Plata',
    'Dajabón',
    'Comendador',
    'Montecristi',
    'Samaná',
    'Las Terrenas',
    'Bayaguana',
    'Villa Altagracia'
  ];

  final Map<String, Map<String, double>> _cityCoordinates = {
    'Santo Domingo': {'lat': 18.4861, 'lon': -69.9312},
    'Santiago': {'lat': 19.4500, 'lon': -70.7000},
    'La Vega': {'lat': 19.2225, 'lon': -70.5294},
    'San Pedro de Macorís': {'lat': 18.4667, 'lon': -69.3000},
    'Puerto Plata': {'lat': 19.7950, 'lon': -70.6944},
    'La Romana': {'lat': 18.4273, 'lon': -68.9729},
    'San Cristóbal': {'lat': 18.4167, 'lon': -70.1000},
    'Higüey': {'lat': 18.6167, 'lon': -68.7000},
    'San Francisco de Macorís': {'lat': 19.3000, 'lon': -70.2500},
    'Baní': {'lat': 18.2833, 'lon': -70.3333},
    'Azua': {'lat': 18.4500, 'lon': -70.7333},
    'Moca': {'lat': 19.3833, 'lon': -70.5167},
    'Barahona': {'lat': 18.2000, 'lon': -71.1000},
    'Bonao': {'lat': 18.9333, 'lon': -70.4000},
    'San Juan de la Maguana': {'lat': 18.8000, 'lon': -71.2333},
    'Hato Mayor': {'lat': 18.7667, 'lon': -69.2500},
    'Nagua': {'lat': 19.3833, 'lon': -69.8500},
    'Salcedo': {'lat': 19.4167, 'lon': -70.3833},
    'Jarabacoa': {'lat': 19.1167, 'lon': -70.6333},
    'Constanza': {'lat': 18.9167, 'lon': -70.7500},
    'Pedernales': {'lat': 18.0333, 'lon': -71.7500},
    'El Seibo': {'lat': 18.7667, 'lon': -69.0333},
    'Monte Plata': {'lat': 18.8000, 'lon': -69.7833},
    'Dajabón': {'lat': 19.5500, 'lon': -71.7000},
    'Comendador': {'lat': 18.8667, 'lon': -71.7000},
    'Montecristi': {'lat': 19.8500, 'lon': -71.6500},
    'Samaná': {'lat': 19.2000, 'lon': -69.3333},
    'Las Terrenas': {'lat': 19.3167, 'lon': -69.5333},
    'Bayaguana': {'lat': 18.7500, 'lon': -69.6333},
    'Villa Altagracia': {'lat': 18.6667, 'lon': -70.1667},
  };

  String _selectedCity = 'Santo Domingo';
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _useCelsius = true;

  @override
  void initState() {
    super.initState();
    final coords = _cityCoordinates[_selectedCity]!;
    _fetchWeatherWithOpenMeteo(coords['lat']!, coords['lon']!);
  }

  Future<void> _fetchWeatherWithOpenMeteo(double lat, double lon) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,weathercode&timezone=auto';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al obtener el clima. Código: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Despejado';
      case 1:
        return 'Mayormente despejado';
      case 2:
        return 'Parcialmente nublado';
      case 3:
        return 'Nublado';
      case 45:
      case 48:
        return 'Niebla';
      case 51:
      case 53:
      case 55:
        return 'Llovizna';
      case 56:
      case 57:
        return 'Llovizna helada';
      case 61:
      case 63:
      case 65:
        return 'Lluvia';
      case 66:
      case 67:
        return 'Lluvia helada';
      case 71:
      case 73:
      case 75:
        return 'Nieve';
      case 77:
        return 'Granizo';
      case 80:
      case 81:
      case 82:
        return 'Lluvias intensas';
      case 85:
      case 86:
        return 'Nevadas intensas';
      case 95:
      case 96:
      case 99:
        return 'Tormenta eléctrica';
      default:
        return 'Condición desconocida';
    }
  }

Widget _getWeatherIcon(int weatherCode) {
  final iconSize = 60.0;

  switch (weatherCode) {
    case 0:
      return Image.asset('assets/images/sun.png', width: iconSize, height: iconSize);
    case 1:
      return Image.asset('assets/images/cloud_sun.png', width: iconSize, height: iconSize);
    case 2:
    case 3:
      return Image.asset('assets/images/cloud.png', width: iconSize, height: iconSize);
    case 45:
    case 48:
      return Image.asset('assets/images/fog.png', width: iconSize, height: iconSize);
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return Image.asset('assets/images/rain.png', width: iconSize, height: iconSize);
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
      return Image.asset('assets/images/heavy_rain.png', width: iconSize, height: iconSize);
    case 71:
    case 73:
    case 75:
    case 77:
      return Image.asset('assets/images/snow.png', width: iconSize, height: iconSize);
    case 80:
    case 81:
    case 82:
      return Image.asset('assets/images/cloud_rain.png', width: iconSize, height: iconSize);
    case 85:
    case 86:
      return Image.asset('assets/images/snowman.png', width: iconSize, height: iconSize);
    case 95:
    case 96:
    case 99:
      return Image.asset('assets/images/thunderstorm.png', width: iconSize, height: iconSize);
    default:
      return Image.asset('assets/images/unknown.png', width: iconSize, height: iconSize);
  }
}
  double _getTemperature(double temp) {
    return _useCelsius ? temp : (temp * 9 / 5) + 32;
  }

  Widget _buildWeatherCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      );
    } else if (_weatherData == null || _weatherData!['current_weather'] == null) {
      return const Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      final currentWeather = _weatherData!['current_weather'];
      final weatherCode = currentWeather['weathercode'];
      final temperature = _getTemperature(currentWeather['temperature']);
      final windSpeed = currentWeather['windspeed'];

      return Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedCity,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              _getWeatherIcon(weatherCode),
              const SizedBox(height: 10),
              Text(
                _getWeatherDescription(weatherCode),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${temperature.toStringAsFixed(1)}°${_useCelsius ? 'C' : 'F'}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const FaIcon(FontAwesomeIcons.wind, size: 20),
                      const SizedBox(height: 5),
                      Text(
                        '$windSpeed km/h',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const FaIcon(FontAwesomeIcons.temperatureHalf, size: 20),
                      const SizedBox(height: 5),
                      Text(
                        _useCelsius ? 'Celsius' : 'Fahrenheit',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima en República Dominicana'),
        actions: [
          IconButton(
            icon: Icon(_useCelsius ? FontAwesomeIcons.temperatureLow : FontAwesomeIcons.temperatureHigh),
            onPressed: () {
              setState(() {
                _useCelsius = !_useCelsius;
              });
            },
            tooltip: 'Cambiar a ${_useCelsius ? 'Fahrenheit' : 'Celsius'}',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consulta el clima actual',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              items: _cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value!;
                });
                final coords = _cityCoordinates[_selectedCity]!;
                _fetchWeatherWithOpenMeteo(coords['lat']!, coords['lon']!);
              },
              decoration: const InputDecoration(
                labelText: 'Seleccione una ciudad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 20),
            _buildWeatherCard(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Datos proporcionados por Open-Meteo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}