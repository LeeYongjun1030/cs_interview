import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../interview/presentation/screens/subject_questions_screen.dart';

/// Training tab — subject list for starting training.
class TrainingTab extends StatelessWidget {
  const TrainingTab({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final strings = Provider.of<LanguageController>(context).strings;

    final subjects = [
      {
        'id': 'computer_architecture',
        'title': strings.subjectArch,
        'subtitle': strings.lectureDescArch,
        'icon': Icons.memory,
        'color': Colors.blueGrey,
      },
      {
        'id': 'operating_system',
        'title': strings.subjectOS,
        'subtitle': strings.lectureDescOS,
        'icon': Icons.settings_system_daydream,
        'color': AppColors.accentRed,
      },
      {
        'id': 'network',
        'title': strings.subjectNetwork,
        'subtitle': strings.lectureDescNetwork,
        'icon': Icons.hub,
        'color': AppColors.accentCyan,
      },
      {
        'id': 'database',
        'title': strings.subjectDB,
        'subtitle': strings.lectureDescDB,
        'icon': Icons.storage,
        'color': const Color(0xFFFFCC00),
      },
      {
        'id': 'data_structure',
        'title': strings.subjectDS,
        'subtitle': strings.lectureDescDS,
        'icon': Icons.layers,
        'color': Colors.green,
      },
      {
        'id': 'java',
        'title': strings.subjectJava,
        'subtitle': strings.lectureDescJava,
        'icon': Icons.coffee,
        'color': Colors.orange,
      },
      {
        'id': 'javascript',
        'title': strings.subjectJs,
        'subtitle': strings.lectureDescJs,
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
                strings.trainingTabTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.selectSubjectToTrain,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = subjects[index];
                  return _SubjectCard(
                    id: s['id'] as String,
                    title: s['title'] as String,
                    subtitle: s['subtitle'] as String,
                    icon: s['icon'] as IconData,
                    color: s['color'] as Color,
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SubjectCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
                builder: (_) => SubjectQuestionsScreen(
                  subjectId: id,
                  subjectName: title,
                  themeColor: color,
                  icon: icon,
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
