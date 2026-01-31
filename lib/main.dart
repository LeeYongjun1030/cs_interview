import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // Added
import 'package:firebase_remote_config/firebase_remote_config.dart'; // Added
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'core/localization/language_service.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/auth/presentation/login_screen.dart';

import 'features/monetization/data/repositories/credit_repository.dart';
import 'features/monetization/services/ad_service.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final adService = AdService();
  // Initialize Firebase & Ads
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageController()),
          ChangeNotifierProvider(create: (_) => ThemeController()),
          Provider(create: (_) => CreditRepository()),
          Provider.value(value: adService), // Inject service
        ],
        child: const MyApp(),
      ),
    );

    // Run heavy initializations in background after UI mount
    _initializeServices(adService);
  } catch (e, stackTrace) {
    print("Failed to initialize Firebase: $e");
    runApp(ErrorApp(error: e.toString(), stackTrace: stackTrace));
  }
}

Future<void> _initializeServices(AdService adService) async {
  try {
    // 1. Activate App Check
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleDeviceCheckProvider(),
      providerWeb: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );

    // 2. Initialize Ads
    await adService.initialize();

    // 3. Initialize Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval:
          kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 12),
    ));

    await remoteConfig.setDefaults({
      "model_name": "gemini-2.5-flash-lite",
    });

    await remoteConfig.fetchAndActivate();
  } catch (e) {
    debugPrint("Background Initialization Failed: $e");
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  final StackTrace? stackTrace;

  const ErrorApp({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to Initialize App',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: const TextStyle(
                        color: Colors.redAccent, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes to support dynamic switching
    context.watch<ThemeController>();

    return MaterialApp(
      title: 'SocrAItes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
