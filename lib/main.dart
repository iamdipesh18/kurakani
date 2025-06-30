import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:kurakani/firebase_options.dart';
import 'package:kurakani/themes/theme_provider.dart';
import 'package:kurakani/themes/dark_mode.dart';
import 'package:kurakani/themes/light_mode.dart';
import 'package:kurakani/services/auth/auth_gate.dart'; // ✅ use this now

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? darkMode : lightMode,
      home: const AuthGate(), // 🔐 all logic handled here
    );
  }
}
