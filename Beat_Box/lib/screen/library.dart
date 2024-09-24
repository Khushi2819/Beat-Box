import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import '../models/Playlist_Controller.dart';
import '../models/song_model.dart'; // Import the Song model
import 'TrendingMusicScreen.dart';
import 'home_screen.dart';

class UserPlaylistScreen extends StatefulWidget {
  const UserPlaylistScreen({Key? key}) : super(key: key);

  @override
  _UserPlaylistScreenState createState() => _UserPlaylistScreenState();
}

class _UserPlaylistScreenState extends State<UserPlaylistScreen> {
  final PlaylistController playlistController = Get.put(PlaylistController());
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Firestore instance

  List<Map<String, dynamic>> userPlaylists = []; // Directly using a list of maps for playlists
  final TextEditingController _playlistNameController = TextEditingController();

  // Variable to track selected index in BottomNavigationBar
  int _selectedIndex = 2; // Set default to "Play" (Library) index (2)

  @override
  void initState() {
    super.initState();
    _fetchPlaylists(); // Fetch playlists when the screen is initialized
  }

  // Method to fetch playlists from Firestore
  Future<void> _fetchPlaylists() async {
    try {
      QuerySnapshot snapshot = await _db.collection('playlists').get();
      setState(() {
        userPlaylists = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'title': data['title'],
            'songs': (data['songs'] as List<dynamic>).map((song) {
              // Ensure each song is properly converted to a Song object
              return Song.fromMap(song as Map<String, dynamic>);
            }).toList(),
            'imageUrl': data['imageUrl'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching playlists: $e");
    }
  }

  // Method to create a new playlist and add to Firestore
  Future<void> _createPlaylist(String name) async {
    try {
      DocumentReference newPlaylistRef = await _db.collection('playlists').add({
        'title': name,
        'songs': [], // Initially empty
        'imageUrl': '', // Initially empty
      });

      // Update local list with the new playlist
      setState(() {
        userPlaylists.add({
          'title': name,
          'songs': [], // Initially empty
          'imageUrl': '', // Initially empty
        });
      });
      _playlistNameController.clear();
      Get.back();
    } catch (e) {
      print("Error creating playlist: $e");
    }
  }

  // Dialog to create a new playlist
  void _showCreatePlaylistDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.deepPurple.shade800.withOpacity(0.9), // Deep purple and a bit transparent
        title: const Text('Create Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _playlistNameController,
          decoration: const InputDecoration(
            hintText: 'Enter playlist name',
            hintStyle: TextStyle(color: Colors.white70), // Make hint text white
          ),
          style: const TextStyle(color: Colors.white), // Make input text white
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)), // White text
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // White button
              foregroundColor: Colors.deepPurple, // Deep purple text
            ),
            onPressed: () {
              if (_playlistNameController.text.isNotEmpty) {
                _createPlaylist(_playlistNameController.text);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Function to handle BottomNavigationBar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    switch (index) {
      case 0:
        Get.offAll(() => const HomeScreen()); // Navigate to HomeScreen
        break;
      case 1:
        Get.offAll(() => const TrendingMusicScreen()); // Navigate to TrendingMusicScreen
        break;
      case 2:
      // Already on Play (Library) screen, no need to navigate
        break;
      case 3:
      // Handle Profile navigation here if necessary
        break;
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // White back arrow
            onPressed: () {
              Get.back(); // Go back to the previous screen
            },
          ),
          title: const Text('Your Playlists', style: TextStyle(color: Colors.white)), // White title
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white), // White icon for "+" button
              onPressed: _showCreatePlaylistDialog,
            ),
          ],
        ),
        body: userPlaylists.isEmpty
            ? const Center(
          child: Text(
            'No playlists yet. Create one!',
            style: TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: userPlaylists.length,
          itemBuilder: (context, index) {
            final playlist = userPlaylists[index];
            return GestureDetector(
              onTap: () {
                // Add logic to navigate to playlist details or add songs
              },
              child: CardPlay(playlist: playlist), // Display each playlist using the CardPlay widget
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepPurple.shade800,
          unselectedItemColor: Colors.white70,
          selectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex, // Set the current selected index
          onTap: _onItemTapped, // Handle taps on BottomNavigationBar
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
              label: 'Play',
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
  final Map<String, dynamic> playlist; // Changed to a map

  const CardPlay({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: playlist['imageUrl'].isNotEmpty
            ? Image.asset(playlist['imageUrl'], fit: BoxFit.cover, width: 50, height: 50)
            : const Icon(Icons.music_note, size: 50), // Placeholder icon if no image
        title: Text(
          playlist['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${(playlist['songs'] as List<Song>).length} songs'), // Display number of songs
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // You can add a function to navigate to the playlist's detail page here
        },
      ),
    );
  }
}
