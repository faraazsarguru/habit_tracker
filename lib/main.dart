import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'YOUR_WEB_API_KEY',
        authDomain: 'habitzzz-b7ced.firebaseapp.com',
        projectId: 'habitzzz-b7ced',
        storageBucket: 'habitzzz-b7ced.appspot.com',
        messagingSenderId: 'YOUR_SENDER_ID',
        appId: 'YOUR_WEB_APP_ID',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const HabitzzApp(),
    ),
  );
}

class HabitzzApp extends StatelessWidget {
  const HabitzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
      title: 'Habitzzz',
      debugShowCheckedModeBanner: false,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MainScaffold(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
