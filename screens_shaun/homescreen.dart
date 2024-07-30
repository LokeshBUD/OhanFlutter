import 'package:flutter/material.dart';
import 'consultation.dart';
import 'academics.dart';
import 'partners.dart';
import 'profile.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OHAN'),
      ),
      body: Stack( // Use Stack widget to position elements on top of each other
        children: [
          // Logo positioned in the center using Center widget
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Image.asset(
              'lib/assets/images/logo-bg-removed.png',
              width: 400.0, // Adjust width as needed
            ),
          // Rest of the content positioned below the logo
                  CustomButton(
                    text: '   Consultation',
                    icon: Icons.medical_services,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ConsultationScreen()),
                      );
                    },
                  ),
                  CustomButton(
                    text: 'Profile',
                    icon: Icons.person,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  CustomButton(
                    text: '      Academics',
                    icon: Icons.school,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AcademicsScreen()),
                      );
                    },
                  ),
                  CustomButton(
                    text: '        Partners',
                    icon: Icons.group,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PartnersScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          
        ],
      ),
    );
  }
}


class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
   Widget build(BuildContext context) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
       child: ElevatedButton.icon(
         onPressed: onPressed,
         icon: Icon(icon, size: 30.0),
         label: Text(text),
         style: ElevatedButton.styleFrom(
           fixedSize: Size.fromWidth(250.0),
           backgroundColor: Colors.blue,
           foregroundColor: Colors.white, // Set text color
           padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
           textStyle: TextStyle(fontSize: 18.0),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12.0),
             side: BorderSide(color: Colors.white, width: 2.0),
           ),
          elevation: 5,
         ),
       ),
     );
   }
 }