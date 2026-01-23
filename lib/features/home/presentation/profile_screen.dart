import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';
import '../../interview/data/repositories/interview_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final InterviewRepository _repository = InterviewRepository();

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  Future<void> _clearData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final strings =
        Provider.of<LanguageController>(context, listen: false).strings;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(strings.resetDialogTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(strings.resetDialogContent,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancelButton,
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            child: Text(strings.deleteAction,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
    // Access strings via LanguageController
    final strings = Provider.of<LanguageController>(context).strings;

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
              if (FirebaseAuth.instance.currentUser != null) ...[
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [],
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

              Text(strings.settingsTitle,
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
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.language,
                                      color: Colors.white70),
                                  const SizedBox(width: 12),
                                  Text(
                                    strings.languageSettingTitle,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => controller
                                          .setLanguage(AppLanguage.korean),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: controller.isKorean
                                              ? AppColors.primary
                                              : Colors.white
                                                  .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: controller.isKorean
                                                ? AppColors.primary
                                                : Colors.white10,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '🇰🇷 한국어',
                                          style: TextStyle(
                                            color: controller.isKorean
                                                ? Colors.white
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => controller
                                          .setLanguage(AppLanguage.english),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !controller.isKorean
                                              ? AppColors.primary
                                              : Colors.white
                                                  .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: !controller.isKorean
                                                ? AppColors.primary
                                                : Colors.white10,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '🇺🇸 English',
                                          style: TextStyle(
                                            color: !controller.isKorean
                                                ? Colors.white
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(strings.accountTitle,
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
                      title: Text(strings.logoutLabel,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () async {
                        try {
                          await AuthService().signOut();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logout failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.white70),
                      title: Text(strings.resetDataLabel,
                          style: const TextStyle(color: Colors.white)),
                      onTap: _clearData,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(strings.supportTitle,
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
                      leading: const Icon(Icons.email, color: Colors.white70),
                      title: Text(strings.contactLabel,
                          style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.white30),
                      onTap: () => _launchUrl(
                          'mailto:yiyj1516@gmail.com?Subject=CS Interview Coach Inquiry'),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    ListTile(
                      leading:
                          const Icon(Icons.privacy_tip, color: Colors.white70),
                      title: Text(strings.privacyLabel,
                          style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.white30),
                      onTap: () => _launchUrl(
                          'https://cs-interview-66fb7.web.app'), // Placeholder
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
