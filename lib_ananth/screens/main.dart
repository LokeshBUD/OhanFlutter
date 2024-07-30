import 'package:flutter/material.dart';
import 'screens/profile.dart'; // Make sure this path is correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Profile App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: ProfileScreen(
        userData: {
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'DOB': '01/01/2000',
          'photo': 'https://example.com/photo.jpg', // Replace with a valid URL or local asset
        },
      ),
    );
  }
}
