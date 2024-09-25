import 'package:beatbox/models/song_model.dart';
import 'package:get/get.dart';
import 'MusicCollection.dart';

class PlaylistController extends GetxController {
  var userPlaylists = <MusicCollection>[].obs;

  // Method to create a new playlist locally and in Firestore
  void createPlaylist(String name, String userId) async {
    MusicCollection newPlaylist = MusicCollection(
      id: '', // Initially empty, will be set after saving
      title: name,
      songs: [],
      imageUrl: '',
      userId: userId,
    );

    await newPlaylist.saveToFirestore(); // Save to Firestore and get ID
    newPlaylist.id = newPlaylist.id; // Set the ID after saving
    userPlaylists.add(newPlaylist);
  }

  // Method to add a song to a specific playlist
  void addSongToPlaylist(MusicCollection playlist, Song song) {
    playlist.addSong(song); // Update the playlist and Firestore
  }
}
