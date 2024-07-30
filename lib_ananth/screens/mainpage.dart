import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 100),
                const Image(
                  image: AssetImage('lib/assets/images/Logo.png'),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signIn');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 0, 168, 107)), // Change to the specified color
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 20, letterSpacing: .5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signUp');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 255, 204, 0)), // Change to the specified color
                    ),
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 20, letterSpacing: .5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Just want to explore? ",
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue, // Color for the normal text
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "Click here",
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue, // Color for the clickable text
                              decoration: TextDecoration.underline, // Underline for link effect
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
