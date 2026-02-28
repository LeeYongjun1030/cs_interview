import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../domain/models/question_model.dart';

/// A modern, full-screen detail page for studying a single question.
/// Tap-to-reveal flashcard style with editorial layout.
class QuestionDetailScreen extends StatefulWidget {
  final Question question;
  final Color themeColor;
  final int questionIndex; // 1-based
  final int totalQuestions;

  const QuestionDetailScreen({
    super.key,
    required this.question,
    required this.themeColor,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnswerRevealed = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _revealAnswer() {
    setState(() {
      _isAnswerRevealed = true;
      _animController.forward();
    });
  }

  void _hideAnswer() {
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isAnswerRevealed = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        Provider.of<LanguageController>(context).currentLanguage.code;
    final strings =
        AppStrings(Provider.of<LanguageController>(context).currentLanguage);

    final questionText = widget.question.getLocalizedQuestion(languageCode);
    final answerText = widget.question.getLocalizedAnswer(languageCode);
    final tipText = widget.question.getLocalizedTip(languageCode);
    final keywords = widget.question.getLocalizedKeywords(languageCode);
    final category = widget.question.getLocalizedCategory(languageCode);

    final levelLabel = widget.question.level == 1
        ? (languageCode == 'en' ? 'Basic' : '기초')
        : widget.question.level == 2
            ? (languageCode == 'en' ? 'Intermediate' : '중급')
            : (languageCode == 'en' ? 'Advanced' : '심화');
    final levelColor = widget.question.level == 1
        ? AppColors.accentGreen
        : widget.question.level == 2
            ? AppColors.accentCyan
            : AppColors.accentRed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ---------- Header ----------
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back,
                    color: AppColors.textPrimary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.themeColor.withValues(alpha: 0.06),
                      AppColors.background,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags row
                        Row(
                          children: [
                            _tag(category, widget.themeColor),
                            const SizedBox(width: 8),
                            _tag(levelLabel, levelColor),
                            const Spacer(),
                            Text(
                              '${widget.questionIndex} / ${widget.totalQuestions}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Question
                        Text(
                          questionText,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ---------- Body ----------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Reveal Button (hidden state) ──
                  if (!_isAnswerRevealed) ...[
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _revealAnswer,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 56),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: widget.themeColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: widget.themeColor.withValues(alpha: 0.4),
                              size: 44,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              strings.viewAnswer,
                              style: TextStyle(
                                color: widget.themeColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              languageCode == 'en' ? 'Tap to reveal' : '탭하여 확인',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Revealed Content (open state) ──
                  if (_isAnswerRevealed)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Keywords first (quick context) ───
                          if (keywords.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: keywords
                                  .map((k) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: widget.themeColor
                                              .withValues(alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '# $k',
                                          style: TextStyle(
                                            color: widget.themeColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ] else
                            const SizedBox(height: 24),

                          // ─── Answer (main content, no box) ───
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                languageCode == 'en'
                                    ? 'Reference Answer'
                                    : '참고 답안',
                                style: TextStyle(
                                  color: AppColors.accentGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildHighlightedAnswer(
                            answerText,
                            keywords,
                          ),

                          // ─── Tip (subtle, integrated) ───
                          if (tipText.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.accentCyan
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languageCode == 'en' ? 'Tip' : '꿀팁',
                                    style: TextStyle(
                                      color: AppColors.accentCyan,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    tipText,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ─── Hide button ───
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: _hideAnswer,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility_off_outlined,
                                        size: 16,
                                        color: AppColors.textTertiary),
                                    const SizedBox(width: 6),
                                    Text(
                                      languageCode == 'en'
                                          ? 'Hide answer'
                                          : '답안 숨기기',
                                      style: TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Builds the answer text with keyword occurrences bolded.
  Widget _buildHighlightedAnswer(String text, List<String> keywords) {
    if (keywords.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15.5,
          height: 1.75,
          letterSpacing: 0.1,
        ),
      );
    }

    // Build a regex that matches any keyword (case-insensitive)
    final escapedKeywords = keywords.map((k) => RegExp.escape(k)).toList();
    final pattern = RegExp(
      '(${escapedKeywords.join('|')})',
      caseSensitive: false,
    );

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      // Plain text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      // Bold keyword match
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ));
      lastEnd = match.end;
    }
    // Remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15.5,
          height: 1.75,
          letterSpacing: 0.1,
        ),
        children: spans,
      ),
    );
  }
}
