import 'package:flutter/material.dart';
import './introPage.dart';
import './homePage.dart';

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
      },
    );
  }
}
