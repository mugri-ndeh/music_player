import 'dart:convert';
import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/server/api/api.dart';
import 'package:http/http.dart' as http;

class SongsApi {
  static Future<List<Songs>> getSongs(String query) async {
    final url = Uri.parse(Api.getSongs_api);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List songs = json.decode(response.body);

      return songs.map((json) => Songs.fromJson(json)).where((song) {
        final titleLower = song.songName.toLowerCase();
        final authorLower = song.songArtist.toLowerCase();
        final searchLower = query.toLowerCase();

        return titleLower.contains(searchLower) ||
            authorLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception();
    }
  }
}
