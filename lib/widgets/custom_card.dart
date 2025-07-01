import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final color = enabled
            ? Theme.of(context).colorScheme.primary
            : Colors.grey;

        return Padding(
          padding: isSmallScreen
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
              : const EdgeInsets.all(8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: enabled ? null : Colors.grey.shade100,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: isSmallScreen
                    ? const EdgeInsets.all(8.0)
                    : const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: isSmallScreen ? 70 : 80,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: isSmallScreen ? 24 : 28,
                        color: color,
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 15,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: enabled ? Colors.grey[600] : Colors.grey[400],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: isSmallScreen ? 18 : 20,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}