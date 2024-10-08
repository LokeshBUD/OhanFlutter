import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
Future<User?> _signInWithGoogle() async {
  try {
    // Trigger the Google authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    // Save user information to Firestore
    if (user != null) {
      await _saveUserDataToFirestore(user);
    }

    return user;
  } catch (e) {
    print("Google sign-in failed: $e");
    return null;
  }
}

Future<void> _saveUserDataToFirestore(User user) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.email);

  // Check if the user document already exists
  final docSnapshot = await userRef.get();

  if (!docSnapshot.exists) {
    // If the user document doesn't exist, create it
    await userRef.set({
      'email': user.email,
      'name': user.displayName,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'documents': [],
      'calories':[],
    });
  } else {
    // If it does exist, you might want to update the data (optional)
    await userRef.update({
      'name': user.displayName,
      'photoUrl': user.photoURL,
    });
  }
}
 void onSignInPressed() async {
  final String email = _usernameController.text.trim();
  final String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter both email and password')),
    );
    return;
  }

  try {
    // Sign in with email and password
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      print("Sign In successful! User: ${user.displayName}");
      // Navigate to the desired screen after successful login
      Navigator.pushNamed(context, '/home');
    }
  } on FirebaseAuthException catch (e) {
    String message;

    switch (e.code) {
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      default:
        message = 'An error occurred. Please try again.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}


  void onGoogleSignInPressed() async {
    User? user = await _signInWithGoogle();
    if (user != null) {
      print("Google Sign In successful! User: ${user.displayName}");
      // Navigate to the desired screen after successful login
      Navigator.pushNamed(context, '/home');
    } else {
      print("Google Sign In failed!");
    }
  }

  void onForgetPasswordPressed() {
    Navigator.pushNamed(context, '/forgetPassword');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: constraints.maxHeight * 0.3,
                        width: MediaQuery.of(context).size.width * 0.7,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: onSignInPressed,
                        child: Text('Sign In'),
                      ),
                      SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('or'),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: onGoogleSignInPressed,
                        icon: Icon(Icons.login),
                        label: Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                           // Google button color
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: onForgetPasswordPressed,
                        child: Text('Forget Password'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
