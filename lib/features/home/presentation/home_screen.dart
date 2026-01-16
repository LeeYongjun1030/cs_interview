import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/data_seeder.dart';
import '../../interview/presentation/screens/interview_screen.dart';
import '../../interview/presentation/providers/session_controller.dart';
import '../../interview/data/repositories/interview_repository.dart';
import '../../interview/domain/models/session_model.dart';
import '../../interview/presentation/screens/subject_questions_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InterviewRepository _repository = InterviewRepository();
  List<InterviewSession> _sessions = [];
  bool _isLoading = true;
  // For MVP testing, using fixed ID
  final String _userId = 'test-user-id';

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final sessions = await _repository.fetchUserSessions(_userId);
      if (mounted) {
        setState(() {
          _sessions = sessions;
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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              _buildHomeContent(),
              const Center(
                  child: Text('멤버십 화면 준비중',
                      style: TextStyle(
                          color: Colors.white))), // Placeholder for Membership
              const ProfileScreen(),
            ],
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedIndex == 0
          ? _buildFAB(context)
          : null, // Only show FAB on Home
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('과목별 학습',
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
                _buildSubjectCard(context, Icons.memory, '컴퓨터구조',
                    'computer_architecture', Colors.blueGrey),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.settings_system_daydream,
                    '운영체제', 'operating_system', AppColors.accentRed),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.hub, '네트워크', 'network',
                    AppColors.accentCyan),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.storage, '데이터베이스', 'database',
                    const Color(0xFFFFCC00)),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.layers, '자료구조',
                    'data_structure', Colors.green),
                const SizedBox(width: 12),
                _buildSubjectCard(
                    context, Icons.coffee, 'Java', 'java', Colors.orange),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.code, 'JavaScript',
                    'javascript', Colors.yellow),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Sessions',
                    style: AppTextStyles.titleLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _fetchSessions();
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 120), // More bottom padding for nav
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          return _buildSessionCard(_sessions[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                  child: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBRAYUH3XVSo2OHGdcW1Y2yctt6VetQby1-9G3jFKgvWK3vnVd-FUHUpqwkpiljrGU2Eag2tLtYm3wW8UdZZDnzWHJEmj3eHZh5A4L3guFmS81Kwb0FMrL-AaMnzNqQn_bB47z6Ny-_OtXIEHvhEsWoi_gF-nUSqMbc9OM2P7S-LOLxyqh5krmYasAqZDo3rHj0c5HkgMehOGsP0kT4wdzzSBZxiVGEq2HG-dDIsv8JGcaIlfEF40lAAAraxWGlqvR3KP6SZm_YdpA'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('READY TO INTERVIEW?',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary, letterSpacing: 1.5)),
                  Text('Kim Dev',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          // Admin Seed Button (Hidden style)
          InkWell(
            onLongPress: () async {
              final seeder = DataSeeder();
              await seeder.seedData();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Data Seeded')));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8)),
              child:
                  const Icon(Icons.settings, color: Colors.white70, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off,
              size: 60, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('아직 면접 기록이 없습니다.',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54)),
          const SizedBox(height: 8),
          Text('아래 버튼을 눌러 첫 세션을 시작해보세요!',
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
        onTap: () {
          Navigator.push(
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
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(InterviewSession session) {
    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(session.startTime);
    final questionCount = session.questions.length;
    final isCompleted = session.status == SessionStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.accentGreen.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                  style: TextStyle(
                    color: isCompleted ? AppColors.accentGreen : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(dateStr,
                  style:
                      AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.title,
            style:
                AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$questionCount Questions • Network', // Hardcoded subject for now
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
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
                      const Text('실전 면접 시작',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text('AI INTERVIEWER STANDBY',
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

  Widget _buildBottomNav(BuildContext context) {
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
              _buildNavItem(0, Icons.dashboard, '홈'),
              _buildNavItem(1, Icons.diamond_outlined, '멤버십'),
              _buildNavItem(2, Icons.person_outline, '프로필'),
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
    final autoTitle = '새로운-세션-$randomSuffix';
    final titleController = TextEditingController(text: autoTitle);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('세션 시작', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이번 면접 세션의 목표나 제목을 정해주세요.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              maxLength: 30,
              decoration: const InputDecoration(
                hintText: '예: 네트워크 뿌시기',
                hintStyle: TextStyle(color: Colors.white30),
                counterStyle: TextStyle(color: Colors.white30),
                labelText: '세션 제목',
                labelStyle: TextStyle(color: AppColors.accentCyan),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
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
            child:
                const Text('다음', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSubjectSelectionDialog(BuildContext context, String title) {
    final Map<String, String> subjects = {
      'computer_architecture': '컴퓨터 구조',
      'operating_system': '운영체제',
      'network': '네트워크',
      'database': '데이터베이스',
      'data_structure': '자료구조',
      'java': '자바',
      'javascript': '자바스크립트',
    };

    // Default: All selected
    List<String> selectedKeys = subjects.keys.toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title:
                  const Text('출제 과목 선택', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '원하는 과목을 선택해주세요. (복수 선택 가능)',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
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
                  child:
                      const Text('취소', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: selectedKeys.isEmpty
                      ? null // Disable if none selected
                      : () {
                          Navigator.pop(dialogContext);
                          // Call start session with selected subjects
                          _startSession(context, title,
                              targetSubjects: selectedKeys);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.white10,
                  ),
                  child: const Text('면접 시작',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _startSession(BuildContext context, String title,
      {List<String>? targetSubjects}) async {
    // For testing: bypass login check
    // final authService = AuthService();
    // final user = authService.currentUser;
    final userId = _userId;

    final controller = SessionController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await controller.startNewSession(userId, title,
          targetSubjects: targetSubjects);

      if (!context.mounted) return;
      Navigator.pop(context); // Pop loading
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
}
