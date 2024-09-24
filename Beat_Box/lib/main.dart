import 'package:beatbox/screen/TrendingMusicScreen.dart';
import 'package:beatbox/screen/home_screen.dart';
import 'package:beatbox/screen/library.dart';
import 'package:beatbox/screen/login_screen.dart';
import 'package:beatbox/screen/playlist_screen.dart';
import 'package:beatbox/screen/signup_screen.dart';
import 'package:beatbox/screen/song_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Show login page first
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/trending', page: () => const TrendingMusicScreen()),
        GetPage(name: '/song', page: () => const SongScreen()),
        GetPage(name: '/playlist', page: () => const PlaylistScreen()),
        GetPage(name: '/library', page: () =>  UserPlaylistScreen()),
      ],
    );
  }
}
