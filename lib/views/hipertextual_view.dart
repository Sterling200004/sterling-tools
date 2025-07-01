import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/news_card.dart';

class HipertextualView extends StatefulWidget {
  const HipertextualView({super.key});

  @override
  State<HipertextualView> createState() => _HipertextualViewState();
}

class _HipertextualViewState extends State<HipertextualView> {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _siteLogoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Primero obtenemos la información del sitio
      final siteResponse = await http
          .get(
            Uri.parse('https://hipertextual.com/wp-json/'),
          )
          .timeout(const Duration(seconds: 15));

      if (siteResponse.statusCode == 200) {
        final siteData = json.decode(siteResponse.body);
        setState(() {
          _siteLogoUrl = siteData['site_icon_url'] ?? '';
        });
      }

      // Luego obtenemos las noticias
      final newsResponse = await http
          .get(
            Uri.parse(
                'https://hipertextual.com/wp-json/wp/v2/posts?per_page=3'),
          )
          .timeout(const Duration(seconds: 15));

      if (newsResponse.statusCode == 200) {
        final newsData = json.decode(newsResponse.body);
        setState(() => _news = newsData);
      } else {
        setState(() => _errorMessage =
            'Error al cargar noticias (Código ${newsResponse.statusCode})');
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

  Future<void> _refreshNews() async {
    await _fetchNews();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hipertextual - Últimas Noticias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNews,
            tooltip: 'Actualizar noticias',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNews,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Hipertextual',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Descripción
              const Text(
                'Las últimas noticias sobre tecnología, ciencia y cultura digital.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Logo
              Center(
                child: _siteLogoUrl.isNotEmpty
                    ? Image.network(
                        _siteLogoUrl,
                        height: 80,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.public, size: 60),
                      )
                    : const Icon(Icons.public, size: 60),
              ),
              const SizedBox(height: 32),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_news.isEmpty)
                const Center(
                  child: Text(
                    'No se encontraron noticias recientes',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              else
                Column(
                  children: [
                    const Text(
                      'Últimas Noticias',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._news.map((news) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: NewsCard(
                            title: news['title']['rendered'] ?? 'Sin título',
                            excerpt: _cleanHtmlTags(
                                news['excerpt']['rendered'] ?? 'Sin resumen'),
                            imageUrl: news['jetpack_featured_media_url'],
                            url: news['link'],
                            onTap: () => _launchUrl(news['link']),
                          ),
                        )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanHtmlTags(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\[&hellip;\]'), '...')
        .trim();
  }
}
