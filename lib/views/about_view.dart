import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir $url')),
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    const phone = '+18096751204'; // Reemplaza con tu número real
    const message =
        'Hola Sterling, estoy interesado en tus servicios de Desarrollo de Software. Observé tu aplicación y me gustaría contactarte.';
    final url = 'https://wa.me/$phone?text=${Uri.encodeFull(message)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  Future<void> _launchEmail() async {
    const email = 'sterlinggarcia32@gmail.com';
    const subject = 'Me interesa contactarte | Sterling Tools - App de Flutter';
    const body = 'Buenas, espero respuestas lo más pronto posible, saludos.';
    final url =
        'mailto:$email?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo abrir la aplicación de correo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Acerca del Desarrollador'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Efecto de levitación
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(76),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: colorScheme.primary.withAlpha(76),
                      child: const CircleAvatar(
                        radius: 75,
                        backgroundImage: AssetImage('assets/images/FOTO.jpg'),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Información personal
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      title: 'Nombre completo',
                      value: 'Sterling José Vásquez G.',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.badge,
                      title: 'Matrícula',
                      value: '2022 - 0260',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.school,
                      title: 'Carrera',
                      value: 'Desarrollo de Software',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Redes sociales
            const Text(
              'Redes Sociales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF1877F2),
                  url: 'https://www.facebook.com/sterling.garcia.919057',
                ),
                const SizedBox(width: 20),
                _buildSocialIcon(
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE1306C),
                  url: 'https://www.instagram.com/sterling_1204/',
                ),
                const SizedBox(width: 20),
                _buildSocialIcon(
                  icon: FontAwesomeIcons.github,
                  color: Colors.black,
                  url: 'https://github.com/Sterling200004/',
                ),
                const SizedBox(width: 20),
                _buildSocialIcon(
                  icon: FontAwesomeIcons.linkedin,
                  color: const Color(0xFF0077B5),
                  url:
                      'https://www.linkedin.com/in/sterling-jos%C3%A9-v%C3%A1squez-garc%C3%ADa-543441227',
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Botones de contacto
            Column(
              children: [
                // Botón de WhatsApp
                ElevatedButton.icon(
                  onPressed: _launchWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20),
                  label: const Text(
                    'Contactar por WhatsApp',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón de Email (actualizado)
                ElevatedButton.icon(
                  onPressed: _launchEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.email),
                  label: const Text(
                    'Contactar por Email',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Icon(icon, size: 24, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: 1 + (value * 0.1),
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withAlpha(76),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: FaIcon(
              icon,
              size: 30,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
