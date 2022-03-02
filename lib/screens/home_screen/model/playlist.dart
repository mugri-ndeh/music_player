import 'package:Excite/screens/home_screen/api/Songs.dart';

class Artist {
  //List<Songs> songs;
  //Artist({required this.songs});
  String? name;
  filter(List<Songs> songs) {
    for (int i = 0; i < songs.length; i++) {
      // if()
    }
  }

  List getArtists(List songsFrom) {
    List<String> artists = [];

    var seen = Set<String>();

    for (int i = 0; i < songsFrom.length; i++) {
      artists.add(songsFrom[i].songArtist);
      print(artists[i]);
    }
    List unique = artists.where((element) => seen.add(element)).toList();

    print(unique.toString());
    print('Lenght ${unique.length}');

    List artistSongs = [];
    for (int i = 0; i < unique.length; i++) {
      var temp = [];
      for (int j = 0; j < songsFrom.length; j++) {
        if (unique[i] == songsFrom[j].songArtist) {
          temp.add(songsFrom[j].toJson());
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
  List<Songs> songs;

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
