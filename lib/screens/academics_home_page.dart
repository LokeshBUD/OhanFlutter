import 'package:flutter/material.dart';
import 'articles_page.dart';
import 'videos_page.dart';
import 'global_health_statistics_page.dart';

class AcademicsHomePage extends StatelessWidget {
  const AcademicsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academics'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.25, // Top 25% of the page
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: const DecorationImage(
                    image: AssetImage('assets/OHAN.jpg'), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildCustomButton(
                    context,
                    'Go to Articles',
                    'assets/articles.jpg', // Replace with your image path
                    const ArticlesPage(),
                  ),
                  const SizedBox(height: 20), // Add spacing between buttons
                  _buildCustomButton(
                    context,
                    'Go to Videos',
                    'assets/videos.png', // Replace with your image path
                    const VideosPage(),
                  ),
                  const SizedBox(height: 20), // Add spacing between buttons
                  _buildCustomButton(
                    context,
                    'Go to Global Health Statistics',
                    'assets/statistics.png', // Replace with your image path
                    const GlobalHealthStatisticsPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context, String text, String imagePath, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 200, minHeight: 100),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
