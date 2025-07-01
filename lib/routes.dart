import 'package:flutter/material.dart';
import '../views/age_prediction_view.dart';
import '../views/gender_prediction_view.dart';
import '../views/universities_view.dart';
import '../views/weather_view.dart';
import '../views/pokemon_view.dart';
import '../views/hipertextual_view.dart';
import '../views/about_view.dart';
import '../views/home_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String genderPrediction = '/gender-prediction';
  static const String agePrediction = '/age-prediction';
  static const String universities = '/universities';
  static const String weather = '/weather';
  static const String pokemon = '/pokemon';
  static const String hipertextual = '/hipertextual';
  static const String about = '/about';
  // Agregar otras rutas aquí conforme avances

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeView(),
      genderPrediction: (context) => const GenderPredictionView(),
      agePrediction: (context) => const AgePredictionView(),
      universities: (context) => const UniversitiesView(),
      pokemon: (context) => const PokemonView(),
      hipertextual: (context) => const HipertextualView(),
      about: (context) => const AboutView(),
      weather: (context) => const WeatherView(),
    };
  }
}