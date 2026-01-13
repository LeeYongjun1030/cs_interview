import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CS Interview Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!),
                radius: 40,
              ),
            const SizedBox(height: 16),
            Text(
              'Welcome Back,',
              style: AppTextStyles.headlineSmall,
            ),
            Text(
              user?.displayName ?? 'Developer',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            Text(
              'Select a subject to start training',
              style: AppTextStyles.bodyLarge,
            ),
            // TODO: Subject Grid
          ],
        ),
      ),
    );
  }
}
