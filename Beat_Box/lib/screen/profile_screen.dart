<<<<<<< HEAD
import 'dart:io';
import './login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // _loadProfileImage();
  }

  // Function to prompt user to select an image source
  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                // for single line with the leading optional icon.
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  uploadProfileImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  uploadProfileImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle image selection, compression, and upload
  Future<void> uploadProfileImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);
      File? compressedFile =
          await compressImage(originalFile, 40); // Compress to 40% quality

      if (compressedFile != null) {
        String fileName = 'profile_${_auth.currentUser!.uid}.jpg';
        Reference ref = _storage.ref().child('profile_images/$fileName');

        UploadTask uploadTask = ref.putFile(compressedFile);
        await uploadTask.whenComplete(() => print("Image Uploaded"));

        // Get the download URL to store in Firestore
        String imageUrl = await ref.getDownloadURL();
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'profileImageUrl': imageUrl});
      }
    }
  }

  Future<File?> compressImage(File file, int quality) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/temp.jpg';

    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: quality, // Compress to 40%
    );

    return result != null ? File(result.path) : null;
  }

  // Logout function.
  Future<void> _logout() async {
    await _auth.signOut(); // Ensure signOut completes
    Navigator.of(context)
        .popUntil((route) => route.isFirst); // Clear the navigation stack
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
=======
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
>>>>>>> 2eb8b6a0132e4f4acc8af5deba3098bba8966193
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String? profileImageUrl = userData['profileImageUrl'];

                  return GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: (profileImageUrl != null && profileImageUrl !="")
                          ? NetworkImage(profileImageUrl)
                          : AssetImage(
                                  'BeatBox/assets/icons/default_profile_photo.png')
                              as ImageProvider,
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: CircularProgressIndicator()
                  );
                }
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Email: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  _auth.currentUser?.email ??
                      'No Email', // Display email from Firebase Auth
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
=======
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
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white), // Set title color to white
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white), // Set back arrow color to white
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
>>>>>>> 2eb8b6a0132e4f4acc8af5deba3098bba8966193
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 2eb8b6a0132e4f4acc8af5deba3098bba8966193
