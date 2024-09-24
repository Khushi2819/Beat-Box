import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/MusicCollection.dart';
import '../models/Playlist_Controller.dart';
import '../models/song_model.dart';
import 'TrendingMusicScreen.dart';
import 'home_screen.dart';

class UserPlaylistScreen extends StatefulWidget {
  const UserPlaylistScreen({Key? key}) : super(key: key);

  @override
  _UserPlaylistScreenState createState() => _UserPlaylistScreenState();
}

class _UserPlaylistScreenState extends State<UserPlaylistScreen> {
  final PlaylistController playlistController = Get.put(PlaylistController());


  List<MusicCollection> userPlaylists = []; // Updated to use MusicCollection
  final TextEditingController _playlistNameController = TextEditingController();

  // Variable to track selected index in BottomNavigationBar
  int _selectedIndex = 2; // Set default to "Play" (Library) index (2)

  // Method to create a new playlist and add to the list
  void _createPlaylist(String name) {
    setState(() {
      userPlaylists.add(
        MusicCollection(title: name, songs: [], imageUrl: ''), // Updated model
      );
    });
    _playlistNameController.clear();
    Get.back();
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

  // Method to add a song to a playlist and update the playlist cover image
  void _addSongToPlaylist(MusicCollection playlist, Song song) {
    setState(() {
      playlist.songs.add(song);
      // Update the image to the first song's coverUrl if songs exist
      playlist.imageUrl = playlist.songs.isNotEmpty ? playlist.songs.first.coverUrl : '';
    });
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
              child: CardPlay(playlist: playlist), // Display each playlist using the PlaylistCard widget
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
      child: ListTile(
        leading: playlist.imageUrl.isNotEmpty
            ? Image.asset(playlist.imageUrl, fit: BoxFit.cover, width: 50, height: 50)
            : const Icon(Icons.music_note, size: 50), // Placeholder icon if no image
        title: Text(
          playlist.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${playlist.songs.length} songs'), // Display number of songs
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // You can add a function to navigate to the playlist's detail page here
        },
      ),
    );
  }
}
