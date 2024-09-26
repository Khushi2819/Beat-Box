import 'dart:io';
import 'package:beatbox/screen/TrendingMusicScreen.dart';
import 'package:beatbox/screen/home_screen.dart';
import 'package:beatbox/screen/library.dart';

import './login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

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
          .set(
            {'profileImageUrl': imageUrl},
            SetOptions(merge: true), // Merge ensures only the profileImageUrl is updated or added
          );
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
          title: Text("Profile", style: const TextStyle(color: Colors.white)),
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                                    'Beat_Box/assets/icon/default_profile_photo.png'),
                      ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  Text(
                    _auth.currentUser?.email ??
                        'No Email', //email from Firebase Auth
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 253, 253, 253),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepPurple.shade800,
          unselectedItemColor: Colors.white70,
          selectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: 3, // Assuming 2 is the index for this screen
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offAll(() => const HomeScreen());
                break;
              case 1:
                Get.offAll(() => const TrendingMusicScreen());
                break;
              case 2:
                Get.offAll(() => const UserPlaylistScreen());
                break;
              case 3:
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
        ),
      ),
    );
  }
}