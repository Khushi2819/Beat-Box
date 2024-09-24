import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        Get.offNamed('/login'); // Redirect to login after successful signup
      } catch (e) {
        print('Signup failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade800.withOpacity(0.8),
              Colors.deepPurple.shade200.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 'BeatBox' Logo on Top
                  Text(
                    'BeatBox',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40, // Increased font size for better visibility
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('Sign Up', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white)),
                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => _email = value,
                    validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
                    style: const TextStyle(color: Colors.black), // Enhanced readability
                  ),
                  const SizedBox(height: 10),

                  // Password Field
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => _password = value,
                    validator: (value) => value!.length >= 6 ? null : 'Password must be at least 6 characters',
                    style: const TextStyle(color: Colors.black), // Enhanced readability
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password Field
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => _confirmPassword = value,
                    validator: (value) => value == _password ? null : 'Passwords do not match',
                    style: const TextStyle(color: Colors.black), // Enhanced readability
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Better button size
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Redirect to Login Button
                  TextButton(
                    onPressed: () {
                      Get.offNamed('/login');
                    },
                    child: const Text('Already have an account? Log in'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
