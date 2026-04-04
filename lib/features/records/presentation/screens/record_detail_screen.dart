import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../training/domain/models/training_session_model.dart';
import '../../../training/presentation/screens/training_flow_screen.dart';
import '../../../interview/data/repositories/interview_repository.dart';
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

            // ── Evaluation (visual first) ──
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

              // ── Feedback Card (Improvement + main checklist subtly) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eval.improvementTip != null) ...[
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
                    // Main checklist — subtly listed, no section title
                    if (eval.mainChecklist.isNotEmpty) ...[
                      if (eval.improvementTip != null)
                        const SizedBox(height: 12),
                      _checklistContent(eval.mainChecklist),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── My Answers (individual expandable previews) ──
            _expandableAnswer(strings.myAnswerStepA, session.stepA),
            const SizedBox(height: 8),
            _expandableAnswer(strings.myAnswerStepB, session.stepB),
            const SizedBox(height: 8),
            _expandableAnswer(strings.myAnswerStepC, session.stepC),
            const SizedBox(height: 24),

            // ── Follow-up Q&A (visible) ──
            if (session.aiFollowUpQuestion != null) ...[
              Row(
                children: [
                  Icon(Icons.psychology,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    strings.followUpQuestionLabel,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
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
                    height: 1.5,
                  ),
                ),
              ),
              if (session.userFollowUpAnswer != null) ...[
                const SizedBox(height: 8),
                _answerContent(session.userFollowUpAnswer!),
              ],
              // Follow-up checklist (separate from main)
              if (eval != null && eval.followUpChecklist.isNotEmpty) ...[
                const SizedBox(height: 8),
                _checklistContent(eval.followUpChecklist),
              ],
            ],

            const SizedBox(height: 32),

            // Retry Training Button
            if (session.questionId.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final question = await InterviewRepository()
                        .fetchQuestionById(session.questionId);
                    if (question != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TrainingFlowScreen(question: question),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.questionNotFound),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.replay, size: 18),
                  label: Text(
                    strings.retryTraining,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
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

  Widget _expandableAnswer(String label, String answer) {
    return _ExpandableAnswerCard(label: label, answer: answer);
  }

  Widget _answerContent(String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        answer,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _checklistContent(List<ChecklistItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((ci) => Padding(
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
              ))
          .toList(),
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

/// A card that shows the first line of an answer with "..."
/// and expands to the full answer on tap.
class _ExpandableAnswerCard extends StatefulWidget {
  final String label;
  final String answer;

  const _ExpandableAnswerCard({required this.label, required this.answer});

  @override
  State<_ExpandableAnswerCard> createState() => _ExpandableAnswerCardState();
}

class _ExpandableAnswerCardState extends State<_ExpandableAnswerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.textDisabled.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedCrossFade(
              firstChild: Text(
                widget.answer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              secondChild: Text(
                widget.answer,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
