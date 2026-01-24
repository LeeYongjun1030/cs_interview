import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../features/monetization/services/ad_service.dart';
import '../providers/session_controller.dart';

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
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    strings.overallScore,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$displayScore',
                    style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.0),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white10,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getCheerMessage(displayScore, strings),
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details List
            ...rounds.asMap().entries.map((entry) {
              final index = entry.key;
              final round = entry.value;
              return Column(
                children: [
                  _buildRoundCard(index + 1, round, strings),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // Banner Ad at the bottom of content
            const SizedBox(height: 32),
            const _BannerAdWidget(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => _handleRetry(context, strings),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(strings.retrySameQuestions,
                    style: const TextStyle(
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
                  backgroundColor: Colors.white10,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(strings.homeButton,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
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
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.retryContentDialog,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: strings.sessionNameLabel,
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
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
                  style: const TextStyle(color: Colors.white54)),
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
    // Return to HomeScreen with retry intent
    // We pass the data needed to start a new session
    final retryData = {
      'action': 'retry',
      'title': title,
      'questions': rounds.map((r) => r.mainQuestion).toList(),
    };
    Navigator.pop(context, retryData);
  }

  Widget _buildRoundCard(int index, SessionRound round, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Q$index',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ExpandableQuestionText(
                  text: round.mainQuestion
                      .getLocalizedQuestion(strings.language.code),
                ),
              ),
              if (round.mainGrade != null)
                Text(
                  '${round.mainGrade!.score}',
                  style: TextStyle(
                      color: _getScoreColor(round.mainGrade!.score),
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
          // Main Answer Display
          if (round.mainAnswer != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.myAnswer,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(round.mainAnswer!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Main Feedback
          if (round.mainGrade != null) ...[
            Text('${strings.aiFeedback}: ${round.mainGrade!.feedback}',
                style:
                    const TextStyle(color: AppColors.accentCyan, fontSize: 13)),
          ] else ...[
            Text(strings.noFeedback,
                style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ],

          // Follow Up Section if exists
          if (round.followUpQuestion != null) ...[
            const Divider(color: Colors.white10, height: 24),
            Row(
              children: [
                const Icon(Icons.subdirectory_arrow_right,
                    color: AppColors.accentRed, size: 16),
                const SizedBox(width: 8),
                Text(strings.followUpTitle,
                    style: const TextStyle(
                        color: AppColors.accentRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (round.followUpGrade != null)
                  Text(
                    '${round.followUpGrade!.score}',
                    style: TextStyle(
                        color: _getScoreColor(round.followUpGrade!.score),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(round.followUpQuestion!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            if (round.followUpAnswer != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.myAnswer,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(round.followUpAnswer!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
            if (round.followUpGrade != null) ...[
              const SizedBox(height: 8),
              Text('${strings.aiFeedback}: ${round.followUpGrade!.feedback}',
                  style: const TextStyle(
                      color: AppColors.accentCyan, fontSize: 12)),
            ]
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

class _ExpandableQuestionText extends StatefulWidget {
  final String text;
  const _ExpandableQuestionText({required this.text});

  @override
  State<_ExpandableQuestionText> createState() =>
      _ExpandableQuestionTextState();
}

class _ExpandableQuestionTextState extends State<_ExpandableQuestionText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState:
            _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: Text(
          widget.text,
          style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        secondChild: Text(
          widget.text,
          style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
        ),
      ),
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
    // Use AdService to get Unit ID but create Ad here for state control
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
          print('Banner failed to load: $error');
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
