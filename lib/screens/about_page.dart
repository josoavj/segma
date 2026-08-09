import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  Future<void> _launchURL(String url) async {
    try {
      if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else if (Platform.isWindows) {
        await Process.run('start', [url], runInShell: true);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo/Icon
            Container(
              width: 200,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/logo/Segma.png',
                  width: 200,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: scheme.surfaceContainer,
                      child: Center(
                        child: Icon(
                          Icons.image_search,
                          size: 80,
                          color: scheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'SEGMA',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Image Segmentation with SAM 3',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Version Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Description Card
            _SectionCard(
              title: 'À propos',
              icon: Icons.info_outline,
              iconColor: scheme.primary,
              iconBackgroundColor: scheme.primaryContainer.withValues(alpha: 0.4),
              child: Text(
                'SEGMA est une solution professionnelle de segmentation d\'images '
                'utilisant le modèle SAM 3 de Meta. Elle combine l\'intelligence '
                'artificielle et une interface intuitive pour isoler n\'importe quel '
                'objet avec une précision chirurgicale.\n\n'
                '• Charger et explorer des images\n'
                '• Segmenter les objets par simple clic\n'
                '• Afficher et gérer les résultats\n'
                '• Suivre l\'historique des segmentations\n'
                '• Exporter les données\n'
                '• Consulter les logs d\'activité',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Technologies Card
            _SectionCard(
              title: 'Technologies',
              icon: Icons.auto_awesome_mosaic,
              iconColor: scheme.secondary,
              iconBackgroundColor: scheme.secondaryContainer.withValues(alpha: 0.4),
              child: Column(
                children: [
                  _buildTechCard(
                    context,
                    name: 'Flutter & Dart',
                    description: 'Interface graphique multiplateforme',
                    icon: Icons.bolt,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildTechCard(
                    context,
                    name: 'FastAPI & Python',
                    description: 'Traitement asynchrone haute performance',
                    icon: Icons.api,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  _buildTechCard(
                    context,
                    name: 'Meta SAM 3',
                    description: 'Segment Anything Model de dernière génération',
                    icon: Icons.psychology,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Developers Card
            _SectionCard(
              title: 'Équipe',
              icon: Icons.groups_outlined,
              iconColor: scheme.tertiary,
              iconBackgroundColor: scheme.tertiaryContainer.withValues(alpha: 0.4),
              child: _buildDeveloperCard(
                context,
                name: 'Josoa VONJINIAINA',
                role: 'Fullstack Developer | Lead Architect',
                profileUrl: 'https://github.com/josoavj',
                portfolioUrl: 'https://josoavj-portfolio.vercel.app/',
                imageUrl: 'https://github.com/josoavj.png',
              ),
            ),
            const SizedBox(height: 48),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Divider(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 24),
                  Text(
                    '© 2026 SEGMA Project',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Propulsé par l\'IA de Meta et Flutter',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
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

  Widget _buildTechCard(
    BuildContext context, {
    required String name,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? scheme.surfaceContainerHigh.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String name,
    required String role,
    String? profileUrl,
    String? portfolioUrl,
    String? imageUrl,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? scheme.surfaceContainerHigh.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.person, color: scheme.primary, size: 28),
                ),
              ),
            )
          else
            CircleAvatar(
              radius: 28,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.person, color: scheme.primary, size: 28),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (portfolioUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      color: scheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: () => _launchURL(portfolioUrl),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.language, size: 14, color: scheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Voir mon Portfolio',
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (profileUrl != null)
            IconButton(
              onPressed: () => _launchURL(profileUrl),
              icon: Icon(Icons.open_in_new, color: scheme.primary, size: 20),
              tooltip: 'GitHub',
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? scheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}
