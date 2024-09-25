import 'package:beatbox/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/song_model.dart';
import 'home_screen.dart'; // Import HomeScreen
import 'package:cloud_firestore/cloud_firestore.dart';

import 'library.dart';

class TrendingMusicScreen extends StatefulWidget {
  const TrendingMusicScreen({Key? key}) : super(key: key);

  @override
  _TrendingMusicScreenState createState() => _TrendingMusicScreenState();
}

class _TrendingMusicScreenState extends State<TrendingMusicScreen> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];

  Future<List<Song>> fetchSongs() async {
    List<Song> songList = [];
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    print(1);
    try {
      // Get the songs collection
      QuerySnapshot snapshot = await firestore.collection('songs').get();
      // Map each document to the Song model
      for (var doc in snapshot.docs) {
        print(doc);
        Song song = Song(
          title: doc['title'],
          description: doc['description'] ?? "hii",
          url: doc['url'],
          coverUrl: doc['coverUrl'],
        );
        songList.add(song);
      }
    } catch (e) {
      print('Error fetching songs: $e');
    }
    print(songList);
    return songList;
  }

  Future<void> loadSongs() async {
    songs = await fetchSongs(); // Wait for the fetch to complete
    setState(() {
      filteredSongs = songs; // Update filteredSongs here
    });
  }

  @override
  void initState() {
    super.initState();
    loadSongs(); // Call to load songs
  }

  void _filterSongs(String query) {
    setState(() {
      filteredSongs = songs.where((song) =>
      song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
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
          backgroundColor: Colors.deepPurple.shade600,
          unselectedItemColor: Colors.white70,
          selectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: 1, // Highlight the "Search" button
          onTap: (index) {
            switch (index) {
              case 0:
                Get.to(() => const HomeScreen());
                break;
              case 1:
                Get.to(() => const TrendingMusicScreen()); // Navigate to TrendingMusicScreen
                break;
              case 2:
                Get.to(() => const UserPlaylistScreen()); // Navigate to UserPlaylistScreen
                break;
              case 3:
                Get.to(() => ProfileScreen());
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
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
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
                              filteredSongs[index].coverUrl, // Use Image.network for URLs
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
      elevation: 0,
      leading: const Icon(Icons.grid_view_rounded, color: Colors.white),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/download.png'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
