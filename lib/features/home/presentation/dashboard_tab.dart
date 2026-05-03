import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/localization/language_service.dart';
import '../../interview/data/repositories/interview_repository.dart';
import '../../interview/domain/models/question_model.dart';
import '../../stats/domain/models/user_stats_model.dart';

import '../../training/presentation/screens/training_flow_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final InterviewRepository _repository = InterviewRepository();
  UserStats? _stats;
  Question? _dailyQuestion;
  bool _isLoading = true;
  int _dailyOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final stats = await _repository.getUserStats(uid);
      final daily = await _repository.getDailyQuestion(uid, offset: _dailyOffset);
      if (mounted) {
        setState(() {
          _stats = stats;
          _dailyQuestion = daily;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshDailyQuestion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    // Increment offset to get a new question
    _dailyOffset++;
    
    // We only want a soft loading state if possible, but let's just use _loadData
    // which manages _isLoading. To prevent blanking the screen completely, 
    // let's do an in-place update without turning the whole screen to a spinner.
    try {
      final daily = await _repository.getDailyQuestion(uid, offset: _dailyOffset);
      if (mounted) {
        setState(() {
          _dailyQuestion = daily;
        });
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  String _getGreeting(AppStrings strings) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return strings.greetingMorning;
    } else if (hour < 18) {
      return strings.greetingAfternoon;
    } else {
      return strings.greetingEvening;
    }
  }



  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final strings = Provider.of<LanguageController>(context).strings;
    final langCode =
        Provider.of<LanguageController>(context).currentLanguage.code;

    return SafeArea(
      bottom: false,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // ── Header: Greeting + Streak ──
                  _buildHeader(strings),
                  const SizedBox(height: 28),

                  // ── Radar Chart Section ──
                  _buildStatsSection(strings),
                  const SizedBox(height: 28),

                  // ── Today's Training Card ──
                  _buildTodayTrainingCard(strings, langCode),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(AppStrings strings) {
    final displayName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Guest';
    final greeting = _getGreeting(strings);
    final trainCount = _stats?.totalTrainings ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  FirebaseAuth.instance.currentUser?.photoURL ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, color: Colors.white, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $displayName 👋',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Streak / Motivation badge
        if (trainCount > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trainCount >= 10
                      ? '🔥'
                      : trainCount >= 5
                          ? '💪'
                          : '🌱',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  strings.trainingStreakMessage(trainCount),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(AppStrings strings) {
    final avgScore = _stats?.averageScore ?? 0;
    final totalCount = _stats?.totalTrainings ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.textDisabled.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            strings.myAnalysisTitle,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.trending_up,
                  label: strings.averageScoreLabel,
                  value: totalCount > 0 ? '$avgScore' : '-',
                  color: _scoreColor(avgScore),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statItem(
                  icon: Icons.fitness_center,
                  label: strings.totalTrainingsLabel,
                  value: '$totalCount',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 90) return AppColors.accentGreen;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    if (score > 0) return AppColors.accentRed;
    return AppColors.textTertiary;
  }

  Widget _buildTodayTrainingCard(AppStrings strings, String langCode) {
    if (_dailyQuestion == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.textDisabled.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            strings.noTrainingYet,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textTertiary),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF312E81),
                ]
              : [
                  const Color(0xFFF5F3FF),
                  const Color(0xFFEDE9FE),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF6366F1).withValues(alpha: 0.3)
              : const Color(0xFF6366F1).withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TrainingFlowScreen(question: _dailyQuestion!),
              ),
            ).then((_) => _loadData());
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strings.todayTraining,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFA5B4FC)
                              : const Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Refresh Button
                    GestureDetector(
                      onTap: () {
                        // Prevent triggering the card's onTap
                        _refreshDailyQuestion();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: isDark
                              ? const Color(0xFFA5B4FC)
                              : const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: isDark
                          ? const Color(0xFFA5B4FC)
                          : const Color(0xFF6366F1),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Question text
                Text(
                  _dailyQuestion!.getLocalizedQuestion(langCode),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                // CTA button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        strings.startTodayTraining,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    );
  }
}
