import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../interview/presentation/screens/subject_questions_screen.dart';

class LectureScreen extends StatelessWidget {
  const LectureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch ThemeController to rebuild on theme change
    context.watch<ThemeController>();
    final strings = Provider.of<LanguageController>(context).strings;

    // Subject Data (same 7 subjects as Home, with lecture URLs)
    final subjects = [
      {
        'id': 'computer_architecture',
        'title': strings.subjectArch,
        'subtitle': strings.lectureDescArch,
        'url': 'https://inf.run/BedRr',
        'icon': Icons.memory,
        'color': Colors.blueGrey,
      },
      {
        'id': 'operating_system',
        'title': strings.subjectOS,
        'subtitle': strings.lectureDescOS,
        'url': 'https://inf.run/RWY19',
        'icon': Icons.settings_system_daydream,
        'color': AppColors.accentRed,
      },
      {
        'id': 'network',
        'title': strings.subjectNetwork,
        'subtitle': strings.lectureDescNetwork,
        'url': 'https://inf.run/6ffJb',
        'icon': Icons.hub,
        'color': AppColors.accentCyan,
      },
      {
        'id': 'database',
        'title': strings.subjectDB,
        'subtitle': strings.lectureDescDB,
        'url': 'https://inf.run/XnimG',
        'icon': Icons.storage,
        'color': const Color(0xFFFFCC00),
      },
      {
        'id': 'data_structure',
        'title': strings.subjectDS,
        'subtitle': strings.lectureDescDS,
        'url': 'https://inf.run/m8Q51',
        'icon': Icons.layers,
        'color': Colors.green,
      },
      {
        'id': 'java',
        'title': strings.subjectJava,
        'subtitle': strings.lectureDescJava,
        'url': 'https://inf.run/gfGbQ',
        'icon': Icons.coffee,
        'color': Colors.orange,
      },
      {
        'id': 'javascript',
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.lectureScreenSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _buildSubjectCard(
                    context: context,
                    id: subject['id'] as String,
                    title: subject['title'] as String,
                    subtitle: subject['subtitle'] as String,
                    lectureUrl: subject['url'] as String,
                    icon: subject['icon'] as IconData,
                    color: subject['color'] as Color,
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

  Widget _buildSubjectCard({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required String lectureUrl,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.textDisabled.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectQuestionsScreen(
                  subjectId: id,
                  subjectName: title,
                  themeColor: color,
                  icon: icon,
                  lectureUrl: lectureUrl,
                ),
              ),
            );
          },
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
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: AppColors.textTertiary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
