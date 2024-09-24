class Song{
  final String title;
  final String description;
  final String url;
  final String coverUrl;

  Song({
    required this.title,
    required this.description,
    required this.url,
    required this.coverUrl
  });

  static List<Song> songs = [
    Song(
      title: 'Love Yourself',
      description: 'Justin Bieber',
      url: 'assets/music/Justin Bieber - Love Yourself (PURPOSE _ The Movement)_oyEuk8j8imI.mp3',
      coverUrl: 'assets/images/love_yourself.jpeg',
    ),
    Song(
      title: 'Lovely',
      description: 'Song by Billie Eilish and Khalid',
      url: 'assets/music/Lovely_320(PagalWorld.com.so).mp3',
      coverUrl: 'assets/images/lovely.jpeg',
    ),
    Song(
      title: 'Perfect',
      description: 'Perfect',
      url: 'assets/music/Perfect Ed Sheeran-(PagalSongs.Com.IN).mp3',
      coverUrl: 'assets/images/download.jpeg',
    ),
    Song(
      title: 'I wanna be yours',
      description: 'Song by Arctic Monkeys',
      url: 'assets/music/I-Wanna-Be-Yours(PagalWorld).mp3',
      coverUrl: 'assets/images/i wanna be yours.webp',
    ),
    Song(
      title: 'Standing By You',
      description: 'Nish',
      url: 'assets/music/Standing By You (Duniya Cover) Bangla-(PagalSongs.Com.IN).mp3',
      coverUrl: 'assets/images/standing by you.webp',
    ),
    Song(
      title: 'Akhiyaan',
      description: 'Mitraz',
      url: 'assets/music/Akhiyaan-Mitraz(PagalWorldl).mp3',
      coverUrl: 'assets/images/th.jpeg',
    )
  ];
}