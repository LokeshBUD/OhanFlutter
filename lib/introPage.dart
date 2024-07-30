import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './homePage.dart'; // Import the HomePage

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _animationInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 200, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _controller.addListener(() {
      setState(() {
        _animationInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _navigateToLoginPage() {
    Navigator.pushNamed(context, '/sign_in');
  }

  void _navigateToSignUpPage() {
    Navigator.pushNamed(context, '/sign_up');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _animationInitialized
            ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value),
                    child: child,
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 100),
                    const Image(
                      image: AssetImage('assets/logo.png'),
                    ),
                    SizedBox(
                      height: 50,
                      width: 250,
                      child: FilledButton(
                        onPressed: _navigateToLoginPage,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.shade800), // Royal blue color
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.robotoCondensed(
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
                      child: FilledButton.tonal(
                        onPressed: _navigateToSignUpPage,
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.robotoCondensed(
                            textStyle: const TextStyle(
                                fontSize: 20, letterSpacing: .5),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToHomePage,
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "Just want to explore? ",
                              style: GoogleFonts.robotoCondensed(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue, // Color for the normal text
                                ),
                              ),
                            ),
                            TextSpan(
                              text: "Click here",
                              style: GoogleFonts.robotoCondensed(
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
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
