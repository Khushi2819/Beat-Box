import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/MusicCollection.dart';
import '../models/Playlist_Controller.dart';
import '../models/song_model.dart';
import '../widget/player_buttons.dart';
import '../widget/seekbar.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rxdart;


class SongScreen extends StatefulWidget {
  const SongScreen({Key? key}) : super(key: key);


  @override
  State<SongScreen> createState() => _SongScreenState();
}


class _SongScreenState extends State<SongScreen> {
  late AudioPlayer audioPlayer;
  late Song song;


  @override
  void initState() {
    super.initState();
    song = Get.arguments ?? Song.songs[0];
    audioPlayer = AudioPlayer();
    _playSong();
  }


  Future<void> _playSong() async {
    await audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse('asset:///${song.url}'),
      ),
    );
    audioPlayer.play();
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
            SizedBox(height: 80), // Space above the image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Horizontal padding
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous screen
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 60), // Space between the back arrow and the image
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Adds horizontal padding
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity * 0.8, // Adjust the width here
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(song.coverUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12), // Adds rounded corners to the image
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
  })  : _seekBarDataStream = seekBarDataStream,
        super(key: key);


  final Song song;
  final Stream<SeekBarData> _seekBarDataStream;
  final AudioPlayer audioPlayer;


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
                icon: Icon(Icons.settings, color: Colors.white),
                iconSize: 35,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.add_to_photos, color: Colors.white),
                iconSize: 35,
                onPressed: () {},
              ),


            ],
          ),
        ],
      ),
    );
  }
}
