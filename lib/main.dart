import 'package:flutter/material.dart';
import 'screens/introPage.dart';
import 'screens/homePage.dart';
import 'screens/forget.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';
import 'screens/profile.dart';
import 'screens/edit_profile.dart';
import 'screens/academics_home_page.dart';
import 'screens/academics.dart';
import 'screens/articles_form_page.dart';
import 'screens/articles_page.dart';
import 'screens/calorie_tracker_page.dart';
import 'screens/confirmation.dart';
import 'screens/consultation.dart';
import 'screens/global_health_statistics_page.dart';
import 'screens/homescreen.dart';
import 'screens/partners.dart';
import 'screens/video_form_page.dart';
import 'screens/videos_page.dart';
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
        '/forget': (context) => const Forget(),
        '/sign_in': (context) => const SignInScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/academics': (context) => const AcademicsScreen(),
        '/academics_home_page': (context) =>
            const AcademicsHomePage(), // Added route
        '/articles_page': (context) => const ArticlesPage(),
        '/articles_form_page': (context) => const ArticleFormPage(),
        '/calorie_tracker_page': (context) => const CalorieTrackerPage(),
        '/confirmation': (context) => ConfirmationPage(
          name: 'John Doe', 
          email: 'john.doe@example.com', 
          date: '2024-08-08', 
          time: '10:00 AM', 
          appointmentType: 'Consultation'
        ),
        '/consultation': (context) => ConsultationScreen(),
        '/global_health_statistics_page': (context) => const GlobalHealthStatisticsPage(),
        '/homescreen': (context) => HomeScreen(),
        '/partners': (context) =>  PartnersScreen(),
        '/video_form_page': (context) => const VideoFormPage(),
        '/videos_page': (context) => const VideosPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProfileScreen(userData: args['userData']),
            );
          case '/edit_profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                userData: args['userData'],
                onUpdate: args['onUpdate'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}

void navigateToProfile(BuildContext context) {
  Navigator.pushNamed(
    context,
    '/profile',
    arguments: {
      'userData': {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'DOB': '01/01/2000',
        'photo': 'https://example.com/photo.jpg',
      },
    },
  );
}

void navigateToEditProfile(
    BuildContext context, Map<String, dynamic> userData) {
  Navigator.pushNamed(
    context,
    '/edit_profile',
    arguments: {
      'userData': userData,
      'onUpdate': (updatedData) {
        // Handle the updated data here
        print('Updated data: $updatedData');
      },
    },
  );
}
