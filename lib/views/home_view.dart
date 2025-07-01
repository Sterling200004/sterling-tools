import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_card.dart';
import '../routes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Alignment> _imageAlignmentAnimation;
  late Animation<double> _imageSizeAnimation;
  bool _showInitialImage = true;
  bool _showContent = false;

  final List<Map<String, dynamic>> cardItems = [
    {
      'icon': Icons.transgender,
      'title': 'Predicción de Género',  
      'subtitle': 'Ingresa un nombre y descubre su género probable.',
      'routeName': AppRoutes.genderPrediction, // Usamos el nombre de ruta
      'enabled': true, // Nuevo campo para controlar estado
    },
    {
      'icon': Icons.cake_outlined,
      'title': 'Predicción de Edad',
      'subtitle': 'Obtén la edad aproximada con una imagen y mensaje ilustrativo.',
      'routeName': AppRoutes.agePrediction, // Usamos el nombre de ruta
      'enabled': true,
    },
    {
      'icon': Icons.school_outlined,
      'title': 'Universidades por País',
      'subtitle': 'Consulta universidades de cualquier país ingresado.',
      'routeName': AppRoutes.universities, // Usamos el nombre de ruta
      'enabled': true,
    },
    {
      'icon': Icons.cloud_outlined,
      'title': 'Clima en RD',
      'subtitle': 'Muestra el clima actual en República Dominicana.',
      'routeName': AppRoutes.weather, // Usamos el nombre de ruta
      'enabled': true,
    },
    {
      'icon': Icons.catching_pokemon_outlined,
      'title': 'Datos de Pokémon',
      'subtitle': 'Foto, experiencia, habilidades y sonido del Pokémon.',
      'routeName': AppRoutes.pokemon, // Usamos el nombre de ruta
      'enabled': true,
    },
    {
      'icon': Icons.article_outlined,
      'title': 'Noticias WordPress',
      'subtitle': 'Últimos titulares de una web hecha con WordPress.',
      'routeName': AppRoutes.hipertextual, // Usamos el nombre de ruta
      'enabled': true,
    },
    {
      'icon': Icons.person_outline,
      'title': 'Acerca de Mí',
      'subtitle': 'Foto personal, contacto y más sobre el desarrollador.',
      'routeName': AppRoutes.about, // Usamos el nombre de ruta
      'enabled': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Configurar el controlador de animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Duración de la transición
    );

    // Mostrar la imagen inicial por 2 segundos antes de animar
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showInitialImage = false;
        });
        _animationController.forward().then((_) {
          setState(() {
            _showContent = true;
          });
        });
      }
    });

    // Configurar animaciones
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _imageAlignmentAnimation = Tween<Alignment>(
      begin: Alignment.center,
      end: Alignment.topCenter,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _imageSizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Imagen inicial en pantalla completa (por 2 segundos)
            if (_showInitialImage)
              Center(
                child: Image.asset(
                  'assets/images/tool.png',
                  height: screenHeight * 0.5,
                  fit: BoxFit.contain,
                ),
              ),

            // Animación de transición de la imagen
            if (!_showInitialImage && !_showContent)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Align(
                    alignment: _imageAlignmentAnimation.value,
                    child: Transform.scale(
                      scale: _imageSizeAnimation.value,
                      child: Image.asset(
                        'assets/images/tool.png',
                        height: screenHeight * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

            // Contenido principal (aparece después de completar la animación)
            if (_showContent)
              Opacity(
                opacity: _fadeAnimation.value,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Sterling Tools',
                          style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontSize: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Image.asset(
                          'assets/images/tool.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        _buildCardList(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cardItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cardItems[index];
        return CustomCard(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          enabled:
              item['enabled'] ?? false, // Usamos el operador null-coalescing
          onTap: item.containsKey('routeName')
              ? () => Navigator.pushNamed(context, item['routeName'] as String)
              : null,
        );
      },
    );
  }
}
