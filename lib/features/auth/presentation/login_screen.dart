import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/language_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isGoogleLoading = false;
  bool _isGitHubLoading = false;
  bool _isAppleLoading = false;

  bool get _isAnyLoading =>
      _isGoogleLoading || _isGitHubLoading || _isAppleLoading;

  bool _isCancelledError(dynamic e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('cancel') ||
        msg.contains('popup_closed') ||
        msg.contains('web_context_cancelled');
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (_isCancelledError(e.code) || _isCancelledError(e.message)) return;
      if (mounted) {
        String message = e.message ?? 'Login failed';
        if (e.code == 'account-exists-with-different-credential') {
          message = Provider.of<LanguageController>(context, listen: false)
              .strings
              .errorAccountExistsWithDifferentCredential;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (_isCancelledError(e)) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleGitHubSignIn() async {
    setState(() => _isGitHubLoading = true);
    try {
      await _authService.signInWithGitHub();
    } on FirebaseAuthException catch (e) {
      if (_isCancelledError(e.code) || _isCancelledError(e.message)) return;
      if (mounted) {
        String message = e.message ?? 'Login failed';
        if (e.code == 'account-exists-with-different-credential') {
          message = Provider.of<LanguageController>(context, listen: false)
              .strings
              .errorAccountExistsWithDifferentCredential;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (_isCancelledError(e)) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGitHubLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isAppleLoading = true);
    try {
      await _authService.signInWithApple();
    } on FirebaseAuthException catch (e) {
      if (_isCancelledError(e.code) || _isCancelledError(e.message)) return;
      if (mounted) {
        String message = e.message ?? 'Login failed';
        if (e.code == 'account-exists-with-different-credential') {
          message = Provider.of<LanguageController>(context, listen: false)
              .strings
              .errorAccountExistsWithDifferentCredential;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (_isCancelledError(e)) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://cs-interview-66fb7.web.app/#privacy');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Privacy Policy')),
        );
      }
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
                onPressed: _isAnyLoading ? null : _handleGoogleSignIn,
                icon: _isGoogleLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login, color: Colors.white),
                label: Text(
                  _isGoogleLoading ? strings.signingIn : strings.signInGoogle,
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
                onPressed: _isAnyLoading ? null : _handleGitHubSignIn,
                icon: _isGitHubLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.code,
                        color: Colors.white), // Placeholder for GitHub
                label: Text(
                  _isGitHubLoading ? strings.signingIn : strings.signInGitHub,
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
              if (Platform.isIOS) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isAnyLoading ? null : _handleAppleSignIn,
                  icon: _isAppleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.apple, color: Colors.white),
                  label: Text(
                    _isAppleLoading ? strings.signingIn : strings.signInApple,
                    style:
                        AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Consent Text
              GestureDetector(
                onTap: _launchPrivacyPolicy,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(text: strings.loginConsentStart),
                      TextSpan(
                        text: strings.loginConsentLink,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(text: strings.loginConsentEnd),
                    ],
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
