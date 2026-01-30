import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../features/monetization/services/ad_service.dart';
import '../providers/session_controller.dart';

import '../../../../core/services/ai_service.dart'; // For GradeResult

class InterviewResultScreen extends StatelessWidget {
  final List<SessionRound> rounds;
  final double averageScore;
  final SessionController? controller;

  const InterviewResultScreen({
    super.key,
    required this.rounds,
    required this.averageScore,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final displayScore = averageScore.round();
    final langController = Provider.of<LanguageController>(context);
    final strings = AppStrings(langController.currentLanguage);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(strings.resultReportTitle,
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            _buildSummaryCard(displayScore, strings),
            const SizedBox(height: 24),

            // Accordion List
            ...rounds.asMap().entries.map((entry) {
              final index = entry.key;
              final round = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ResultRoundCard(
                  index: index + 1,
                  round: round,
                  strings: strings,
                ),
              );
            }),

            // Banner Ad
            const _BannerAdWidget(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context, strings),
    );
  }

  Widget _buildSummaryCard(int score, AppStrings strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            strings.overallScore,
            style: AppTextStyles.labelMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: AppTextStyles.displayLarge.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold, height: 1.0),
          ),
          const SizedBox(height: 16),
          Container(width: 40, height: 4, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            _getCheerMessage(score, strings),
            style: AppTextStyles.titleMedium
                .copyWith(color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, AppStrings strings) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => _handleRetry(context, strings),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(strings.retrySameQuestions,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textDisabled.withValues(alpha: 0.1),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(strings.homeButton,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRetry(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(
          text:
              '${strings.defaultSessionTitle}-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).substring(4)}',
        );
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(strings.retryTitleDialog,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.retryContentDialog,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: strings.sessionNameLabel,
                  labelStyle: TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: AppColors.textTertiary),
                    onPressed: () => titleController.clear(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancelButton,
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(context);
                _startRetrySession(context, title);
              },
              child: Text(strings.startAction,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _startRetrySession(BuildContext context, String title) {
    final retryData = {
      'action': 'retry',
      'title': title,
      'questions': rounds.map((r) => r.mainQuestion).toList(),
    };
    Navigator.pop(context, retryData);
  }

  String _getCheerMessage(int score, AppStrings strings) {
    if (strings.language == AppLanguage.korean) {
      if (score >= 90) return '완벽해요! 면접 마스터시네요 🏆';
      if (score >= 70) return '훌륭해요! 조금만 더 다듬으면 완벽할 거예요 🚀';
      if (score >= 50) return '좋아요! 부족한 부분을 보완해볼까요? 💪';
      return '시작이 반이에요! 꾸준히 연습해봐요 🌱';
    } else {
      if (score >= 90) return 'Perfect! You are an interview master 🏆';
      if (score >= 70) return 'Great! Just a little more polish 🚀';
      if (score >= 50) return 'Good! Let\'s improve the weak points 💪';
      return 'A good start! Keep practicing 🌱';
    }
  }
}

class _ResultRoundCard extends StatefulWidget {
  final int index;
  final SessionRound round;
  final AppStrings strings;

  const _ResultRoundCard({
    required this.index,
    required this.round,
    required this.strings,
  });

  @override
  State<_ResultRoundCard> createState() => _ResultRoundCardState();
}

class _ResultRoundCardState extends State<_ResultRoundCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(widget.round.mainGrade?.score ?? 0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Always Visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Q${widget.index}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Question Text
                  Expanded(
                    child: Text(
                      widget.round.mainQuestion
                          .getLocalizedQuestion(widget.strings.language.code),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: _isExpanded ? 3 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Score & Chevron
                  Row(
                    children: [
                      if (widget.round.mainGrade != null)
                        Text(
                          '${widget.round.mainGrade!.score}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Collapsible Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 24),

          // 1. My Answer Block (Chat Style)
          if (widget.round.mainAnswer != null)
            _ChatBubble(
              isUser: true,
              message: widget.round.mainAnswer!,
              label: widget.strings.myAnswer,
            ),

          const SizedBox(height: 16),

          // 2. Feedback Card
          if (widget.round.mainGrade != null)
            _ResultFeedbackCard(
                grade: widget.round.mainGrade!, strings: widget.strings),

          // 3. Follow-up Section
          if (widget.round.followUpQuestion != null) ...[
            const SizedBox(height: 32),
            _ChatDivider(label: widget.strings.followUpTitle),
            const SizedBox(height: 16),

            // Corrected: Use _ChatBubble for Follow-up Question too
            _ChatBubble(
              isUser: false,
              message: widget.round.followUpQuestion!,
              label: 'AI Interviewer', // Or localized string if available
              isFollowUp: true,
            ),
            const SizedBox(height: 12),

            if (widget.round.followUpAnswer != null)
              _ChatBubble(
                isUser: true,
                message: widget.round.followUpAnswer!,
                label: widget.strings.myAnswer,
              ),

            const SizedBox(height: 16),
            if (widget.round.followUpGrade != null)
              _ResultFeedbackCard(
                  grade: widget.round.followUpGrade!, strings: widget.strings),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.accentGreen;
    if (score >= 50) return AppColors.accentCyan;
    return AppColors.accentRed;
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String label;
  final bool isFollowUp;

  const _ChatBubble({
    required this.isUser,
    required this.message,
    required this.label,
    this.isFollowUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isUser ? AppColors.textTertiary : AppColors.accentRed,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            ),
            border: isFollowUp
                ? Border.all(
                    color: AppColors.accentRed.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Text(
            message,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultFeedbackCard extends StatelessWidget {
  final GradeResult grade;
  final AppStrings strings;

  const _ResultFeedbackCard({required this.grade, required this.strings});

  @override
  Widget build(BuildContext context) {
    // If no structured fields, show old feedback string
    if (grade.summary == null &&
        (grade.strengths == null || grade.strengths!.isEmpty) &&
        (grade.weaknesses == null || grade.weaknesses!.isEmpty)) {
      if (grade.feedback.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${strings.aiFeedback}: ${grade.feedback}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, // Nested card on surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.textDisabled.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                strings.aiFeedback,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (grade.summary != null)
            Text(
              grade.summary!,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 16),
          if (grade.strengths != null && grade.strengths!.isNotEmpty) ...[
            _AnalysisSection(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.accentGreen,
              title: strings.strengthsTitle,
              items: grade.strengths!,
            ),
            const SizedBox(height: 12),
          ],
          if (grade.weaknesses != null && grade.weaknesses!.isNotEmpty) ...[
            _AnalysisSection(
              icon: Icons.error_outline,
              iconColor: AppColors.accentRed,
              title: strings.weaknessesTitle,
              items: grade.weaknesses!,
            ),
            const SizedBox(height: 12),
          ],
          if (grade.tip != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: AppColors.accentCyan, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      grade.tip!,
                      style: TextStyle(
                          color: AppColors.accentCyan,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  const _AnalysisSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•',
                      style: TextStyle(color: Colors.grey, height: 1.4)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ChatDivider extends StatelessWidget {
  final String label;

  const _ChatDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child:
                Divider(color: AppColors.textDisabled.withValues(alpha: 0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
            child:
                Divider(color: AppColors.textDisabled.withValues(alpha: 0.2))),
      ],
    );
  }
}

class _BannerAdWidget extends StatefulWidget {
  const _BannerAdWidget();

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    final adService = Provider.of<AdService>(context, listen: false);

    _bannerAd = BannerAd(
      adUnitId: adService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
