import 'package:flutter/material.dart';

class Forget extends StatefulWidget {
  @override
  _ForgetScreenState createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<Forget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();

  void onConfirmPressed() {
  Navigator.pushNamed(context, '/otp', arguments: 'forgetPassword');
}


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/Logo.png',
                height: height * 0.3,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              SizedBox(height: 20),
              Text(
                'Reset Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordRepeatController,
                decoration: InputDecoration(
                  hintText: 'Repeat Password',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onConfirmPressed,
                child: Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
