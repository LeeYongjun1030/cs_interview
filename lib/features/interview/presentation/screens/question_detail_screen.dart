import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/language_service.dart';
import '../../domain/models/question_model.dart';
import '../../../training/presentation/screens/training_flow_screen.dart';

/// Question detail page — question up top, single toggle reveals all study material.
class QuestionDetailScreen extends StatefulWidget {
  final Question question;
  final int questionIndex;
  final int totalQuestions;

  const QuestionDetailScreen({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _revealed = false;
  late AnimationController _animController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _revealed = !_revealed);
    if (_revealed) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        Provider.of<LanguageController>(context).currentLanguage.code;
    final strings =
        AppStrings(Provider.of<LanguageController>(context).currentLanguage);

    final questionText = widget.question.getLocalizedQuestion(languageCode);
    final category = widget.question.getLocalizedCategory(languageCode);
    final tip = widget.question.getLocalizedTip(languageCode);
    final answer = widget.question.getLocalizedAnswer(languageCode);
    final keywords = widget.question.getLocalizedKeywords(languageCode);
    final level = widget.question.level;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.questionIndex} / ${widget.totalQuestions}',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Tags row ──
            Row(
              children: [
                _chip(category, AppColors.primary),
                const SizedBox(width: 8),
                _starBadge(level),
              ],
            ),
            const SizedBox(height: 20),

            // ── Question text ──
            Text(
              questionText,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.45,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 32),

            // ── Toggle button (full width, clear single action) ──
            GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _revealed
                      ? AppColors.surface
                      : AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _revealed
                        ? AppColors.textDisabled.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedRotation(
                      turns: _revealed ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _revealed
                            ? AppColors.textTertiary
                            : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _revealed ? strings.hideAnswer : strings.showAnswer,
                      style: TextStyle(
                        color: _revealed
                            ? AppColors.textTertiary
                            : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable content ──
            SizeTransition(
              sizeFactor: _expandAnim,
              axisAlignment: -1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Tip
                  if (tip.isNotEmpty) ...[
                    _sectionHeader(Icons.lightbulb_outline_rounded,
                        const Color(0xFFF59E0B), strings.tipLabel),
                    const SizedBox(height: 8),
                    Text(
                      tip,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Keywords
                  if (keywords.isNotEmpty) ...[
                    _sectionHeader(Icons.key_rounded, const Color(0xFF6366F1),
                        strings.keywordsLabel),
                    const SizedBox(height: 8),
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
                                        fontWeight: FontWeight.w700)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Answer
                  if (answer.isNotEmpty) ...[
                    _sectionHeader(Icons.description_outlined,
                        AppColors.primary, strings.keySummary),
                    const SizedBox(height: 8),
                    _buildHighlightedText(answer, keywords),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Training CTA ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TrainingFlowScreen(question: widget.question),
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
                    const Icon(Icons.edit_note_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(strings.trainButton,
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _starBadge(int level) {
    const color = Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Icon(
            i < level ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14,
            color: i < level ? color : color.withValues(alpha: 0.3),
          );
        }),
      ),
    );
  }

  /// Builds answer text with keyword occurrences highlighted in bold.
  Widget _buildHighlightedText(String text, List<String> keywords) {
    if (keywords.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.5,
          height: 1.6,
        ),
      );
    }

    final pattern = keywords.map((k) => RegExp.escape(k)).join('|');
    final regex = RegExp('($pattern)', caseSensitive: false);
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.5,
          height: 1.6,
        ),
        children: spans,
      ),
    );
  }

  Widget _sectionHeader(IconData icon, Color color, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
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
