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

  ];
}