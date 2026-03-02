import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../interview/domain/models/question_model.dart';
import '../screens/training_flow_screen.dart';

/// Quick view screen: answer, keywords, tip — no AI, local data only.
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
        scrolledUnderElevation: 0,
        title: Text(strings.quickViewTitle,
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Question ──
                  Text(
                    question.getLocalizedQuestion(langCode),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Model Answer ──
                  if (answer.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.description_outlined,
                      iconColor: AppColors.primary,
                      title: strings.keySummary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      answer,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Keywords ──
                  if (keywords.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.key_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: strings.keyKeywords,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: keywords
                          .map((k) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(k,
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Tip ──
                  if (tip.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: strings.interviewTip,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.textDisabled.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainingFlowScreen(question: question),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(strings.startTrainingCTA,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: Colors.yellow, size: 13),
                          Text('1',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal section header: emoji + title.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionHeader(
      {required this.icon, required this.iconColor, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
