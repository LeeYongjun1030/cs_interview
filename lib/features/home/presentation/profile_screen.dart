import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/language_service.dart';
import '../../interview/data/repositories/interview_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../monetization/data/repositories/credit_repository.dart';

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
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(strings.resetDialogContent,
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancelButton,
                style: TextStyle(color: AppColors.textSecondary)),
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

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final strings =
        Provider.of<LanguageController>(context, listen: false).strings;
    final creditRepo = Provider.of<CreditRepository>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(strings.deleteAccountDialogTitle,
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(strings.deleteAccountDialogContent,
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancelButton,
                style: TextStyle(color: AppColors.textSecondary)),
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
        // 1. Delete Sessions (Firestore)
        await _repository.deleteAllUserSessions(user.uid);

        // 2. Delete User Data (Credits, etc.) (Firestore)
        await creditRepo.deleteUser(user.uid);

        // 3. Delete Auth Account (Firebase Auth)
        await AuthService().deleteAccount();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.deleteAccountSuccess)),
          );
          // Force UI to Login Screen immediately (Remove all previous routes)
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          if (mounted) {
            // Sign out to force re-login
            await AuthService().signOut();

            // Show dialog explaining why
            await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text(strings.deleteAccountDialogTitle,
                          style: TextStyle(color: AppColors.textPrimary)),
                      content: Text(strings.deleteAccountReauth,
                          style: TextStyle(color: AppColors.textSecondary)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text('OK',
                                style: TextStyle(color: AppColors.primary)))
                      ],
                    ));

            // Navigate to Login Screen
            if (mounted) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.message}')),
            );
          }
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
    // Watch ThemeController to rebuild on theme change
    context.watch<ThemeController>();

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
                                .copyWith(color: AppColors.textSecondary)),
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
                  border: Border.all(
                      color: AppColors.textDisabled.withValues(alpha: 0.2)),
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
                                  Icon(Icons.language,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    strings.languageSettingTitle,
                                    style:
                                        TextStyle(color: AppColors.textPrimary),
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
                                              : AppColors.surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: controller.isKorean
                                                ? AppColors.primary
                                                : AppColors.textDisabled
                                                    .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '🇰🇷 한국어',
                                          style: TextStyle(
                                            color: controller.isKorean
                                                ? Colors.white
                                                : AppColors.textSecondary,
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
                                              : AppColors.surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: !controller.isKorean
                                                ? AppColors.primary
                                                : AppColors.textDisabled
                                                    .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '🇺🇸 English',
                                          style: TextStyle(
                                            color: !controller.isKorean
                                                ? Colors.white
                                                : AppColors.textSecondary,
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
                    const Divider(height: 1, color: Colors.black12),
                    Consumer<ThemeController>(
                      builder: (context, themeController, child) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.brightness_6,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    strings.themeSettingTitle,
                                    style:
                                        TextStyle(color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => themeController
                                          .setThemeMode(ThemeMode.light),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !themeController.isDarkMode
                                              ? AppColors.primary
                                              : AppColors.surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: !themeController.isDarkMode
                                                ? AppColors.primary
                                                : AppColors.textDisabled
                                                    .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          strings.themeLight,
                                          style: TextStyle(
                                            color: !themeController.isDarkMode
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => themeController
                                          .setThemeMode(ThemeMode.dark),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: themeController.isDarkMode
                                              ? AppColors.primary
                                              : AppColors.surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: themeController.isDarkMode
                                                ? AppColors.primary
                                                : AppColors.textDisabled
                                                    .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          strings.themeDark,
                                          style: TextStyle(
                                            color: themeController.isDarkMode
                                                ? Colors.white
                                                : AppColors.textSecondary,
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
                  border: Border.all(
                      color: AppColors.textDisabled.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.logout, color: AppColors.textSecondary),
                      title: Text(strings.logoutLabel,
                          style: TextStyle(color: AppColors.textPrimary)),
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
                    const Divider(height: 1, color: Colors.black12),
                    ListTile(
                      leading:
                          Icon(Icons.refresh, color: AppColors.textSecondary),
                      title: Text(strings.resetDataLabel,
                          style: TextStyle(color: AppColors.textPrimary)),
                      onTap: _clearData,
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    ListTile(
                      leading:
                          Icon(Icons.person_off, color: AppColors.accentRed),
                      title: Text(strings.deleteAccountLabel,
                          style: TextStyle(color: AppColors.accentRed)),
                      onTap: _deleteAccount,
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
                  border: Border.all(
                      color: AppColors.textDisabled.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.email, color: AppColors.textSecondary),
                      title: Text(strings.contactLabel,
                          style: TextStyle(color: AppColors.textPrimary)),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppColors.textTertiary),
                      onTap: () => _launchUrl(
                          'mailto:yiyj1516@gmail.com?Subject=CS Interview Coach Inquiry'),
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    ListTile(
                      leading: Icon(Icons.privacy_tip,
                          color: AppColors.textSecondary),
                      title: Text(strings.privacyLabel,
                          style: TextStyle(color: AppColors.textPrimary)),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppColors.textTertiary),
                      onTap: () => _launchUrl(
                          'https://cs-interview-66fb7.web.app'), // Placeholder
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                  child: Text('Version 1.0.0',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 12))),
              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}
