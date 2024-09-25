import 'package:beatbox/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'TrendingMusicScreen.dart';
import 'library.dart'; // Import your UserPlaylistScreen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginPage()); // Navigate to HomeScreen after logout
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Profile'),
          centerTitle: true,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepPurple.shade800,
          unselectedItemColor: Colors.white70,
          selectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.off(() => const HomeScreen());
                break;
              case 1:
                Get.to(() => const TrendingMusicScreen());
                break;
              case 2:
                Get.to(() => const UserPlaylistScreen());
                break;
              case 3:
              // Already on Profile screen, do nothing
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined),
              label: 'Playlists',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: 3, // Highlight the Profile tab
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600, // Button color
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
