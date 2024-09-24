import 'package:beatbox/models/song_model.dart';

class MusicCollection {
  String title;
  String imageUrl;
  List<Song> songs;

  MusicCollection({
    required this.title,
    required this.imageUrl,
    required this.songs,
  });

  // Add a song to the collection and update the image to the topmost song's image.
  void addSong(Song song) {
    songs.insert(0, song);
    imageUrl = songs.first.coverUrl;
  }

  // Remove a song from the collection
  void removeSong(Song song) {
    songs.remove(song);
    if (songs.isNotEmpty) {
      imageUrl = songs.first.coverUrl;
    } else {
      imageUrl = ''; // Optionally set a default image when empty.
    }
  }
}
