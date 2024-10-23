import 'package:beatbox/models/MusicCollection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/Playlist_Controller.dart';
import '../models/playlist_model.dart';
import '../screen/playlist_screen.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    Get.put(PlaylistController());
    MusicCollection convertPlaylistToMusicCollection(Playlist playlist) {
      return MusicCollection(
        id:"12",
        title: playlist.title,
        songs: playlist.songs,
        imageUrl: playlist.imageUrl,
        userId:"23"
      );
    }

    return InkWell(
      onTap: () {
        Get.to(() => PlaylistScreen(playlist:convertPlaylistToMusicCollection(playlist) ));
      },
      child: Container(
        height: 75,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade800.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: playlist.imageUrl.isNotEmpty?Image.network(
                playlist.imageUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ):Image.network(
                "https://firebasestorage.googleapis.com/v0/b/beat-e7c20.appspot.com/o/image%2Fplaylist.png?alt=media&token=ad97ea21-7cf9-4f1a-87aa-a9ff81da7dc7",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playlist.title,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${playlist.songs.length} song${playlist.songs.length != 1 ? 's' : ''}', // Pluralization
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: playlist.songs.isNotEmpty // Check if there are songs in the playlist
                  ? () {
                // Navigate to the play screen with the playlist
                Get.toNamed('/play', arguments: playlist);
              }
                  : null, // Disable button if no songs
              icon: const Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
              // Optional: Change the button's appearance when disabled
              tooltip: playlist.songs.isEmpty ? 'No songs to play' : null,
            ),
          ],
        ),
      ),
    );
  }
}
