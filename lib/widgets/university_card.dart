import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityCard extends StatelessWidget {
  final String name;
  final List<String> domains;
  final List<String> webPages;
  final Color cardColor;

  const UniversityCard({
    super.key,
    required this.name,
    required this.domains,
    required this.webPages,
    this.cardColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (domains.isNotEmpty) ...[
              const Text(
                'Dominio:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(domains.first),
              const SizedBox(height: 12),
            ],
            
            if (webPages.isNotEmpty)
              InkWell(
                onTap: () => _launchUrl(webPages.first),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sitio web:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      webPages.first,
                      style: TextStyle(
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}