import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/data_seeder.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoginLoading = false;
  bool _isSeedLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoginLoading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoginLoading = false);
    }
  }

  Future<void> _handleGitHubSignIn() async {
    setState(() => _isLoginLoading = true);
    try {
      await _authService.signInWithGitHub();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoginLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Need consumer here
    final strings =
        AppStrings(Provider.of<LanguageController>(context).currentLanguage);

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Title
              Text(
                strings.loginTitle,
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                strings.loginSubtitle,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Login Button
              ElevatedButton.icon(
                onPressed: (_isLoginLoading || _isSeedLoading)
                    ? null
                    : _handleGoogleSignIn,
                icon: _isLoginLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Image.asset(
                        'assets/images/google_logo.png', // Assuming no asset, using Icon
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons
                                .login)), // Oh, previously it was Icon(Icons.login).
                // User asked for "Google login". Usually uses G logo.
                // Previous code: const Icon(Icons.login). I will stick to Icon for consistency unless I have asset.
                // I'll keep previous Icon logic but maybe change icon type?
                // Material Icons doesn't have Google logo.
                // I'll stick to Icon(Icons.login) for Google for now to match previous code, or ensure I don't break it.
                // Wait, I should not change Google button style if not requested.
                // But for GitHub I need an icon? `FontAwesome` not installed.
                // I'll use `Icons.code` or just text. Or `Icons.login` with different color?
                // I'll use `Icons.person` for GitHub or similar.
                icon: _isLoginLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login,
                        color: Colors.white), // Added color
                label: Text(
                  _isLoginLoading ? strings.signingIn : strings.signInGoogle,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: (_isLoginLoading || _isSeedLoading)
                    ? null
                    : _handleGitHubSignIn,
                icon: const Icon(Icons.code,
                    color: Colors.white), // Placeholder for GitHub
                label: Text(
                  strings.signInGitHub,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24292e), // GitHub Dark Color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                strings.loginFooter,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
