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
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            FirebaseAuth.instance.currentUser?.photoURL ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.person,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName ??
                                'Guest',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (_stats != null)
                            Text(
                              '${strings.totalScoreLabel}: ${_stats!.totalTrainings}회 훈련',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textTertiary),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Radar Chart Section
                  _buildRadarSection(strings),
                  const SizedBox(height: 28),

                  // Today's Training Card
                  _buildTodayTrainingCard(strings, langCode),
                  const SizedBox(height: 100),
                ],
              ),
            ),
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
          Text(
            strings.myAbilityRadar,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: RadarChartWidget(
              scores: scores,
              labels: labels,
              size: 240,
            ),
          ),
          const SizedBox(height: 12),
          // Score chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: scores.entries.map((e) {
              final idx = scores.keys.toList().indexOf(e.key);
              final label = idx < labels.length ? labels[idx] : e.key;
              return _scoreChip(label, e.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(String label, int score) {
    final color = score >= 80
        ? AppColors.accentGreen
        : score >= 60
            ? Colors.orange
            : AppColors.accentRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label $score',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrainingFlowScreen(question: _dailyQuestion!),
              ),
            ).then((_) => _loadData());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.bolt, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      strings.todayTraining,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _dailyQuestion!.getLocalizedQuestion(langCode),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          strings.startTodayTraining,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
