import 'package:beatbox/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Navigate to the main screen after 3 seconds
    Timer(Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;

      if(user==null){
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginPage())
        );
      }
      else{
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen())
        );
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon/app_icon.png', height: 120),  
            // SizedBox(height: 20),
            // Text(
            //   'BeatBox', 
            //   style: TextStyle(
            //     fontSize: 32,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //     fontFamily: 'highperformancefont',
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
