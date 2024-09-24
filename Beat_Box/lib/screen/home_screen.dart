import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../widget/playlist_card.dart';
import '../widget/section_header.dart';
import '../widget/song_card.dart';
import 'TrendingMusicScreen.dart';
import 'library.dart'; // Import the UserPlaylistScreen
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  Future<List<Song>> fetchSongs() async {
    List<Song> songList = [];
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get the songs collection
      QuerySnapshot snapshot = await firestore.collection('songs').get();

      // Map each document to the Song model
      for (var doc in snapshot.docs) {
        Song song = Song(
          title: doc['title'],
          description: doc['description'],
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
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  String searchQuery = '';
  Future<void> loadSongs() async {
    songs = await fetchSongs(); // Wait for the fetch to complete
    setState(() {
      filteredSongs = songs; // Update filteredSongs here
    });
  }

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  void _filterSongs(String query) {
    setState(() {
      searchQuery = query;
      filteredSongs = songs
          .where((song) =>
      song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the songs to display in the Trending Music section
    List<Song> displayedSongs = searchQuery.isEmpty
        ? filteredSongs.take(3).toList()
        : filteredSongs;

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
          onTap: (index) {
            switch (index) {
              case 0:
              // Handle Home navigation
                break;
              case 1:
                Get.to(() => const TrendingMusicScreen()); // Navigate to TrendingMusicScreen
                break;
              case 2:
                Get.to(() => const UserPlaylistScreen()); // Navigate to UserPlaylistScreen
                break;
              case 3:
              // Handle Profile navigation
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Enjoy your favorite music',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onChanged: (value) => _filterSongs(value),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey.shade400),
                        prefixIcon:
                        Icon(Icons.search, color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Trending Music',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.27,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayedSongs.length,
                        itemBuilder: (context, index) {
                          return SongCard(song: displayedSongs[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SectionHeader(title: 'Playlists'),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 20),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 0,
                            itemBuilder: (context, index) {
                              return PlaylistCard(
                                  playlist: Playlist.playlists[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
