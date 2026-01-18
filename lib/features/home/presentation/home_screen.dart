import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../interview/presentation/screens/interview_screen.dart';
import '../../interview/presentation/providers/session_controller.dart';
import '../../interview/data/repositories/interview_repository.dart';
import '../../interview/domain/models/session_model.dart';
import '../../interview/presentation/screens/subject_questions_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';
import 'profile_screen.dart';
import 'lecture_screen.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/ai_service.dart';
import '../../interview/domain/models/question_model.dart';
import '../../interview/presentation/screens/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InterviewRepository _repository = InterviewRepository();
  List<InterviewSession> _sessions = [];
  bool _isLoading = true;
  late String _userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _fetchSessions();
    } else {
      // Should not happen if wrapped in AuthWrapper, but handle safe
      _isLoading = false;
    }
  }

  Future<void> _fetchSessions() async {
    try {
      final sessions = await _repository.fetchUserSessions(_userId);
      if (mounted) {
        setState(() {
          // Filter only completed sessions locally for display
          _sessions = sessions
              .where((s) => s.status == SessionStatus.completed)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to fetch sessions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      // Optimistic update
      setState(() {
        _sessions.removeWhere((s) => s.id == sessionId);
      });
      await _repository.deleteSession(sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Session deleted')));
      }
    } catch (e) {
      print('Failed to delete session: $e');
      // Re-fetch if failed
      _fetchSessions();
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Watch language changes to rebuild the entire screen
    final language = Provider.of<LanguageController>(context).currentLanguage;
    final strings = AppStrings(language);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          // Global Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Main Content
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeContent(strings),
              const LectureScreen(),
              const ProfileScreen(),
            ],
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedIndex == 0
          ? _buildFAB(context, strings)
          : null, // Only show FAB on Home
      bottomNavigationBar: _buildBottomNav(context, strings),
    );
  }

  Widget _buildHomeContent(AppStrings strings) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(strings),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(strings.sectionSubjectLearning,
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Row(
                        children: [
                          _buildSubjectCard(
                              context,
                              Icons.memory,
                              strings.subjectArch,
                              'computer_architecture',
                              Colors.blueGrey),
                          const SizedBox(width: 12),
                          _buildSubjectCard(
                              context,
                              Icons.settings_system_daydream,
                              strings.subjectOS,
                              'operating_system',
                              AppColors.accentRed),
                          const SizedBox(width: 12),
                          _buildSubjectCard(
                              context,
                              Icons.hub,
                              strings.subjectNetwork,
                              'network',
                              AppColors.accentCyan),
                          const SizedBox(width: 12),
                          _buildSubjectCard(
                              context,
                              Icons.storage,
                              strings.subjectDB,
                              'database',
                              const Color(0xFFFFCC00)),
                          const SizedBox(width: 12),
                          _buildSubjectCard(
                              context,
                              Icons.layers,
                              strings.subjectDS,
                              'data_structure',
                              Colors.green),
                          const SizedBox(width: 12),
                          _buildSubjectCard(context, Icons.coffee,
                              strings.subjectJava, 'java', Colors.orange),
                          const SizedBox(width: 12),
                          _buildSubjectCard(context, Icons.code,
                              strings.subjectJs, 'javascript', Colors.yellow),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.recentSessions,
                        style: AppTextStyles.titleLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        onPressed: () {
                          // Silent refresh (keep existing list visible while fetching)
                          if (_sessions.isEmpty) {
                            setState(() => _isLoading = true);
                          }
                          _fetchSessions();
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_sessions.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(strings),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildSessionCard(_sessions[index], strings);
                  },
                  childCount: _sessions.length,
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }

  Widget _buildHeader(AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accentCyan]),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 10)
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      FirebaseAuth.instance.currentUser?.photoURL ??
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBRAYUH3XVSo2OHGdcW1Y2yctt6VetQby1-9G3jFKgvWK3vnVd-FUHUpqwkpiljrGU2Eag2tLtYm3wW8UdZZDnzWHJEmj3eHZh5A4L3guFmS81Kwb0FMrL-AaMnzNqQn_bB47z6Ny-_OtXIEHvhEsWoi_gF-nUSqMbc9OM2P7S-LOLxyqh5krmYasAqZDo3rHj0c5HkgMehOGsP0kT4wdzzSBZxiVGEq2HG-dDIsv8JGcaIlfEF40lAAAraxWGlqvR3KP6SZm_YdpA',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.person,
                              color: Colors.white54, size: 24),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)));
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.readyToInterview,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary, letterSpacing: 1.5)),
                  Text(
                      FirebaseAuth.instance.currentUser?.displayName ?? 'Guest',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          // Language Toggle
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off,
              size: 60, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(strings.recentSessions,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54)),
          const SizedBox(height: 8),
          Text(strings.startNewSession,
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white30)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, IconData icon, String title,
      String id, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectQuestionsScreen(
                subjectId: id,
                subjectName: title,
                themeColor: color,
                icon: icon,
              ),
            ),
          );
          _fetchSessions();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          height: 120, // Fixed height for consistency
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(InterviewSession session, AppStrings strings) {
    // Only show completed sessions
    if (session.status != SessionStatus.completed)
      return const SizedBox.shrink();

    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(session.startTime);

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.accentRed.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('기록 삭제', style: TextStyle(color: Colors.white)),
            content: const Text('이 인터뷰 기록을 삭제하시겠습니까?',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    const Text('취소', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed),
                child: const Text('삭제',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteSession(session.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: InkWell(
          onTap: () => _openSessionDetail(session),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: Colors.white38)),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white30, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('기록 삭제',
                                style: TextStyle(color: Colors.white)),
                            content: const Text('이 인터뷰 기록을 삭제하시겠습니까?',
                                style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('취소',
                                    style: TextStyle(color: Colors.white54)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentRed),
                                child: const Text('삭제',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _deleteSession(session.id);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (session.averageScore != null)
                      Text(
                        '${session.averageScore!.round()}',
                        style: TextStyle(
                            color:
                                _getScoreColor(session.averageScore!.round()),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, AppStrings strings) {
    return Container(
      width: 300,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            AppColors.accentCyan,
            AppColors.primary,
            AppColors.accentCyan
          ],
        ),
        boxShadow: AppColors.neonCyanShadow,
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0B2E),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showStartSessionDialog(context),
            borderRadius: BorderRadius.circular(26),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.accentRed,
                            blurRadius: 10,
                            spreadRadius: 2)
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.startInterviewButton,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(strings.aiStandbyStatus,
                          style: TextStyle(
                              color:
                                  AppColors.accentCyan.withValues(alpha: 0.8),
                              fontSize: 10,
                              letterSpacing: 1)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppStrings strings) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 60 + MediaQuery.paddingOf(context).bottom,
          padding:
              EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F12).withValues(alpha: 0.8),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard, strings.navHome),
              _buildNavItem(1, Icons.menu_book, strings.navLearning),
              _buildNavItem(2, Icons.person_outline, strings.navProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  void _showStartSessionDialog(BuildContext context) {
    // Auto-generate title: "새로운-세션-cf61s2" (Base36, 6 chars)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final randomSuffix = timestamp.substring(timestamp.length - 6);
    final strings = AppStrings(
        Provider.of<LanguageController>(context, listen: false)
            .currentLanguage);

    // Localize default title base
    final defaultTitleBase = strings.defaultSessionTitle.replaceAll(' ', '-');
    final autoTitle = '$defaultTitleBase-$randomSuffix';
    final titleController = TextEditingController(text: autoTitle);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(strings.startNewSession,
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.sessionGoalHint,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              maxLength: 30,
              decoration: InputDecoration(
                hintText: strings.sessionTitleHint,
                hintStyle: const TextStyle(color: Colors.white30),
                counterStyle: const TextStyle(color: Colors.white30),
                labelText: strings.sessionNameLabel,
                labelStyle: const TextStyle(color: AppColors.accentCyan),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
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
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              // Allow using the auto-generated title if user didn't change it
              final title = titleController.text.trim().isEmpty
                  ? autoTitle
                  : titleController.text.trim();
              Navigator.pop(dialogContext); // Close title dialog
              _showSubjectSelectionDialog(
                  context, title); // Open subject dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(strings.nextButtonLabel,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSubjectSelectionDialog(BuildContext context, String title) {
    final strings = AppStrings(
        Provider.of<LanguageController>(context, listen: false)
            .currentLanguage);

    final Map<String, String> subjects = {
      'computer_architecture': strings.subjectArch,
      'operating_system': strings.subjectOS,
      'network': strings.subjectNetwork,
      'database': strings.subjectDB,
      'data_structure': strings.subjectDS,
      'java': strings.subjectJava,
      'javascript': strings.subjectJs,
    };

    // Default: All selected
    List<String> selectedKeys = subjects.keys.toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(strings.selectSubjectTitle,
                  style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.selectSubjectSubtitle,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: subjects.entries.map((entry) {
                          final isSelected = selectedKeys.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedKeys.add(entry.key);
                                } else {
                                  selectedKeys.remove(entry.key);
                                }
                              });
                            },
                            backgroundColor: Colors.white10,
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.3),
                            checkmarkColor: AppColors.accentCyan,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.accentCyan
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.accentCyan
                                    : Colors.transparent,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(strings.cancelButton,
                      style: const TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: selectedKeys.isEmpty
                      ? null // Disable if none selected
                      : () {
                          Navigator.pop(dialogContext);
                          // Call start session with selected subjects
                          // Use outer 'context' (HomeScreen) to ensure it survives the pop
                          _startSession(context, title,
                              targetSubjects: selectedKeys);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.white10,
                  ),
                  child: Text(strings.startInterviewButton,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cleanupIncompleteSessions() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
          const SnackBar(content: Text('Cleaning up incomplete sessions...')));

      // 1. Fetch ALL sessions (including incomplete)
      final allSessions = await _repository.fetchUserSessions(_userId);

      // 2. Filter incomplete ones
      final incomplete = allSessions
          .where((s) => s.status != SessionStatus.completed)
          .toList();

      if (incomplete.isEmpty) {
        messenger.showSnackBar(
            const SnackBar(content: Text('No incomplete sessions found.')));
        return;
      }

      // 3. Delete them
      for (final session in incomplete) {
        await _repository.deleteSession(session.id);
      }

      messenger.showSnackBar(SnackBar(
          content: Text('Deleted ${incomplete.length} incomplete sessions.')));

      // 4. Refresh list
      _fetchSessions();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to cleanup: $e')));
    }
  }

  void _openSessionDetail(InterviewSession session) async {
    // Map existing session items to SessionRounds for display
    final rounds = session.questions.map((q) {
      return SessionRound(
        mainQuestion: Question(
          id: q.questionId,
          question: q.questionText,
          // Use stored metadata if available
          subject: q.subject,
          category: q.category,
          level: 1, // Default level for history
          depth: 0,
          keywords: [],
          tip: '',
        ),
      )
        ..mainAnswer = q.userAnswerText
        ..mainGrade = q.evaluation != null && q.evaluation!['main'] != null
            ? GradeResult.fromJson(q.evaluation!['main'])
            : null
        ..followUpQuestion = q.aiFollowUp
        ..followUpAnswer = q.userFollowUpAnswer
        ..followUpGrade =
            q.evaluation != null && q.evaluation!['followUp'] != null
                ? GradeResult.fromJson(q.evaluation!['followUp'])
                : null;
    }).toList();

    // Calculate score
    final avgScore = session.averageScore ?? 0.0;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterviewResultScreen(
          rounds: rounds,
          averageScore: avgScore,
          // Optionally pass a new controller for Retrying historical sessions
        ),
      ),
    );

    // Handle Retry
    if (result != null &&
        result is Map &&
        result['action'] == 'retry' &&
        result['questions'] is List<Question>) {
      print('[HomeScreen] Retry requested for: ${result['title']}');
      if (mounted) {
        // Start new session with fixed questions
        await _startSession(
          context,
          result['title'],
          fixedQuestions: result['questions'],
        );
      }
    }

    // Always fetch sessions to ensure list is updated
    _fetchSessions();
  }

  Future<void> _startSession(BuildContext context, String title,
      {List<String>? targetSubjects, List<Question>? fixedQuestions}) async {
    // For testing: bypass login check
    // final authService = AuthService();
    // final user = authService.currentUser;
    final userId = _userId;

    final controller = SessionController();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await controller.startNewSession(userId, title,
          targetSubjects: targetSubjects, fixedQuestions: fixedQuestions);

      print('[StartSession] Session started successfully');

      if (!context.mounted) return;
      Navigator.pop(context); // Pop loading
      print('[StartSession] Navigating to InterviewScreen');
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InterviewScreen(controller: controller)),
      );
      // Refresh list after returning from session
      _fetchSessions();
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Pop loading
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF00E676); // Green Accent
    if (score >= 50) return AppColors.accentCyan;
    return AppColors.accentRed;
  }
}
