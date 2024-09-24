import 'package:flutter/cupertino.dart';

import 'song_model.dart';
class Playlist{
  final String title;
  final List<Song> songs;
  final String imageUrl;

  Playlist({
    required this.title,
    required this.songs,
    required this.imageUrl,
  });
  static List<Playlist> playlists = [
    Playlist(
      title: "hip-hop R&B Mix",
      songs: Song.songs,
      imageUrl: "https://images.unsplash.com/photo-1652180124341-823c08881ed0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHJvY2slMjBhbmQlMjByb2xsfGVufDB8fDB8fHww",
    ),
    Playlist(
      title: "Rock & Roll",
      songs: Song.songs,
      imageUrl: "https://images.unsplash.com/photo-1652180124341-823c08881ed0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHJvY2slMjBhbmQlMjByb2xsfGVufDB8fDB8fHww",
    ),
    Playlist(
      title: "Techno",
      songs: Song.songs,
      imageUrl: "https://images.unsplash.com/photo-1652180124341-823c08881ed0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHJvY2slMjBhbmQlMjByb2xsfGVufDB8fDB8fHww",
    )
  ];
}