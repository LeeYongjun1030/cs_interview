import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../training/domain/models/training_session_model.dart';
import '../../../training/presentation/screens/training_flow_screen.dart';
import '../../../interview/data/repositories/interview_repository.dart';
import '../../../interview/domain/models/question_model.dart';

/// Detail screen for a completed training session.
class RecordDetailScreen extends StatelessWidget {
  final TrainingSession session;

  const RecordDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<LanguageController>(context).strings;
    final fb = session.feedback;

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
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.question,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary)),
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
            const SizedBox(height: 20),

            // Score
            if (fb != null) ...[
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _scoreColor(fb.score).withValues(alpha: 0.15),
                    border:
                        Border.all(color: _scoreColor(fb.score), width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '${fb.score}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(fb.score),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Strengths
              if (fb.strengths.isNotEmpty) ...[
                _sectionLabel(Icons.check_circle, strings.strengthsLabel,
                    AppColors.accentGreen),
                const SizedBox(height: 8),
                ...fb.strengths
                    .map((s) => _feedbackItem(s, AppColors.accentGreen)),
                const SizedBox(height: 14),
              ],

              // Improvements
              if (fb.improvements.isNotEmpty) ...[
                _sectionLabel(Icons.warning_amber, strings.improvementsLabel,
                    Colors.orange),
                const SizedBox(height: 8),
                ...fb.improvements
                    .map((s) => _feedbackItem(s, Colors.orange)),
                const SizedBox(height: 14),
              ],

              // Missing Keywords
              if (fb.missingKeywords.isNotEmpty) ...[
                _sectionLabel(Icons.vpn_key, strings.missingKeywordsLabel,
                    AppColors.primary),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: fb.missingKeywords
                      .map((kw) => Chip(
                            label: Text(kw,
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.accentRed)),
                            backgroundColor:
                                AppColors.accentRed.withValues(alpha: 0.08),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
              ],
            ],

            // My Answer
            _sectionLabel(
                Icons.edit_note, strings.myAnswerLabel, AppColors.textSecondary),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.textDisabled.withValues(alpha: 0.15)),
              ),
              child: Text(
                session.userAnswer.isEmpty
                    ? strings.skippedTrainingLabel
                    : session.userAnswer,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: session.userAnswer.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontStyle: session.userAnswer.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Original Question Model Answer
            FutureBuilder<Question?>(
              future: InterviewRepository().fetchQuestionById(session.questionId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink();
                }
                final langCode = Provider.of<LanguageController>(context, listen: false).currentLanguage.code;
                final modelAnswer = snapshot.data!.getLocalizedAnswer(langCode);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(Icons.menu_book, strings.referenceAnswerLabel, AppColors.accentGreen),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accentGreen.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        modelAnswer,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),

            // Follow-up Q&A
            if (session.aiFollowUpQuestion != null) ...[
              _sectionLabel(
                  Icons.psychology,
                  (session.userFollowUpAnswer == null ||
                          session.userFollowUpAnswer!.isEmpty)
                      ? strings.skippedFollowUpLabel
                      : strings.followUpQuestionLabel,
                  Colors.orange),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  session.aiFollowUpQuestion!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),

              // User follow-up answer (Only if they wrote something)
              if (session.userFollowUpAnswer != null &&
                  session.userFollowUpAnswer!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _sectionLabel(Icons.edit_note, strings.myAnswerLabel,
                    AppColors.textSecondary),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.textDisabled.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    session.userFollowUpAnswer!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              // Follow-up model answer
              if (session.aiFollowUpModelAnswer != null) ...[
                const SizedBox(height: 10),
                _sectionLabel(Icons.menu_book, strings.referenceAnswerLabel,
                    AppColors.accentGreen),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    session.aiFollowUpModelAnswer!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],

            // Retry Training Button
            if (session.questionId.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final repo = Provider.of<InterviewRepository>(context,
                        listen: false);
                    final q = await repo.fetchQuestionById(session.questionId);
                    if (q != null && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrainingFlowScreen(question: q),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  icon: Icon(Icons.refresh, color: AppColors.primary),
                  label: Text(strings.retryTraining,
                      style: TextStyle(color: AppColors.primary)),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _feedbackItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 90) return AppColors.accentGreen;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return AppColors.accentRed;
  }
}
