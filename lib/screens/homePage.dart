import 'package:flutter/material.dart';
import 'academics.dart';
import 'profile.dart';
import 'homescreen.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final userData = {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'DOB': '01/01/2000',
      'photo': 'https://example.com/photo.jpg',
    };
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          HomeScreen(),
          AcademicsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Academics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
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
