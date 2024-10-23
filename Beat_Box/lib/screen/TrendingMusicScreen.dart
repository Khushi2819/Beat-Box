import 'package:beatbox/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/song_model.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import 'library.dart';

class TrendingMusicScreen extends StatefulWidget {
  const TrendingMusicScreen({Key? key}) : super(key: key);

  @override
  _TrendingMusicScreenState createState() => _TrendingMusicScreenState();
}

class _TrendingMusicScreenState extends State<TrendingMusicScreen> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceSearchText = '';
  final TextEditingController _searchController = TextEditingController(); // Create a TextEditingController

  Future<List<Song>> fetchSongs() async {
    List<Song> songList = [];
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot = await firestore.collection('songs').get();
      for (var doc in snapshot.docs) {
        Song song = Song(
          title: doc['title'],
          description: doc['description'] ?? "No description",
          url: doc['url'],
          coverUrl: doc['coverUrl'],
        );
        songList.add(song);
      }
    } catch (e) {
      print('Error fetching songs: $e');
    }
    return songList;
  }

  Future<void> loadSongs() async {
    songs = await fetchSongs();
    setState(() {
      filteredSongs = songs;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  void _filterSongs(String query) {
    setState(() {
      filteredSongs = songs.where((song) =>
      song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      bool available = await _speech.initialize(
        onStatus: (status) => setState(() {
          _isListening = status == 'listening';
        }),
        onError: (error) => setState(() {
          _isListening = false;
          print('Speech recognition error: $error');
        }),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _voiceSearchText = result.recognizedWords;
            _searchController.text = _voiceSearchText; // Update the TextEditingController text
            _filterSongs(_voiceSearchText);
          });
        });
      } else {
        setState(() => _isListening = false);
        print('Speech recognition is not available.');
      }
    } else {
      print('Microphone permission not granted.');
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of the controller when done
    super.dispose();
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
        appBar: const _CustomAppBar(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepPurple.shade800,
          unselectedItemColor: Colors.white70,
          selectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offAll(() => const HomeScreen());
                break;
              case 1:
                break;
              case 2:
                Get.offAll(() => const UserPlaylistScreen());
                break;
              case 3:
                Get.offAll(() => ProfileScreen());
                break;
            }
          },
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Music',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _searchController, // Set the controller
                  onChanged: (value) => _filterSongs(value),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search for songs',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.grey.shade400),
                    prefixIcon: IconButton(
                      icon: Icon(Icons.mic, color: _isListening ? Colors.red : Colors.grey.shade400),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade800.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              filteredSongs[index].coverUrl,
                              height: 75,
                              width: 75,
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
                                  filteredSongs[index].title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  filteredSongs[index].description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Get.toNamed('/song', arguments: filteredSongs[index]);
                            },
                            icon: const Icon(
                              Icons.play_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text("BeatBox", style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
