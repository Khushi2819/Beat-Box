import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/MusicCollection.dart';
import '../models/Playlist_Controller.dart';
import '../models/song_model.dart';
import '../widget/player_buttons.dart';
import '../widget/seekbar.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SongScreen extends StatefulWidget {
  const SongScreen({Key? key}) : super(key: key);


  @override
  State<SongScreen> createState() => _SongScreenState();
}


class _SongScreenState extends State<SongScreen> {
  late AudioPlayer audioPlayer;
  late Song song;
  final PlaylistController playlistController = Get.put(PlaylistController());


  @override
  void initState() {
    super.initState();
    song = Get.arguments ?? null;
    audioPlayer = AudioPlayer();
    _playSong();
  }


  Future<void> _playSong() async {
    try {
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(song.url),
        ),
      );
      audioPlayer.play();
    } catch (e) {
      print('Error playing song: $e');
    }
  }


  Future<void> _showAddToPlaylistDialog() async {
    // Fetch user's playlists
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    var snapshot = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: userId)
        .get();

    List<MusicCollection> playlists = snapshot.docs
        .map((doc) => MusicCollection.fromDocument(doc))
        .toList();

    // Show the dialog with playlists
    showDialog(
      context: context,
      builder: (context) {
        return Center( // This centers the dialog
          child: SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: Colors.deepPurple.shade800, // Set background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Customize shape
              ),
              contentPadding: EdgeInsets.zero, // Remove default padding
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8, // Set width based on screen size
                height: 400, // Set a fixed height for the dialog box
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Select a Playlist',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: SizedBox(
                              width: 50, // Set the image size
                              height: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  playlists[index].imageUrl ?? '', // Add image URL for the playlist
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Use a default playlist image if the URL fails or is null
                                    return Image.asset(
                                      'assets/images/default_playlist.png', // Replace with your default image path
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              playlists[index].title,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _addSongToPlaylist(playlists[index]);
                              Navigator.pop(context); // Close the dialog
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> _addSongToPlaylist(MusicCollection playlist) async {
    // Check if the song already exists in the playlist by comparing the URLs
    bool songExists = playlist.songs.any((existingSong) => existingSong.url == song.url);

    if (songExists) {
      // Show an error message if the song already exists
      Get.snackbar('Song not Added !', 'This song is already in the playlist');
      return;
    }

    // Add the song to the selected playlist
    playlist.songs.add(song);

    // Update playlist image if it's the first song
    if (playlist.songs.length == 1) {
      await FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlist.id)
          .update({'imageUrl': song.coverUrl});
    }

    // Update Firestore with the new playlist data
    await FirebaseFirestore.instance
        .collection('playlists')
        .doc(playlist.id)
        .update({'songs': playlist.songs.map((s) => s.toMap()).toList()});
  }




  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }


  Stream<SeekBarData> get _seekBarDataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
        audioPlayer.positionStream,
        audioPlayer.durationStream,
            (Duration position, Duration? duration) {
          return SeekBarData(position, duration ?? Duration.zero);
        },
      );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade800],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity * 0.8,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(song.coverUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _MusicPlayer(
                song: song,
                seekBarDataStream: _seekBarDataStream,
                audioPlayer: audioPlayer,
                onAddToPlaylist: _showAddToPlaylistDialog, // Pass the function to the music player
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _MusicPlayer extends StatelessWidget {
  const _MusicPlayer({
    Key? key,
    required this.song,
    required Stream<SeekBarData> seekBarDataStream,
    required this.audioPlayer,
    required this.onAddToPlaylist, // Added parameter
  })  : _seekBarDataStream = seekBarDataStream,
        super(key: key);


  final Song song;
  final Stream<SeekBarData> _seekBarDataStream;
  final AudioPlayer audioPlayer;
  final Function onAddToPlaylist; // Added parameter


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            song.description,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          StreamBuilder<SeekBarData>(
            stream: _seekBarDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                position: positionData?.position ?? Duration.zero,
                duration: positionData?.duration ?? Duration.zero,
                onChangedEnd: audioPlayer.seek,
              );
            },
          ),
          PlayerButtons(audioPlayer: audioPlayer),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [


              IconButton(
                icon: Icon(Icons.add_to_photos, color: Colors.white),
                iconSize: 35,
                onPressed: () {
                  onAddToPlaylist(); // Trigger the add to playlist dialog
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
