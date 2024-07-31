import 'package:flutter/material.dart';
import 'pages/academics_home_page.dart';

void main() {
  runApp(const AcademicsApp());
}

class AcademicsApp extends StatelessWidget {
  const AcademicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AcademicsHomePage(),
    );
  }
}
