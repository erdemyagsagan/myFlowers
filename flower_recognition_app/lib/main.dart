import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myFlowers',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MainScreen(),
      routes: {
        '/home': (context) => const MainScreen(),
        '/login': (context) => const ProfileScreen(),
        '/user_info': (context) => const UserInfoScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
