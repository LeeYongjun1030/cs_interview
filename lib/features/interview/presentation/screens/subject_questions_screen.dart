import 'package:flutter/material.dart';
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

  const SubjectQuestionsScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.themeColor,
    required this.icon,
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

  @override
  Widget build(BuildContext context) {
    final languageCode =
        Provider.of<LanguageController>(context).currentLanguage.code; // code
    final strings =
        AppStrings(Provider.of<LanguageController>(context).currentLanguage);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(builder: (context) {
                            final categoryText =
                                question.getLocalizedCategory(languageCode);
                            // Use a neutral/calm style (Dam-baek)
                            const categoryColor = Colors.white70;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                categoryText,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                          Text(
                            question.getLocalizedQuestion(languageCode),
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: Colors.white, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (question.lastReviewedAt != null)
                                Text(
                                  '${strings.lastStudied}: ${question.lastReviewedAt.toString().split(' ')[0]}',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: Colors.white38),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined,
              size: 60, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            strings.noQuestions,
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // _getCategoryColor removed as it is no longer needed
}
