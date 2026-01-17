import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/session_controller.dart';

class InterviewResultScreen extends StatelessWidget {
  final List<SessionRound> rounds;
  final double averageScore;

  const InterviewResultScreen({
    super.key,
    required this.rounds,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    final displayScore = averageScore.round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            const Text('면접 결과 Report', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.neonShadow,
              ),
              child: Column(
                children: [
                  Text(
                    '종합 점수',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${displayScore}점',
                    style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getCheerMessage(displayScore),
                    style:
                        AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details List
            ...rounds.asMap().entries.map((entry) {
              final index = entry.key;
              final round = entry.value;
              return Column(
                children: [
                  _buildRoundCard(index + 1, round),
                  const SizedBox(height: 16),
                ],
              );
            }),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child:
                  const Text('홈으로 이동', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundCard(int index, SessionRound round) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Q$index',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  round.mainQuestion.question,
                  style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (round.mainGrade != null)
                Text(
                  '${round.mainGrade!.score}점',
                  style: TextStyle(
                      color: _getScoreColor(round.mainGrade!.score),
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
          // Main Answer Display
          if (round.mainAnswer != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('나의 답변',
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(round.mainAnswer!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Main Feedback
          if (round.mainGrade != null) ...[
            Text('AI 피드백: ${round.mainGrade!.feedback}',
                style:
                    const TextStyle(color: AppColors.accentCyan, fontSize: 13)),
          ] else ...[
            const Text('피드백 없음',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],

          // Follow Up Section if exists
          if (round.followUpQuestion != null) ...[
            const Divider(color: Colors.white10, height: 24),
            Row(
              children: [
                const Icon(Icons.subdirectory_arrow_right,
                    color: AppColors.accentRed, size: 16),
                const SizedBox(width: 8),
                const Text('AI 꼬리 질문',
                    style: TextStyle(
                        color: AppColors.accentRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (round.followUpGrade != null)
                  Text(
                    '${round.followUpGrade!.score}점',
                    style: TextStyle(
                        color: _getScoreColor(round.followUpGrade!.score),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(round.followUpQuestion!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            if (round.followUpAnswer != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('나의 답변',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(round.followUpAnswer!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
            if (round.followUpGrade != null) ...[
              const SizedBox(height: 8),
              Text('AI 피드백: ${round.followUpGrade!.feedback}',
                  style: const TextStyle(
                      color: AppColors.accentCyan, fontSize: 12)),
            ]
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.accentGreen;
    if (score >= 50) return AppColors.accentCyan;
    return AppColors.accentRed;
  }

  String _getCheerMessage(int score) {
    if (score >= 90) return '완벽해요! 면접 마스터시네요 🏆';
    if (score >= 70) return '훌륭해요! 조금만 더 다듬으면 완벽할 거예요 🚀';
    if (score >= 50) return '좋아요! 부족한 부분을 보완해볼까요? 💪';
    return '시작이 반이에요! 꾸준히 연습해봐요 🌱';
  }
}
