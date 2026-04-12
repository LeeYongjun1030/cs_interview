import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../interview/domain/models/question_model.dart';
import '../providers/training_controller.dart';
import '../../../monetization/data/repositories/credit_repository.dart';

/// Full training flow screen.
class TrainingFlowScreen extends StatefulWidget {
  final Question question;

  const TrainingFlowScreen({super.key, required this.question});

  @override
  State<TrainingFlowScreen> createState() => _TrainingFlowScreenState();
}

class _TrainingFlowScreenState extends State<TrainingFlowScreen> {
  late final TrainingController _controller;
  final _textController = TextEditingController();
  bool _hasEnergy = false;
  bool _showHints = false;

  @override
  void initState() {
    super.initState();
    _controller = TrainingController();
    _controller.addListener(_onControllerChange);
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

  void _onClosePressed(AppStrings strings) {
    if (_controller.currentStep == TrainingStep.done) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          strings.exitTrainingTitle,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          strings.exitTrainingMessage,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.continueTraining,
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(strings.exitAnyway,
                style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
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
          onPressed: () => _onClosePressed(strings),
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

  String _getStepTitle(AppStrings strings) {
    switch (_controller.currentStep) {
      case TrainingStep.answer:
        return strings.trainingTitle;
      case TrainingStep.loading:
        return strings.trainingTitle;
      case TrainingStep.feedback:
        return strings.feedbackTitle;
      case TrainingStep.followUp:
        return strings.followUpQuestionLabel;
      case TrainingStep.followUpResult:
        return strings.followUpQuestionLabel;
      case TrainingStep.done:
        return strings.trainingTitle;
    }
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
      case TrainingStep.answer:
        return _buildAnswerStep(strings, langCode);
      case TrainingStep.loading:
        return _buildLoadingState();
      case TrainingStep.feedback:
        return _buildFeedbackStep(strings, langCode);
      case TrainingStep.followUp:
        return _buildFollowUpStep(strings);
      case TrainingStep.followUpResult:
        return _buildFollowUpResult(strings);
      case TrainingStep.done:
        return _buildDoneState(strings, langCode);
    }
  }

  // ── Answer Step ──
  Widget _buildAnswerStep(AppStrings strings, String langCode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question card
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
          const SizedBox(height: 16),

          if (!_showHints)
            Center(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showHints = true),
                icon: Icon(Icons.visibility,
                    color: AppColors.textSecondary, size: 18),
                label: Text(strings.showHintsLabel,
                    style: TextStyle(color: AppColors.textSecondary)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(
                      color: AppColors.textDisabled.withValues(alpha: 0.3)),
                ),
              ),
            )
          else ...[
            // Keywords chips
            Text(
              strings.coreKeywordsLabel,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.question
                  .getLocalizedKeywords(langCode)
                  .map((kw) => Chip(
                        label: Text(kw,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.primary)),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.08),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Tip
            if (widget.question.getLocalizedTip(langCode).isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates,
                        color: Colors.amber[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.question.getLocalizedTip(langCode),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 20),

          // Text input
          TextField(
            controller: _textController,
            maxLines: 8,
            maxLength: 500,
            style: TextStyle(color: AppColors.textPrimary),
            buildCounter: (context,
                {required currentLength,
                required isFocused,
                required maxLength}) {
              final isNearLimit = currentLength > (maxLength! * 0.8);
              return Text(
                '$currentLength / $maxLength',
                style: TextStyle(
                  color: isNearLimit
                      ? AppColors.accentRed
                      : AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            },
            decoration: InputDecoration(
              hintText: strings.answerHint,
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

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final text = _textController.text.trim();
                if (text.isEmpty) return;
                _textController.clear();
                _controller.submitAnswer(text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                strings.submitForFeedback,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feedback Step ──
  Widget _buildFeedbackStep(AppStrings strings, String langCode) {
    final fb = _controller.feedback;
    if (fb == null) {
      return Center(
        child: Text('Evaluation failed',
            style: TextStyle(color: AppColors.textTertiary)),
      );
    }

    final refAnswer = widget.question.getLocalizedAnswer(langCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score circle

          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _scoreColor(fb.score).withValues(alpha: 0.15),
                border: Border.all(color: _scoreColor(fb.score), width: 3),
              ),
              child: Center(
                child: Text(
                  '${fb.score}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _scoreColor(fb.score),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Strengths
          if (fb.strengths.isNotEmpty) ...[
            _sectionLabel(Icons.check_circle, strings.strengthsLabel,
                AppColors.accentGreen),
            const SizedBox(height: 8),
            ...fb.strengths.map((s) => _feedbackItem(s, AppColors.accentGreen)),
            const SizedBox(height: 16),
          ],

          // Improvements
          if (fb.improvements.isNotEmpty) ...[
            _sectionLabel(
                Icons.warning_amber, strings.improvementsLabel, Colors.orange),
            const SizedBox(height: 8),
            ...fb.improvements.map((s) => _feedbackItem(s, Colors.orange)),
            const SizedBox(height: 16),
          ],

          // Missing Keywords
          if (fb.missingKeywords.isNotEmpty) ...[
            _sectionLabel(
                Icons.vpn_key, strings.missingKeywordsLabel, AppColors.primary),
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
            const SizedBox(height: 16),
          ],

          // Reference Answer
          if (refAnswer.isNotEmpty) ...[
            _sectionLabel(Icons.menu_book, strings.referenceAnswerLabel,
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
                refAnswer,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action buttons
          Row(
            children: [
              // Skip / Complete
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await _controller.finishTraining();
                    if (mounted) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.textDisabled),
                  ),
                  child: Text(strings.completeTraining,
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              // Follow-up challenge
              if (fb.followUpQuestion != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _controller.startFollowUp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      strings.tryFollowUp,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Follow-up Step ──
  Widget _buildFollowUpStep(AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Follow-up question
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
                  _controller.feedback?.followUpQuestion ?? '',
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
                strings.seeModelAnswer,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Follow-up Result ──
  Widget _buildFollowUpResult(AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The follow-up question
          _sectionLabel(
              Icons.psychology, strings.followUpQuestionLabel, Colors.orange),
          const SizedBox(height: 8),
          Text(
            _controller.feedback?.followUpQuestion ?? '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // User's answer
          _sectionLabel(Icons.edit_note, strings.myAnswerLabel,
              AppColors.textSecondary),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _controller.followUpAnswer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Model answer
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
              _controller.feedback?.followUpModelAnswer ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Complete button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await _controller.finishTraining();
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                strings.completeTraining,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Done State ──
  Widget _buildDoneState(AppStrings strings, String langCode) {
    // Auto-pop handled by finishTraining callers, but just in case:
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.accentGreen, size: 48),
          const SizedBox(height: 16),
          Text(strings.trainingComplete,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              )),
        ],
      ),
    );
  }

  // ── Helpers ──

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
