import 'package:beatbox/screen/playlist_screen.dart';
import 'package:beatbox/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/MusicCollection.dart';
import '../models/Playlist_Controller.dart';
import 'TrendingMusicScreen.dart';
import 'home_screen.dart';

class UserPlaylistScreen extends StatefulWidget {
  const UserPlaylistScreen({Key? key}) : super(key: key);

  @override
  _UserPlaylistScreenState createState() => _UserPlaylistScreenState();
}

class _UserPlaylistScreenState extends State<UserPlaylistScreen> {
  final PlaylistController playlistController = Get.put(PlaylistController());
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserPlaylists();
  }

  void _fetchUserPlaylists() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      var snapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: userId)
          .get();

      playlistController.userPlaylists.value = snapshot.docs
          .map((doc) => MusicCollection.fromDocument(doc))
          .toList();
    }
  }

  void _createPlaylist(String name) async {
    // Check for duplicate names
    if (playlistController.userPlaylists.any((playlist) => playlist.title == name)) {
      Get.snackbar('Error', 'A playlist with this name already exists.');
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      MusicCollection newPlaylist = MusicCollection(
        id: '', // Will be set after saving
        title: name,
        songs: [],
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/beat-e7c20.appspot.com/o/image%2Fplaylist.png?alt=media&token=ad97ea21-7cf9-4f1a-87aa-a9ff81da7dc7',
        userId: userId,
      );

      await newPlaylist.saveToFirestore();
      newPlaylist.id = newPlaylist.id; // Ensure the ID is set
      playlistController.userPlaylists.add(newPlaylist);

      _playlistNameController.clear();
      Get.back();
    } else {
      print("Error: User not logged in");
    }
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: _playlistNameController,
            decoration: const InputDecoration(hintText: 'Playlist Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playlistNameController.clear();
                Get.back(); // Cancel action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_playlistNameController.text.isNotEmpty) {
                  _createPlaylist(_playlistNameController.text);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
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
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
          title: const Text('Your Playlists', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _showCreatePlaylistDialog,
            ),
          ],
        ),
        body: Obx(() {
          if (playlistController.userPlaylists.isEmpty) {
            return const Center(
              child: Text(
                'No playlists yet. Create one!',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: playlistController.userPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = playlistController.userPlaylists[index];
              return GestureDetector(
                onTap: () async {
                  // Wait for PlaylistScreen to return and then refresh playlists
                  await Get.to(() => PlaylistScreen(playlist: playlist));
                  setState(() {}); // Refresh the UI to reflect changes
                },
                child: CardPlay(playlist: playlist),
              );
            },
          );
        }),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepPurple.shade800,
          unselectedItemColor: Colors.white70,
          selectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: 2, // Assuming 2 is the index for this screen
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offAll(() => const HomeScreen());
                break;
              case 1:
                Get.offAll(() => const TrendingMusicScreen());
                break;
              case 2:
              // Stay on current page
                break;
              case 3:
                Get.offAll(() => ProfileScreen());
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

class CardPlay extends StatelessWidget {
  final MusicCollection playlist;

  const CardPlay({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.deepPurple.shade800, // Set background color to deep purple
      child: ListTile(
        leading: (playlist.songs.isNotEmpty && playlist.songs.first.coverUrl.isNotEmpty)
            ? Image.network(
          playlist.songs.first.coverUrl,
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        )
            : const Icon(Icons.music_note, size: 50, color: Colors.white), // Change icon color to white
        title: Text(
          playlist.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change title text color to white
          ),
        ),
        subtitle: Text(
          '${playlist.songs.length} songs',
          style: const TextStyle(color: Colors.white), // Change subtitle text color to white
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white), // Change trailing icon color to white
        onTap: () {
          // Navigate to PlaylistScreen and pass the playlist
          Get.to(() => PlaylistScreen(playlist: playlist));
        },
      ),
    );
  }
}
