import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../interview/domain/models/question_model.dart';
import '../providers/training_controller.dart';
import '../../../home/presentation/widgets/radar_chart_widget.dart';
import '../../../monetization/data/repositories/credit_repository.dart';

/// Full training flow screen: Step A → B → C → D (loading) → E → F (result).
class TrainingFlowScreen extends StatefulWidget {
  final Question question;

  const TrainingFlowScreen({super.key, required this.question});

  @override
  State<TrainingFlowScreen> createState() => _TrainingFlowScreenState();
}

class _TrainingFlowScreenState extends State<TrainingFlowScreen> {
  late final TrainingController _controller;
  final _textController = TextEditingController();
  bool _hasEnergy = false; // Becomes true after credit deduction

  @override
  void initState() {
    super.initState();
    _controller = TrainingController();
    _controller.addListener(_onControllerChange);

    // Check and deduct credit after first frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndDeductCredit());
  }

  Future<void> _checkAndDeductCredit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final creditRepo = Provider.of<CreditRepository>(context, listen: false);
    final success = await creditRepo.deductCredit(uid);

    if (!success) {
      if (!mounted) return;
      final strings =
          Provider.of<LanguageController>(context, listen: false).strings;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.notEnoughEnergySnack)),
      );
      Navigator.pop(context);
      return;
    }

    // Credit deducted successfully — start training
    if (mounted) {
      final langCode = Provider.of<LanguageController>(context, listen: false)
          .currentLanguage
          .code;
      _controller.startTraining(widget.question, languageCode: langCode);
      setState(() => _hasEnergy = true);
    }
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Provider.of<LanguageController>(context).strings;
    final langCode =
        Provider.of<LanguageController>(context).currentLanguage.code;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getStepTitle(strings),
          style:
              AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: !_hasEnergy
          ? const Center(child: CircularProgressIndicator())
          : _controller.isLoading
              ? _buildLoadingState()
              : _buildContent(strings, langCode),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _controller.loadingMessage,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppStrings strings, String langCode) {
    switch (_controller.currentStep) {
      case TrainingStep.stepA:
      case TrainingStep.stepB:
      case TrainingStep.stepC:
        return _buildAnswerStep(strings, langCode);
      case TrainingStep.stepD:
        return _buildLoadingState(); // Should be caught by isLoading
      case TrainingStep.stepE:
        return _buildFollowUpStep(strings);
      case TrainingStep.stepF:
        return _buildEvaluationResult(strings);
    }
  }

  Widget _buildAnswerStep(AppStrings strings, String langCode) {
    final step = _controller.currentStep;
    final stepNum = step == TrainingStep.stepA
        ? 1
        : step == TrainingStep.stepB
            ? 2
            : 3;

    String title;
    String hint;
    switch (step) {
      case TrainingStep.stepA:
        title = strings.stepATitle;
        hint = strings.stepAHint;
        break;
      case TrainingStep.stepB:
        title = strings.stepBTitle;
        hint = strings.stepBHint;
        break;
      case TrainingStep.stepC:
        title = strings.stepCTitle;
        hint = strings.stepCHint;
        break;
      default:
        title = '';
        hint = '';
    }

    // Pre-fill if going back
    if (step == TrainingStep.stepA && _controller.stepA.isNotEmpty) {
      _textController.text = _controller.stepA;
    } else if (step == TrainingStep.stepB && _controller.stepB.isNotEmpty) {
      _textController.text = _controller.stepB;
    } else if (step == TrainingStep.stepC && _controller.stepC.isNotEmpty) {
      _textController.text = _controller.stepC;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          _buildProgressBar(stepNum, 3),
          const SizedBox(height: 20),

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
                  strings.question,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.question.getLocalizedQuestion(langCode),
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

          // Step title
          Text(
            'Step $stepNum: $title',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),

          // Text input
          TextField(
            controller: _textController,
            maxLines: step == TrainingStep.stepA ? 3 : 6,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.textDisabled.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.textDisabled.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              if (step != TrainingStep.stepA)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _textController.clear();
                      _controller.goBack();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: AppColors.textDisabled),
                    ),
                    child: Text(strings.previousStep,
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              if (step != TrainingStep.stepA) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isEmpty) return;

                    _textController.clear();
                    switch (step) {
                      case TrainingStep.stepA:
                        _controller.submitStepA(text);
                        break;
                      case TrainingStep.stepB:
                        _controller.submitStepB(text);
                        break;
                      case TrainingStep.stepC:
                        _controller.submitStepC(text);
                        break;
                      default:
                        break;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    step == TrainingStep.stepC
                        ? strings.receiveFollowUp
                        : strings.nextStep,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpStep(AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Follow-up question display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      strings.followUpQuestionLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _controller.followUpQuestion ?? '',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            strings.followUpAnswerHint,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _textController,
            maxLines: 6,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: strings.followUpAnswerHint,
              hintStyle: TextStyle(color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.textDisabled.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.textDisabled.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.orange, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final text = _textController.text.trim();
                if (text.isEmpty) return;
                _textController.clear();
                _controller.submitFollowUpAnswer(text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                strings.submitEvaluation,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationResult(AppStrings strings) {
    final eval = _controller.evaluation;
    if (eval == null) {
      return Center(
        child: Text('Evaluation failed',
            style: TextStyle(color: AppColors.textTertiary)),
      );
    }

    final axisLabels = [
      strings.axisSummary,
      strings.axisPrinciple,
      strings.axisExample,
      strings.axisKeyword,
      strings.axisClarity,
      strings.axisFollowUp,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grade & Total Score
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gradeColor(eval.grade).withValues(alpha: 0.15),
                    border:
                        Border.all(color: _gradeColor(eval.grade), width: 3),
                  ),
                  child: Center(
                    child: Text(
                      eval.grade,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _gradeColor(eval.grade),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${strings.totalScoreLabel}: ${eval.totalScore}',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Radar Chart
          Center(
            child: RadarChartWidget(
              scores: eval.axisScores,
              labels: axisLabels,
              size: 200,
            ),
          ),
          const SizedBox(height: 24),

          // Axis Scores
          ...eval.axisScores.entries.map((e) {
            final idx = eval.axisScores.keys.toList().indexOf(e.key);
            final label = idx < axisLabels.length ? axisLabels[idx] : e.key;
            return _scoreRow(label, e.value);
          }),
          const SizedBox(height: 24),

          // My Answers
          _buildAnswerCard(strings.myAnswerStepA, _controller.stepA),
          const SizedBox(height: 10),
          _buildAnswerCard(strings.myAnswerStepB, _controller.stepB),
          const SizedBox(height: 10),
          _buildAnswerCard(strings.myAnswerStepC, _controller.stepC),

          // Follow-up Q&A
          if (_controller.followUpQuestion != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.orange.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.orange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        strings.followUpQuestionLabel,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _controller.followUpQuestion!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.followUpAnswerEval,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _controller.followUpAnswer,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Main Checklist
          _buildChecklistSection(strings.mainAnswerEval, eval.mainChecklist),
          const SizedBox(height: 16),

          // Follow-up Checklist
          _buildChecklistSection(
              strings.followUpAnswerEval, eval.followUpChecklist),
          const SizedBox(height: 16),

          // Improvement Tip
          if (eval.improvementTip != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppColors.accentGreen, size: 20),
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
            const SizedBox(height: 24),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.textDisabled),
                  ),
                  child: Text(strings.backToHome,
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Restart training with same question
                    final langCode =
                        Provider.of<LanguageController>(context, listen: false)
                            .currentLanguage
                            .code;
                    _textController.clear();
                    _controller.startTraining(widget.question,
                        languageCode: langCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(strings.tryAgain,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(String title, List<dynamic> checklist) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 12),
          ...checklist.map((item) {
            final ci = item as dynamic;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    ci.passed ? Icons.check_circle : Icons.cancel,
                    color:
                        ci.passed ? AppColors.accentGreen : AppColors.accentRed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ci.criterion,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500),
                        ),
                        if (ci.comment != null && ci.comment!.isNotEmpty)
                          Text(
                            ci.comment!,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textTertiary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, int score) {
    final color = score >= 80
        ? AppColors.accentGreen
        : score >= 60
            ? Colors.orange
            : AppColors.accentRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100.0,
                backgroundColor: AppColors.textDisabled.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int current, int total) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i < current;
        final isCurrent = i == current - 1;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? (isCurrent
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.4))
                  : AppColors.textDisabled.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  String _getStepTitle(AppStrings strings) {
    switch (_controller.currentStep) {
      case TrainingStep.stepA:
        return '${strings.stepATitle} (1/3)';
      case TrainingStep.stepB:
        return '${strings.stepBTitle} (2/3)';
      case TrainingStep.stepC:
        return '${strings.stepCTitle} (3/3)';
      case TrainingStep.stepD:
        return strings.generatingFollowUp;
      case TrainingStep.stepE:
        return strings.followUpQuestionLabel;
      case TrainingStep.stepF:
        return strings.evaluationTitle;
    }
  }

  Widget _buildAnswerCard(String title, String answer) {
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
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
