import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CS Interview Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Apply the High-End Dark Mode
      home: const Scaffold(
        body: Center(
          child: Text('CS Interview Coach\nInitializing...', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
