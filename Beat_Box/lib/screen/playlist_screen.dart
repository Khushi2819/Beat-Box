import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/MusicCollection.dart';
import '../models/Playlist_Controller.dart';
import '../models/song_model.dart';

class PlaylistScreen extends StatefulWidget {
  final MusicCollection playlist;

  PlaylistScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late PlaylistController playlistController;

  @override
  void initState() {
    super.initState();
    // Initialize the playlist controller
    playlistController = Get.find<PlaylistController>();
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
          iconTheme: const IconThemeData(color: Colors.white), // Makes back arrow white
          title: Text(widget.playlist.title, style: const TextStyle(color: Colors.white)), // Makes header white
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white), // Delete playlist icon
              onPressed: () {
                _deletePlaylist(context);
              },
            ),
          ],
        ),
        body: widget.playlist.songs.isEmpty
            ? const Center(
          child: Text(
            'No songs in this playlist',
            style: TextStyle(color: Colors.white),
          ),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _PlaylistInformation(playlist: widget.playlist),
                const SizedBox(height: 30),
                _PlaylistSongs(
                  playlist: widget.playlist,
                  refreshPlaylist: _refreshPlaylist, // Pass refresh function to the songs widget
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to delete the playlist
  void _deletePlaylist(BuildContext context) {
    Get.defaultDialog(
      title: 'Delete Playlist',
      middleText: 'Are you sure you want to delete this playlist?',
      onConfirm: () async {
        // Call the controller to delete the playlist from Firestore
        try {
          await playlistController.deletePlaylist(widget.playlist); // Pass the entire playlist object
          Get.back(); // Close the dialog
          Get.snackbar('Success', 'Playlist deleted');
          // Navigate back to the previous screen after deletion
          Get.offAllNamed('/library'); // Replace '/library' with your actual route name
        } catch (error) {
          Get.snackbar('Error', 'Failed to delete playlist: $error');
        }
      },
      onCancel: () => Get.back(),
    );
  }

  // Function to refresh the playlist UI
  void _refreshPlaylist() {
    setState(() {});
  }
}

class _PlaylistSongs extends StatelessWidget {
  final MusicCollection playlist;
  final VoidCallback refreshPlaylist; // Add refresh function as a parameter

  const _PlaylistSongs({
    Key? key,
    required this.playlist,
    required this.refreshPlaylist, // Initialize refreshPlaylist
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlist.songs.length,
      itemBuilder: (context, index) {
        final song = playlist.songs[index];
        return ListTile(
          onTap: () {
            // Navigate to SongScreen when the song is clicked
            Get.toNamed('/song', arguments: song);
          },
          leading: Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover),
          title: Text(
            song.title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white), // Set song title text to white
          ),
          subtitle: Text(
            song.description,
            style: const TextStyle(color: Colors.white), // Set song description text to white
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_to_playlist') {
                _showAddToPlaylistDialog(context, song);
              } else if (value == 'delete') {
                _deleteSongFromPlaylist(context, playlist, song);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_to_playlist',
                child: Text('Add to Playlist'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete from Playlist'),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        );
      },
    );
  }

  // Function to show add-to-playlist dialog
  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: Text('Add ${song.title} to another playlist.'),
          actions: [
            TextButton(
              onPressed: () {
                // Implement add to playlist logic here
                Navigator.pop(context);
                Get.snackbar('Success', '${song.title} added to playlist');
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a song from the playlist
  void _deleteSongFromPlaylist(BuildContext context, MusicCollection playlist, Song song) {
    Get.defaultDialog(
      title: 'Delete Song',
      middleText: 'Are you sure you want to delete this song?',
      onConfirm: () {
        playlist.removeSong(song); // Call the remove song method
        Get.back(); // Close the dialog
        Get.snackbar('Success', 'Song deleted from playlist');
        refreshPlaylist(); // Refresh the playlist after deleting the song
      },
      onCancel: () => Get.back(),
    );
  }
}

class _PlaylistInformation extends StatelessWidget {
  final MusicCollection playlist;

  const _PlaylistInformation({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(playlist.imageUrl.isNotEmpty ? playlist.imageUrl : 'default_image_url'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          playlist.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          '${playlist.songs.length} songs',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
