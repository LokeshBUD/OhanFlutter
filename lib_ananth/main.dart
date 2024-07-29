import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/sign_up.dart';
import 'screens/forget.dart';
import 'screens/otp.dart';
import 'screens/sign_in.dart';
import 'screens/mainpage.dart';  // Import the main page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: '/',  // Set initial route to MainPage
      routes: {
        '/': (context) => MainPage(),  // MainPage as initial route
        '/signIn': (context) => SignInScreen(),
        '/signUp': (context) => SignUpScreen(),
        '/forgetPassword': (context) => Forget(),
        '/otp': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return OTPScreen(origin: args ?? '');
        },
        '/mainPage': (context) => MainPage(), // Ensure MainPage route is set
      },
    );
  }
}
