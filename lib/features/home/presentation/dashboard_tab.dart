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
import 'widgets/radar_chart_widget.dart';
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
      final daily = await _repository.getDailyQuestion(uid);
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

  void _showAnalysisInfo(AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.myAnalysisTitle,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          strings.analysisExplanation,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.confirmButton,
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                  _buildRadarSection(strings),
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

  Widget _buildRadarSection(AppStrings strings) {
    final labels = [
      strings.axisSummary,
      strings.axisPrinciple,
      strings.axisExample,
      strings.axisKeyword,
      strings.axisClarity,
      strings.axisFollowUp,
    ];

    final scores = _stats?.stats ??
        {
          'summary': 50,
          'principle': 50,
          'example': 50,
          'keyword': 50,
          'clarity': 50,
          'followUp': 50,
        };

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                strings.myAnalysisTitle,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showAnalysisInfo(strings),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: RadarChartWidget(
              scores: scores,
              labels: labels,
              size: 240,
            ),
          ),
        ],
      ),
    );
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
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text(
                  strings.confirmTrainingTitle,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                content: Text(
                  strings.confirmTrainingMessage,
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(strings.cancelButton,
                        style: TextStyle(color: AppColors.textTertiary)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TrainingFlowScreen(question: _dailyQuestion!),
                        ),
                      ).then((_) => _loadData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(strings.startAction,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
