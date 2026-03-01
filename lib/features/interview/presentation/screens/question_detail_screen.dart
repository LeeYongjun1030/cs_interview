import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../domain/models/question_model.dart';
import '../../../training/presentation/screens/quick_view_screen.dart';
import '../../../training/presentation/screens/training_flow_screen.dart';

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

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final languageCode =
        Provider.of<LanguageController>(context).currentLanguage.code;
    final strings =
        AppStrings(Provider.of<LanguageController>(context).currentLanguage);

    final questionText = widget.question.getLocalizedQuestion(languageCode);
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
                  // ── CTA Buttons: Quick View / Training ──
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuickViewScreen(
                                  question: widget.question,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.visibility,
                              color: widget.themeColor, size: 18),
                          label: Text(strings.quickViewButton,
                              style: TextStyle(
                                  color: widget.themeColor,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            side: BorderSide(
                                color:
                                    widget.themeColor.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrainingFlowScreen(
                                  question: widget.question,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(strings.trainButton,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt,
                                        color: Colors.yellow, size: 12),
                                    Text('1',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.themeColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
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
}
