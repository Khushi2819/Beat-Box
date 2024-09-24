import 'package:beatbox/models/song_model.dart';
import 'package:get/get.dart';

import 'MusicCollection.dart';

class PlaylistController extends GetxController {
  var userPlaylists = <MusicCollection>[].obs;

  void createPlaylist(String name) {
    userPlaylists.add(MusicCollection(title: name, songs: [], imageUrl: ''));
  }

  void addSongToPlaylist(MusicCollection playlist, Song song) {
    playlist.songs.add(song);
    playlist.imageUrl = playlist.songs.isNotEmpty ? playlist.songs.first.coverUrl : '';
  }
}
