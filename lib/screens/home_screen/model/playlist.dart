import 'package:Excite/screens/home_screen/api/Songs.dart';

class Artist {
  //List<Songs> songs;
  //Artist({required this.songs});
  String? name;
  String? id;
  String? imageSrc;
  int? noSongs;

  Artist({this.name, this.id, this.imageSrc, this.noSongs});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'],
      id: json['id'],
      imageSrc: json['image'],
      noSongs: json['no_of_songs'],
    );
  }
  filter(List<Songs> songs) {
    for (int i = 0; i < songs.length; i++) {
      // if()
    }
  }

  List<List<Songs>> getArtists(List<Songs> songsFrom) {
    List<String> artists = [];

    var seen = Set<String>();

    for (int i = 0; i < songsFrom.length; i++) {
      artists.add(songsFrom[i].songArtist);
      print(artists[i]);
    }
    List unique = artists.where((element) => seen.add(element)).toList();

    print(unique.toString());
    print('Lenght ${unique.length}');

    List<List<Songs>> artistSongs = [];
    for (int i = 0; i < unique.length; i++) {
      List<Songs> temp = [];
      for (int j = 0; j < songsFrom.length; j++) {
        if (unique[i] == songsFrom[j].songArtist) {
          temp.add(songsFrom[j]);
        }
      }
      artistSongs.add(temp);
      // print(artists[i]);
    }

    print(artistSongs);
    print('Lenght ${artistSongs.length}');

    return artistSongs;
  }
}

class Playlist {
  String title;
  List songs;

  List getPlaylists(List songsFrom) {
    List<String> playlists = [];

    var seen = Set<String>();

    for (int i = 0; i < songsFrom.length; i++) {
      playlists.add(songsFrom[i].songArtist);
      print(playlists[i]);
    }
    List unique = playlists.where((element) => seen.add(element)).toList();

    print(unique.toString());
    print('Lenght ${unique.length}');

    List playlistSongs = [];
    for (int i = 0; i < unique.length; i++) {
      var temp = [];
      for (int j = 0; j < songsFrom.length; j++) {
        if (unique[i] == songsFrom[j].songArtist) {
          temp.add(songsFrom[j].toJson());
        }
      }
      playlistSongs.add(temp);
      // print(artists[i]);
    }

    print(playlistSongs);
    print('Lenght ${playlistSongs.length}');

    return playlistSongs;
  }

  Playlist({required this.title, required this.songs});
  toJson() {
    Map<String, dynamic> m = Map();
    m['title'] = title;
    m['songs'] = songs;
    return m;
  }

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      Playlist(title: json['title'], songs: json['songs']);
}

class PlaylistList {
  List<Playlist> playlists = [];

  toJSONEncodable() {
    return playlists.map((item) {
      return item.toJson();
    }).toList();
  }
}
