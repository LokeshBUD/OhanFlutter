// lib/main.dart
import 'package:flutter/material.dart';
import 'package:calorietracker/screens/calorie_tracker_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalorieTrackerPage(),
    );
  }
}
