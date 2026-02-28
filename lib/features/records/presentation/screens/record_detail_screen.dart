import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../training/domain/models/training_session_model.dart';
import '../../../home/presentation/widgets/radar_chart_widget.dart';

/// Detail screen for a completed training session.
class RecordDetailScreen extends StatelessWidget {
  final TrainingSession session;

  const RecordDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<LanguageController>(context).strings;
    final eval = session.evaluation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(strings.recordDetailTitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.subject} · ${session.category}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.questionText,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3-Step Answers
            _answerSection(strings.myAnswerStepA, session.stepA),
            const SizedBox(height: 12),
            _answerSection(strings.myAnswerStepB, session.stepB),
            const SizedBox(height: 12),
            _answerSection(strings.myAnswerStepC, session.stepC),
            const SizedBox(height: 24),

            // Follow-up Q&A
            if (session.aiFollowUpQuestion != null) ...[
              _sectionTitle(strings.followUpQuestionLabel, Icons.psychology),
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
                  session.aiFollowUpQuestion!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (session.userFollowUpAnswer != null)
                _answerSection(
                    strings.followUpAnswerEval, session.userFollowUpAnswer!),
              const SizedBox(height: 24),
            ],

            // Evaluation
            if (eval != null) ...[
              // Grade
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gradeColor(eval.grade).withValues(alpha: 0.15),
                        border: Border.all(
                            color: _gradeColor(eval.grade), width: 3),
                      ),
                      child: Center(
                        child: Text(
                          eval.grade,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _gradeColor(eval.grade),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${strings.totalScoreLabel}: ${eval.totalScore}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Radar
              Center(
                child: RadarChartWidget(
                  scores: eval.axisScores,
                  labels: [
                    strings.axisSummary,
                    strings.axisPrinciple,
                    strings.axisExample,
                    strings.axisKeyword,
                    strings.axisClarity,
                    strings.axisFollowUp,
                  ],
                  size: 200,
                ),
              ),
              const SizedBox(height: 24),

              // Checklist
              _checklistSection(strings.mainAnswerEval, eval.mainChecklist),
              const SizedBox(height: 12),
              _checklistSection(
                  strings.followUpAnswerEval, eval.followUpChecklist),
              const SizedBox(height: 16),

              // Improvement
              if (eval.improvementTip != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: AppColors.accentGreen, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            strings.improvementPointsLabel,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        eval.improvementTip!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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

  Widget _answerSection(String title, String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.textDisabled.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistSection(String title, List<ChecklistItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.textDisabled.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((ci) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      ci.passed ? Icons.check_circle : Icons.cancel,
                      color: ci.passed
                          ? AppColors.accentGreen
                          : AppColors.accentRed,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ci.criterion,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textPrimary)),
                          if (ci.comment != null && ci.comment!.isNotEmpty)
                            Text(ci.comment!,
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return AppColors.accentGreen;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      default:
        return AppColors.accentRed;
    }
  }
}
