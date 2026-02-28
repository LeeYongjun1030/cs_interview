import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'question_detail_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/question_model.dart';
import '../../data/repositories/interview_repository.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';

class SubjectQuestionsScreen extends StatefulWidget {
  final String subjectId; // For Query (e.g. 'network')
  final String subjectName; // For Display (e.g. 'Network')
  final Color themeColor;
  final IconData icon;
  final String? lectureUrl; // Optional external video link

  const SubjectQuestionsScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.themeColor,
    required this.icon,
    this.lectureUrl,
  });

  @override
  State<SubjectQuestionsScreen> createState() => _SubjectQuestionsScreenState();
}

class _SubjectQuestionsScreenState extends State<SubjectQuestionsScreen> {
  final InterviewRepository _repository = InterviewRepository();
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions =
          await _repository.fetchQuestionsBySubject(widget.subjectId);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      }
    }
  }

  void _openQuestionDetail(Question question, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailScreen(
          question: question,
          themeColor: widget.themeColor,
          questionIndex: index + 1,
          totalQuestions: _questions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        Provider.of<LanguageController>(context).currentLanguage.code;
    final strings =
        AppStrings(Provider.of<LanguageController>(context).currentLanguage);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        title: Text(widget.subjectName, style: AppTextStyles.titleMedium),
        actions: [
          Icon(widget.icon, color: widget.themeColor),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? _buildEmptyState(strings)
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Guidance Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Accent Line
                              Container(
                                width: 3,
                                decoration: BoxDecoration(
                                  color:
                                      widget.themeColor.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Text
                              Expanded(
                                child: Text(
                                  strings.subjectQuestionsGuide,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Video Lecture Button
                    if (widget.lectureUrl != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final url = Uri.parse(widget.lectureUrl!);
                                if (!await launchUrl(url)) {
                                  throw Exception('Could not launch $url');
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color:
                                      widget.themeColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: widget.themeColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      strings.watchVideoLecture,
                                      style: TextStyle(
                                        color: widget.themeColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.open_in_new,
                                      color: widget.themeColor,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    // Question List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final question = _questions[index];

                            return GestureDetector(
                              onTap: () => _openQuestionDetail(question, index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.textDisabled
                                          .withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            question.getLocalizedCategory(
                                                languageCode),
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            question.getLocalizedQuestion(
                                                languageCode),
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                    color:
                                                        AppColors.textPrimary,
                                                    height: 1.4),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: AppColors.textTertiary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _questions.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined,
              size: 60, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            strings.noQuestions,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
