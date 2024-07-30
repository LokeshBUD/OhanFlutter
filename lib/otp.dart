import 'package:flutter/material.dart';
import 'dart:async';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});
  @override
  final String origin = '';

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _start = 60;

  void startTimer() {
    _start = 60;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void onOtpSubmit() {
    // Add OTP verification logic here

    // Navigate to the next screen upon successful OTP verification
    Navigator.pushNamed(context, '/nextScreen'); // Replace '/nextScreen' with the route you want to navigate to
  }

  void handleResendOtp() {
    // Handle logic to resend OTP
    _otpController.clear(); // Clear OTP input
    startTimer(); // Restart timer
  }

  void _goBack() {
    Navigator.pop(context, widget.origin);
  }

  @override
  void initState() {
    super.initState();
    startTimer(); // Start timer when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/Logo.png',
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              Text(
                'Enter OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onOtpSubmit,
                child: Text('Submit'),
              ),
              SizedBox(height: 10),
              _start > 0
                  ? Text('Resend OTP in $_start seconds', style: TextStyle(color: Colors.grey))
                  : ElevatedButton(
                      onPressed: handleResendOtp,
                      child: Text('Resend OTP'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
