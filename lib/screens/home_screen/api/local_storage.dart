import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/model/playlist.dart';
import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';

class PlaylistHelper with ChangeNotifier {
  // final PlaylistList list = new PlaylistList();
  List playlists = [];
  List songs = [];
  final LocalStorage storage = new LocalStorage('playlists');
  List<Songs> allSongs = [];

  init() async {
    playlists = await getPLaylists();
  }

  PlaylistHelper() {
    init();
  }

  getAllSongs(List<Songs> gottenSongs) {
    allSongs = [];
    allSongs = gottenSongs;
    notifyListeners();
  }

  addItem(String title, List songs) async {
    await storage.ready;

    final item = new Playlist(
        title: title, songs: songs.map((e) => e.toJson()).toList());
    playlists.add(item.toJson());
    _saveToStorage();
    notifyListeners();
  }

  addToPlaylist(String title, Songs song) {
    for (var playlist in playlists) {
      if (Playlist.fromJson(playlist).title == title) {
        Playlist.fromJson(playlist).songs.add(song.toJson());
        _saveToStorage();
      }
    }
  }

  _saveToStorage() async {
    await storage.ready;

    storage.setItem('playlist', playlists).then((value) => print('ADDED'));
    print(playlists);
    notifyListeners();
  }

  clearStorage() async {
    await storage.clear();
    playlists = storage.getItem('playlist') ?? [];
    notifyListeners();
  }

  removePlaylist(String title) async {
    await storage.ready;

    for (var playlist in playlists) {
      if (Playlist.fromJson(playlist).title == title) {
        playlists.remove(playlist);
        _saveToStorage();
      }
    }
    notifyListeners();
  }

  removeSong(String title, Songs song) async {
    await storage.ready;
    var val = false;
    for (var playlist in playlists) {
      var ans = false;
      if (Playlist.fromJson(playlist).title == title) {
        Playlist.fromJson(playlist)
            .songs
            .removeWhere((element) => Songs.fromJson(element).id == song.id);

        //.map((e) => Songs.fromJson(e)).toList();
        // .removeWhere((e) {
        //   if (e['id'] == song.toJson()['id']) {
        //     ans = true;
        //   }
        //   return ans;
        // });
        print('REMOVED $ans');
        _saveToStorage();
        break;
      }
    }
    notifyListeners();
  }

  Future<List> getPLaylists() async {
    await storage.ready;
    playlists = await storage.getItem('playlist') ?? [];

    notifyListeners();
    return playlists;
  }
}

class FavouritesHelper with ChangeNotifier {
  final LocalStorage storage = LocalStorage('favourites');
  List favourites = [];
  bool isFavourite = false;

  init() async {
    favourites = await getFavourites();
    print('INIT FAV HELPER');
    notifyListeners();
  }

  FavouritesHelper() {
    init();
  }

  bool isfavourite(Songs song) {
    bool favourite = false;
    int i;
    for (i = 0; i < favourites.length; i++) {
      if (song.id == Songs.fromJson(favourites[i]).id) {
        favourite = true;
      }
    }
    isFavourite = favourite;
    notifyListeners();
    print(favourite);
    return favourite;
  }

  addFavourites(Songs song) {
    favourites.add(song.toJson());
    _saveToStorage();
    notifyListeners();
  }

  remove(Songs song) async {
    await storage.ready;

    favourites.removeWhere((element) {
      //print(element.values);
      var val = false;
      print(song.toJson()['id']);

      if (element['id'] == song.toJson()['id']) {
        val = true;
      } else {
        val = false;
      }
      return val;

      //return element.values == song.toJson().values;
    });
    print(favourites);
    _saveToStorage();
    notifyListeners();
    //storage.deleteItem('favourite $name');
  }

  _saveToStorage() async {
    await storage.ready;
    // List existing = await getFavourites();
    // existing.add(song.toJson());
    storage.setItem('favourite', favourites);
    print('SAVED CORRECTLY');
    notifyListeners();
  }

  getFavourites() async {
    await storage.ready;
    List fav = await storage.getItem('favourite') ?? [];
    notifyListeners();

    return fav;
  }
}

// class SongPlayer with ChangeNotifier {
//   List<Songs> playlist = [];
//   getPlaylist(int index) {
//     switch (index) {
//       case 0:
//         playlist = getArtist();
//         break;
//       case 1:
//         playlist = getFavourites();

//         break;
//       case 2:
//         playlist = getPlaylists();

//         break;
//       default:
//     }
//   }

//   List<Songs> getArtist() {}

//   List<Songs> getPlaylists() {}

//   List<Songs> getFavourites() {}
// }
