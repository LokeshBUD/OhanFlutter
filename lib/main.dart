import 'package:flutter/material.dart';
import './introPage.dart';
import './homePage.dart';
import './forget.dart';
import './otp.dart';
import './sign_in.dart';
import './sign_up.dart';
import './profile.dart';
import './edit_profile.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ohan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroPage(),
        '/home': (context) => const HomePage(),
        '/forget': (context) => const Forget(), // Corrected colon here
        '/sign_in': (context) => const SignInScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/sign_up': (context) => const SignUpScreen(),
      },
    );
  }
}
