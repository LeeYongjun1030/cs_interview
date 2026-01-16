import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock Data for MVP
  final bool _isPremium = true;
  final int _daysLeft = 12;
  bool _notificationEnabled = true;
  bool _soundEnabled = true;

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
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accentCyan]),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)],
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
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kim Dev', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text('kim.dev@example.com', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Membership Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A0B2E), Color(0xFF2D1B4E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('MY MEMBERSHIP', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentCyan, letterSpacing: 1.5)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_isPremium ? 'PRO' : 'FREE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'D-$_daysLeft',
                          style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Days Left',
                          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.6, // Mock value
                      backgroundColor: Colors.white10,
                      color: AppColors.accentCyan,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('기간 연장하기', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text('Settings', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
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
                    SwitchListTile(
                      title: const Text('일일 학습 알림', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('매일 저녁 8시에 알림', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      value: _notificationEnabled,
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withAlpha(100), // Lighter track
                      onChanged: (value) => setState(() => _notificationEnabled = value),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    SwitchListTile(
                      title: const Text('배경음 및 효과음', style: TextStyle(color: Colors.white)),
                      value: _soundEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (value) => setState(() => _soundEnabled = value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('Account', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
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
                      leading: const Icon(Icons.description_outlined, color: Colors.white70),
                      title: const Text('이용약관', style: TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white70),
                      title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
                      onTap: () {
                         // AuthService().signOut();
                      },
                    ),
                    const Divider(height: 1, color: Colors.white10),
                     ListTile(
                      leading: const Icon(Icons.delete_outline, color: AppColors.accentRed),
                      title: const Text('회원 탈퇴', style: TextStyle(color: AppColors.accentRed)),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.white30, fontSize: 12))),
              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}
