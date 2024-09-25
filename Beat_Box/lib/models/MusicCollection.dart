import 'package:beatbox/models/song_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusicCollection {
  String id; // Add this line to store the Firestore document ID
  String title;
  String imageUrl;
  List<Song> songs;
  String userId; // To associate the playlist with a specific user

  MusicCollection({
    required this.id, // Include id in the constructor
    required this.title,
    required this.imageUrl,
    required this.songs,
    required this.userId,
  });

  // Add a song to the collection and update the image to the topmost song's image.
  void addSong(Song song) {
    songs.insert(0, song);
    imageUrl = songs.first.coverUrl;
    updateFirestore(); // Update Firestore entry if necessary.
  }

  // Remove a song from the collection
  void removeSong(Song song) {
    songs.remove(song);
    if (songs.isNotEmpty) {
      imageUrl = songs.first.coverUrl;
    } else {
      imageUrl = ''; // Optionally set a default image when empty.
    }
    updateFirestore(); // Update Firestore entry if necessary.
  }

  // Convert the MusicCollection object to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'songs': songs.map((song) => song.toMap()).toList(),
      'userId': userId,
    };
  }

  // Static method to create a MusicCollection object from Firestore document
  static MusicCollection fromDocument(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<Song> songs = (data['songs'] as List).map((songData) => Song.fromMap(songData)).toList();
    return MusicCollection(
      id: doc.id, // Get the document ID here
      title: data['title'],
      imageUrl: data['imageUrl'],
      songs: songs,
      userId: data['userId'],
    );
  }

  // Save the playlist to Firestore
  Future<void> saveToFirestore() async {
    DocumentReference ref = await FirebaseFirestore.instance.collection('playlists').add(toMap());
    id = ref.id; // Save the document ID after creation
  }

  // Update the Firestore entry (if necessary)
  Future<void> updateFirestore() async {
    await FirebaseFirestore.instance.collection('playlists').doc(id).update(toMap());
  }

  // Delete the Firestore entry
  Future<void> deleteFromFirestore() async {
    await FirebaseFirestore.instance.collection('playlists').doc(id).delete();
  }
}
