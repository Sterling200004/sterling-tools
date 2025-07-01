import 'package:flutter/material.dart';

class GenderCard extends StatelessWidget {
  final String gender;
  final double probability;
  final bool isLoading;

  const GenderCard({
    super.key,
    required this.gender,
    required this.probability,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath;
    Color backgroundColor;
    Color textColor;
    String mainMessage;
    String probabilityMessage;

    if (isLoading) {
      imagePath = 'assets/images/empty.png';
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      mainMessage = 'Analizando...';
      probabilityMessage = '';
    } else if (gender.isEmpty) {
      imagePath = 'assets/images/empty.png';
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      mainMessage = 'Aún está vacío';
      probabilityMessage = '';
    } else if (gender == 'male') {
      imagePath = 'assets/images/men.png';
      backgroundColor = const Color(0xFFE3F2FD); // Azul claro
      textColor = const Color(0xFF0D47A1); // Azul oscuro
      mainMessage = 'Predicción: Masculino';
      probabilityMessage = 'Probabilidad: ${probability.toStringAsFixed(1)}%';
    } else {
      imagePath = 'assets/images/women.png';
      backgroundColor = const Color(0xFFFCE4EC); // Rosa claro
      textColor = const Color(0xFFC2185B); // Rosa oscuro
      mainMessage = 'Predicción: Femenino';
      probabilityMessage = 'Probabilidad: ${probability.toStringAsFixed(1)}%';
    }

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 0), // Elimina márgenes horizontales
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante para centrado
            children: [
              if (isLoading) 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        mainMessage,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                )
              else 
                Column(
                  children: [
                    Image.asset(
                      imagePath,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      mainMessage,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (probabilityMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.7 * 255).toInt()),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          probabilityMessage,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                    if (gender.isNotEmpty && !isLoading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: probability / 100,
                        backgroundColor: Colors.white.withAlpha((0.4 * 255).toInt()),
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}