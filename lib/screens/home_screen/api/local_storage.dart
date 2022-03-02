import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/model/playlist.dart';
import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';

class PlaylistHelper with ChangeNotifier {
  // final PlaylistList list = new PlaylistList();
  List playlists = [];
  final LocalStorage storage = new LocalStorage('playlists');

  init() async {
    playlists = await getPLaylists();
  }

  PlaylistHelper() {
    init();
  }

  addItem(String title, List<Songs> songs) {
    final item = new Playlist(title: title, songs: songs);
    playlists.add(item);
    _saveToStorage(title);
    notifyListeners();
  }

  _saveToStorage(String title) async {
    await storage.ready;

    storage.setItem(title, playlists);
    notifyListeners();
  }

  clearStorage() async {
    await storage.clear();
    playlists = storage.getItem('playlists') ?? [];
    notifyListeners();
  }

  Future<List> getPLaylists() async {
    await storage.ready;
    playlists = await storage.getItem('playlists');
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
  }

  FavouritesHelper() {
    init();
  }

  addFavourites(Songs song) {
    favourites.add(song.toJson());
    _saveToStorage();
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
    List fav = await storage.getItem('favourite');
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
