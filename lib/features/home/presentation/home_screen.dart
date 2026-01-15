import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart'; // Ensure correct path
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/data_seeder.dart';
import '../../interview/presentation/screens/interview_screen.dart';
import '../../interview/presentation/providers/session_controller.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/data_seeder.dart';
import '../../interview/presentation/screens/interview_screen.dart';
import '../../interview/presentation/providers/session_controller.dart';
import '../../interview/data/repositories/interview_repository.dart';
import '../../interview/domain/models/session_model.dart';
import '../../interview/presentation/screens/subject_questions_screen.dart';
import 'profile_screen.dart'; // Added import
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

  @override
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
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ),
          ),
          
          // Main Content
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeContent(),
              const Center(child: Text('멤버십 화면 준비중', style: TextStyle(color: Colors.white))), // Placeholder for Membership
              const ProfileScreen(),
            ],
          ),
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedIndex == 0 ? _buildFAB(context) : null, // Only show FAB on Home
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
            child: Text('과목별 학습', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSubjectCard(context, Icons.hub, 'Network', AppColors.accentCyan),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.memory, 'OS', AppColors.accentRed),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.storage, 'Database', const Color(0xFFFFCC00)),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.code, 'Algorithm', Colors.purple),
                const SizedBox(width: 12),
                _buildSubjectCard(context, Icons.layers, 'DataStructure', Colors.green),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Sessions', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
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
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120), // More bottom padding for nav
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
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accentCyan]),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBRAYUH3XVSo2OHGdcW1Y2yctt6VetQby1-9G3jFKgvWK3vnVd-FUHUpqwkpiljrGU2Eag2tLtYm3wW8UdZZDnzWHJEmj3eHZh5A4L3guFmS81Kwb0FMrL-AaMnzNqQn_bB47z6Ny-_OtXIEHvhEsWoi_gF-nUSqMbc9OM2P7S-LOLxyqh5krmYasAqZDo3rHj0c5HkgMehOGsP0kT4wdzzSBZxiVGEq2HG-dDIsv8JGcaIlfEF40lAAAraxWGlqvR3KP6SZm_YdpA'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('READY TO INTERVIEW?', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, letterSpacing: 1.5)),
                  Text('Kim Dev', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          // Admin Seed Button (Hidden style)
          InkWell(
            onLongPress: () async {
               final seeder = DataSeeder();
               await seeder.seedData();
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Seeded')));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.settings, color: Colors.white70, size: 20),
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
          Icon(Icons.history_toggle_off, size: 60, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('아직 면접 기록이 없습니다.', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54)),
          const SizedBox(height: 8),
          Text('아래 버튼을 눌러 첫 세션을 시작해보세요!', style: AppTextStyles.labelMedium.copyWith(color: Colors.white30)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, IconData icon, String title, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectQuestionsScreen(
                subject: title,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24), 
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
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
                  color: isCompleted ? AppColors.accentGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
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
              Text(dateStr, style: AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.title,
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
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
          colors: [AppColors.accentCyan, AppColors.primary, AppColors.accentCyan],
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
                      boxShadow: [BoxShadow(color: AppColors.accentRed, blurRadius: 10, spreadRadius: 2)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('실전 면접 시작', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('AI INTERVIEWER STANDBY', style: TextStyle(color: AppColors.accentCyan.withOpacity(0.8), fontSize: 10, letterSpacing: 1)),
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
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F12).withOpacity(0.8),
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
              width: 4, height: 4,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  void _showStartSessionDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('세션 시작', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('이번 면접 세션의 목표나 제목을 정해주세요.', style: TextStyle(color: Colors.white70)),
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
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              Navigator.pop(dialogContext);
              _startSession(context, titleController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(BuildContext context, String title) async {
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
      await controller.startNewSession(userId, title);
      
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InterviewScreen(controller: controller)),
        );
        // Refresh list after returning from session
        _fetchSessions();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
