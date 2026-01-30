import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/question_model.dart';
import '../../data/repositories/interview_repository.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../monetization/data/repositories/credit_repository.dart';
import '../providers/session_controller.dart';
import 'interview_screen.dart';
import 'result_screen.dart';

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

  // Selection State
  final Set<String> _selectedIds = {};
  static const int MAX_SELECTION = 3;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        if (_selectedIds.length < MAX_SELECTION) {
          _selectedIds.add(id);
        } else {
          // Max reached
          final strings = AppStrings(
              Provider.of<LanguageController>(context, listen: false)
                  .currentLanguage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.maxSelectionMessage)),
          );
        }
      }
    });
  }

  void _startCustomSession() {
    if (_selectedIds.isEmpty) return;

    final strings = AppStrings(
        Provider.of<LanguageController>(context, listen: false)
            .currentLanguage);

    // Auto-generate title
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final randomSuffix = timestamp.substring(timestamp.length - 6);
    final defaultTitleBase = strings.defaultSessionTitle.replaceAll(' ', '-');
    final autoTitle = '$defaultTitleBase-$randomSuffix';
    final titleController = TextEditingController(text: autoTitle);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(strings.startNewSession,
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.sessionGoalHint,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              style: TextStyle(color: AppColors.textPrimary),
              maxLength: 30,
              decoration: InputDecoration(
                hintText: strings.sessionTitleHint,
                hintStyle: TextStyle(color: AppColors.textTertiary),
                counterStyle: TextStyle(color: AppColors.textTertiary),
                labelText: strings.sessionNameLabel,
                labelStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.textDisabled.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.textDisabled.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancelButton,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim().isEmpty
                  ? autoTitle
                  : titleController.text.trim();
              Navigator.pop(dialogContext);
              _processStartSession(context, title);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(strings.startAction,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _processStartSession(BuildContext context, String title) async {
    // 1. Get Selected Questions
    final selectedQuestions =
        _questions.where((q) => _selectedIds.contains(q.id)).toList();

    // 2. Initial Setup
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final controller = SessionController();

    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. Deduct Credit
      final creditRepo = Provider.of<CreditRepository>(context, listen: false);
      final success = await creditRepo.deductCredit(userId);

      if (!success) {
        if (!context.mounted) return;
        Navigator.pop(context); // Pop loading

        final strings = AppStrings(
            Provider.of<LanguageController>(context, listen: false)
                .currentLanguage);
        // Show simplified 'Not Enough Energy' message since we are deep in a sub-screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.notEnoughEnergySnack)),
        );
        return;
      }

      // 4. Start Session
      await controller.startNewSession(userId, title,
          fixedQuestions: selectedQuestions);

      if (!context.mounted) return;
      Navigator.pop(context); // Pop loading

      // 5. Navigate to Interview
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InterviewScreen(controller: controller)),
      );

      // 6. Handle Completion (Show Result)
      if (result == 'finished') {
        final rounds = controller.rounds;
        double totalScore = 0;
        int count = 0;
        for (var round in rounds) {
          if (round.mainGrade != null) {
            totalScore += round.mainGrade!.score;
            count++;
          }
          if (round.followUpGrade != null) {
            totalScore += round.followUpGrade!.score;
            count++;
          }
        }
        final double averageScore = count > 0 ? totalScore / count : 0.0;

        if (!context.mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InterviewResultScreen(
              rounds: rounds,
              averageScore: averageScore,
              controller:
                  controller, // Pass controller if needed for retry logic
            ),
          ),
        );
      }

      // 7. Clear Selection (Optional but good UX)
      if (mounted) {
        setState(() {
          _selectedIds.clear();
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Pop loading if still there
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
              : Stack(
                  children: [
                    CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Guidance Header (Design 3: Accent Border Clean Style)
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
                                      color: widget.themeColor
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          strings.subjectQuestionsGuide,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          strings.maxSelectionMessage,
                                          style: TextStyle(
                                            color: AppColors.textSecondary
                                                .withValues(alpha: 0.5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Question List
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final question = _questions[index];
                                final isSelected =
                                    _selectedIds.contains(question.id);

                                return GestureDetector(
                                  onTap: () => _toggleSelection(question.id),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                              .withValues(alpha: 0.2)
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textDisabled
                                                  .withValues(alpha: 0.1)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Builder(builder: (context) {
                                                final categoryText = question
                                                    .getLocalizedCategory(
                                                        languageCode);
                                                final categoryColor =
                                                    AppColors.textSecondary;
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 4),
                                                  child: Text(
                                                    categoryText,
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                      color: categoryColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }),
                                              Text(
                                                question.getLocalizedQuestion(
                                                    languageCode),
                                                style: AppTextStyles.bodyLarge
                                                    .copyWith(
                                                        color: AppColors
                                                            .textPrimary,
                                                        height: 1.4),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Checkbox Indicator (Right)
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 4, left: 16),
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.textDisabled
                                                          .withValues(
                                                              alpha: 0.1),
                                                  width: 2)),
                                          child: isSelected
                                              ? const Icon(Icons.check,
                                                  size: 16, color: Colors.white)
                                              : null,
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
                    if (_selectedIds.isNotEmpty)
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: FloatingActionButton.extended(
                            onPressed: _startCustomSession,
                            backgroundColor: AppColors.primary,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              '${strings.startInterview} (${_selectedIds.length}/$MAX_SELECTION)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
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
