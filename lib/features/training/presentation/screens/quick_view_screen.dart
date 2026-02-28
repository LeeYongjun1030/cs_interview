import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../interview/domain/models/question_model.dart';
import '../screens/training_flow_screen.dart';

/// Quick view screen: summary, keywords, tips, reference answer.
/// AI-free — uses local question data only.
class QuickViewScreen extends StatelessWidget {
  final Question question;

  const QuickViewScreen({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<LanguageController>(context).strings;
    final langCode =
        Provider.of<LanguageController>(context).currentLanguage.code;

    final answer = question.getLocalizedAnswer(langCode);
    final keywords = question.getLocalizedKeywords(langCode);
    final tip = question.getLocalizedTip(langCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(strings.quickViewTitle,
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                question.getLocalizedQuestion(langCode),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Summary (= answer)
            if (answer.isNotEmpty) ...[
              _sectionTitle(strings.keySummary, Icons.summarize),
              const SizedBox(height: 8),
              _contentCard(answer),
              const SizedBox(height: 20),
            ],

            // Keywords
            if (keywords.isNotEmpty) ...[
              _sectionTitle(strings.keyKeywords, Icons.label_outline),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: keywords
                    .map((k) => Chip(
                          label: Text(k,
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 12)),
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Tip
            if (tip.isNotEmpty) ...[
              _sectionTitle(strings.interviewTip, Icons.lightbulb_outline),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  tip,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 20),

            // CTA: Start Training
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainingFlowScreen(question: question),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note),
                label: Text(strings.startTrainingCTA,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _contentCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.textDisabled.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }
}
