import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';

class LectureScreen extends StatelessWidget {
  const LectureScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<LanguageController>(context).strings;

    // Lecture Data (Title, Subtitle, URL)
    final lectures = [
      {
        'title': strings.subjectArch,
        'subtitle': strings.lectureDescArch,
        'url': 'https://inf.run/BedRr',
        'icon': Icons.memory,
        'color': Colors.blueGrey,
      },
      {
        'title': strings.subjectOS,
        'subtitle': strings.lectureDescOS,
        'url': 'https://inf.run/RWY19',
        'icon': Icons.settings_system_daydream,
        'color': AppColors.accentRed,
      },
      {
        'title': strings.subjectNetwork,
        'subtitle': strings.lectureDescNetwork,
        'url': 'https://inf.run/6ffJb',
        'icon': Icons.hub,
        'color': AppColors.accentCyan,
      },
      {
        'title': strings.subjectDB,
        'subtitle': strings.lectureDescDB,
        'url': 'https://inf.run/XnimG',
        'icon': Icons.storage,
        'color': const Color(0xFFFFCC00),
      },
      {
        'title': strings.subjectDS,
        'subtitle': strings.lectureDescDS,
        'url': 'https://inf.run/m8Q51',
        'icon': Icons.layers,
        'color': Colors.green,
      },
      {
        'title': strings.subjectJava,
        'subtitle': strings.lectureDescJava,
        'url': 'https://inf.run/gfGbQ',
        'icon': Icons.coffee,
        'color': Colors.orange,
      },
      {
        'title': strings.subjectJs,
        'subtitle': strings.lectureDescJs,
        'url': 'https://inf.run/KYbEj',
        'icon': Icons.code,
        'color': Colors.yellow,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                strings.lectureScreenTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.lectureScreenSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lectures.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lecture = lectures[index];
                  return _buildLectureCard(
                    title: lecture['title'] as String,
                    subtitle: lecture['subtitle'] as String,
                    url: lecture['url'] as String,
                    icon: lecture['icon'] as IconData,
                    color: lecture['color'] as Color,
                  );
                },
              ),
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLectureCard({
    required String title,
    required String subtitle,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchUrl(url),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white10, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
