import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/question_model.dart';
import '../../data/repositories/interview_repository.dart';

class SubjectQuestionsScreen extends StatefulWidget {
  final String subject;
  final Color themeColor;
  final IconData icon;

  const SubjectQuestionsScreen({
    super.key,
    required this.subject,
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
      final questions = await _repository.fetchQuestionsBySubject(widget.subject);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(widget.subject, style: AppTextStyles.titleMedium),
        actions: [
          Icon(widget.icon, color: widget.themeColor),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
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
                                  color: widget.themeColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Level ${question.level}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: widget.themeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.question,
                            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                          ),
                          if (question.tip != null && question.tip!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Tip: ${question.tip}',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 60, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            '등록된 질문이 없습니다.',
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
