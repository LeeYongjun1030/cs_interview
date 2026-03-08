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
  final IconData icon;
  final String? lectureUrl; // Optional external video link

  const SubjectQuestionsScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.icon,
    this.lectureUrl,
  });

  @override
  State<SubjectQuestionsScreen> createState() => _SubjectQuestionsScreenState();
}

class _SubjectQuestionsScreenState extends State<SubjectQuestionsScreen> {
  final InterviewRepository _repository = InterviewRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Question> _questions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<Question> get _filteredQuestions {
    if (_searchQuery.isEmpty) return _questions;
    final q = _searchQuery.toLowerCase();
    return _questions.where((question) {
      final langCode = Provider.of<LanguageController>(context, listen: false)
          .currentLanguage
          .code;
      final questionText =
          question.getLocalizedQuestion(langCode).toLowerCase();
      final category = question.getLocalizedCategory(langCode).toLowerCase();
      final keywords = question
          .getLocalizedKeywords(langCode)
          .map((k) => k.toLowerCase())
          .toList();
      return questionText.contains(q) ||
          category.contains(q) ||
          keywords.any((k) => k.contains(q));
    }).toList();
  }

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQuestionDetail(Question question, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailScreen(
          question: question,
          questionIndex: index + 1,
          totalQuestions: _filteredQuestions.length,
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
          Icon(widget.icon, color: AppColors.primary),
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
                                      AppColors.primary.withValues(alpha: 0.8),
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
                                      AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      strings.watchVideoLecture,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.open_in_new,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Search bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value.trim()),
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: strings.searchQuestions,
                            hintStyle: TextStyle(color: AppColors.textDisabled),
                            prefixIcon: Icon(Icons.search,
                                color: AppColors.textTertiary, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear,
                                        color: AppColors.textTertiary,
                                        size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.textDisabled
                                      .withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.textDisabled
                                      .withValues(alpha: 0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Question List (or empty search result)
                    if (_filteredQuestions.isEmpty && _searchQuery.isNotEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: 12),
                              Text(
                                strings.noSearchResults,
                                style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final question = _filteredQuestions[index];

                              return GestureDetector(
                                onTap: () =>
                                    _openQuestionDetail(question, index),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Star difficulty + category
                                            Row(
                                              children: [
                                                _starRow(question.level),
                                                const SizedBox(width: 8),
                                                Text(
                                                  question.getLocalizedCategory(
                                                      languageCode),
                                                  style: AppTextStyles
                                                      .labelSmall
                                                      .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
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
                            childCount: _filteredQuestions.length,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _starRow(int level) {
    const color = Color(0xFFF59E0B);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < level ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 13,
          color: i < level ? color : color.withValues(alpha: 0.25),
        );
      }),
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
