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
  }

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}