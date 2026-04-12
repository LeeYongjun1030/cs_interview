import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/localization/language_service.dart';
import '../../../interview/data/repositories/interview_repository.dart';
import '../../../training/domain/models/training_session_model.dart';
import 'record_detail_screen.dart';

/// Records tab — shows list of completed training sessions.
class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key});

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  final InterviewRepository _repository = InterviewRepository();
  Stream<List<TrainingSession>>? _sessionsStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _sessionsStream = _repository.getTrainingSessionsStream(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final strings = Provider.of<LanguageController>(context).strings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                strings.recordsTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: _sessionsStream == null
                  ? Center(
                      child: Text(strings.noRecordsYet,
                          style: TextStyle(color: AppColors.textTertiary)),
                    )
                  : StreamBuilder<List<TrainingSession>>(
                      stream: _sessionsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 48, color: AppColors.accentRed),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${strings.noRecordsYet}\n\n${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final sessions = snapshot.data ?? [];
                        if (sessions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off,
                                    size: 60, color: AppColors.textTertiary),
                                const SizedBox(height: 16),
                                Text(
                                  strings.noRecordsYet,
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: sessions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _SessionCard(
                              session: sessions[index],
                              strings: strings,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecordDetailScreen(
                                        session: sessions[index]),
                                  ),
                                );
                              },
                              onDelete: () =>
                                  _deleteSession(sessions[index].id),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSession(String id) async {
    try {
      await _repository.deleteTrainingSession(id);
    } catch (e) {
      debugPrint('Delete training session error: $e');
    }
  }
}

class _SessionCard extends StatelessWidget {
  final TrainingSession session;
  final AppStrings strings;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.strings,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(session.createdAt);
    final score = session.feedback?.score;

    Color scoreColor;
    if (score == null) {
      scoreColor = AppColors.textTertiary;
    } else if (score >= 90) {
      scoreColor = AppColors.accentGreen;
    } else if (score >= 75) {
      scoreColor = Colors.blue;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = AppColors.accentRed;
    }

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.accentRed.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(strings.deleteSessionTitle,
                style: TextStyle(color: AppColors.textPrimary)),
            content: Text(strings.deleteSessionContent,
                style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(strings.cancelButton,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed),
                child: Text(strings.deleteAction,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.textDisabled.withValues(alpha: 0.1)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textTertiary)),
                      if (score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$score',
                            style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.questionText,
                    style: AppTextStyles.titleSmall
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.subject} · ${session.category}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
