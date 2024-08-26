import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Add this import for TapGestureRecognizer
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../components/date_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();
  DateTime? _selectedDate;

  void onRegisterPressed() async {
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String passwordRepeat = _passwordRepeatController.text.trim();

    if (password != passwordRepeat) {
      // Show error: Passwords do not match
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Create a new user with email and password in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'dob': _selectedDate != null ? _selectedDate!.toIso8601String() : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to OTP screen (or other screen)
      Navigator.pushNamed(context, '/sign_in');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Use Navigator.pop to go back
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: height * 0.3),
              SizedBox(height: 20),
              Text(
                'Create an account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              CustomInput(controller: _usernameController, placeholder: 'Name'),
              SizedBox(height: height * 0.01), // Spacer to move DOB 5% down
              DateInput(
                selectedDate: _selectedDate,
                onTap: _selectDate,
              ),
              CustomInput(controller: _emailController, placeholder: 'Email'),
              CustomInput(controller: _passwordController, placeholder: 'Password', obscureText: true),
              CustomInput(controller: _passwordRepeatController, placeholder: 'Repeat Password', obscureText: true),
              CustomButton(text: 'Submit', onPressed: onRegisterPressed),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'By registering, you confirm that you accept our ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(color: const Color.fromARGB(255, 246, 222, 5), decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        // Handle Terms of Use tap
                      },
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: const Color.fromARGB(255, 246, 222, 5), decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        // Handle Privacy Policy tap
                      },
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}