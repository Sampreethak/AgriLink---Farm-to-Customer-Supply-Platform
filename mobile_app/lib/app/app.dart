import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/customer/customer_dashboard.dart';
import 'theme.dart';

class AgriLinkApp extends StatelessWidget {
  const AgriLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "AgriLink",

      theme: AppTheme.lightTheme,

      home: const SplashScreen(),

      routes: {
        '/home': (_) => const CustomerDashboard(),
      },
    );
  }
}