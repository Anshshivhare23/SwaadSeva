import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (we'll add this later)
  // await Firebase.initializeApp();
  
  runApp(const SwaadSevaApp());
}

class SwaadSevaApp extends StatelessWidget {
  const SwaadSevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
