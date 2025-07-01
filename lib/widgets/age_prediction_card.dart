import 'package:flutter/material.dart';

class AgeCard extends StatelessWidget {
  final int age;
  final String ageGroup;
  final bool isLoading;

  const AgeCard({
    super.key,
    required this.age,
    required this.ageGroup,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath;
    Color backgroundColor;
    Color textColor;
    String mainMessage;
    String ageMessage;

    if (isLoading) {
      imagePath = 'assets/images/empty.png';
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      mainMessage = 'Analizando...';
      ageMessage = '';
    } else if (ageGroup.isEmpty) {
      imagePath = 'assets/images/empty.png';
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      mainMessage = 'Aún está vacío';
      ageMessage = '';
    } else {
      // Asignar imagen y colores según grupo de edad
      switch (ageGroup) {
        case 'Niño':
          imagePath = 'assets/images/child.png';
          backgroundColor = const Color(0xFFE8F5E9); // Verde claro
          textColor = const Color(0xFF2E7D32); // Verde oscuro
          break;
        case 'Joven':
          imagePath = 'assets/images/young.png';
          backgroundColor = const Color(0xFFE3F2FD); // Azul claro
          textColor = const Color(0xFF1565C0); // Azul oscuro
          break;
        case 'Adulto':
          imagePath = 'assets/images/adult.png';
          backgroundColor = const Color(0xFFEDE7F6); // Morado claro
          textColor = const Color(0xFF4527A0); // Morado oscuro
          break;
        case 'Anciano':
          imagePath = 'assets/images/elderly.png';
          backgroundColor = const Color(0xFFFFF8E1); // Amarillo claro
          textColor = const Color(0xFFF57F17); // Amarillo oscuro
          break;
        default:
          imagePath = 'assets/images/empty.png';
          backgroundColor = Colors.grey.shade200;
          textColor = Colors.grey.shade800;
      }
      mainMessage = 'Grupo: $ageGroup';
      ageMessage = 'Edad estimada: $age años';
    }

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    if (ageMessage.isNotEmpty) ...[
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
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          ageMessage,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                    if (age > 0) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: age / 100, // Asumiendo que 100 es la edad máxima
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