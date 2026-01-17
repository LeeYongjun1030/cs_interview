import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';
import '../../interview/data/repositories/interview_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final InterviewRepository _repository = InterviewRepository();

  Future<void> _clearData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('데이터 초기화', style: TextStyle(color: Colors.white)),
        content: const Text('모든 인터뷰 기록이 영구적으로 삭제됩니다.\n정말 삭제하시겠습니까?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            child:
                const Text('삭제', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteAllUserSessions(user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('모든 데이터가 초기화되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류 발생: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              // Header
              if (FirebaseAuth.instance.currentUser != null) ...[
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
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
                          border:
                              Border.all(color: AppColors.background, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundImage: FirebaseAuth
                                      .instance.currentUser?.photoURL !=
                                  null
                              ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!)
                              : null,
                          child: FirebaseAuth.instance.currentUser?.photoURL ==
                                  null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            FirebaseAuth.instance.currentUser?.displayName ??
                                'User',
                            style: AppTextStyles.titleLarge
                                .copyWith(fontWeight: FontWeight.bold)),
                        Text(
                            FirebaseAuth.instance.currentUser?.email ??
                                'No Email',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              Text('Settings',
                  style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTertiary)),
              const SizedBox(height: 16),

              // Settings List
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Consumer<LanguageController>(
                      builder: (context, controller, child) {
                        return SwitchListTile(
                          title: const Text('Language (한국어/Eng)',
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                              controller.isKorean
                                  ? '현재: 한국어'
                                  : 'Current: English',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                          value: !controller.isKorean, // True if English
                          activeColor: AppColors.primary,
                          onChanged: (value) => controller.toggleLanguage(),
                          secondary:
                              const Icon(Icons.language, color: Colors.white70),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('Account',
                  style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTertiary)),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white70),
                      title: const Text('로그아웃',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        // AuthService().signOut(); // TODO: Implement sign out
                      },
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.white70),
                      title: const Text('기록 초기화',
                          style: TextStyle(color: Colors.white)),
                      onTap: _clearData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                  child: Text('Version 1.0.0',
                      style: TextStyle(color: Colors.white30, fontSize: 12))),
              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}
