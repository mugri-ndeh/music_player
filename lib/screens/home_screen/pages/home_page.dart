import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/api/services.dart';
import 'package:Excite/screens/home_screen/model/playlist.dart';
import 'package:Excite/screens/home_screen/notifiers/play_button_notifier.dart';
import 'package:Excite/screens/home_screen/notifiers/progress_notifier.dart';
import 'package:Excite/screens/home_screen/widgets/all_songs.dart';
import 'package:Excite/screens/home_screen/widgets/artists.dart';
import 'package:Excite/screens/home_screen/widgets/custom_button.dart';
import 'package:Excite/screens/home_screen/widgets/favourites.dart';
import 'package:Excite/screens/home_screen/widgets/playlists.dart';
import 'package:Excite/screens/home_screen/widgets/search_widget.dart';
import 'package:Excite/screens/home_screen/widgets/shimmer_widget.dart';
import 'package:Excite/screens/home_screen/widgets/song_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Excite/constants/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../notifiers/audio_provider.dart';

var _cardColor = Colors.black;
const _maxHeight = 350.0;
const _minheight = 70.0;
final progressNotifier = ProgressNotifier();
final playButtonNotifier = PlayButtonNotifier();

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Songs> songs = [];
  String query = '';

  Timer? debouncer;
  bool isLoading = true;
  final controller = TextEditingController();
  int _selectedindex = 0;

  late FavouritesHelper favouritesProvider;
  late PlaylistHelper playlistProvider;
  late AudioHelper audioHelper;

  // Create an animation with value of type "double

  late List<Songs> playSongs;

  late List<Artist> artists;

  @override
  void initState() {
    init();
    super.initState();
  }

  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (debouncer != null) {
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }

  Future init() async {
    favouritesProvider = Provider.of<FavouritesHelper>(
      context,
      listen: false,
    );
    playlistProvider = Provider.of<PlaylistHelper>(
      context,
      listen: false,
    );
    audioHelper = Provider.of<AudioHelper>(
      context,
      listen: false,
    );
    final songs = await SongsApi.getSongs(query);
    final artists = await ArtistApi.getArtist(query);
    print('ARTISTS ');
    print(artists);
    setState(() {
      isLoading = false;
      playSongs = songs;
      // temp = songs;
    });
    setState(() {
      this.songs = songs;
      this.artists = artists;
      playlistProvider.getAllSongs(songs);
    });
  }

  @override
  void dispose() async {
    super.dispose();
    debouncer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
          width: 100,
          height: 30,
          child: Image(
            image: AssetImage("assets/logo/splash_logo.png"),
            gaplessPlayback: true,
            fit: BoxFit.fitWidth,
          ),
        ),
        backgroundColor: black,
      ),
      backgroundColor: black,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                color: black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _searchResult(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              CustomButtonWidget(
                                  child: Center(
                                    child: FaIcon(
                                      Icons.music_note,
                                      color: _selectedindex == 0
                                          ? white
                                          : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedindex = 0;
                                      //playlistsInit(playSongs);
                                    });
                                  },
                                  size: 40),
                              Text(
                                "All songs",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      _selectedindex == 0 ? white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.07),
                          Column(
                            children: [
                              CustomButtonWidget(
                                  child: Center(
                                    child: FaIcon(
                                      Icons.playlist_play_rounded,
                                      color: _selectedindex == 1
                                          ? white
                                          : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedindex = 1;
                                    });
                                  },
                                  size: 40),
                              Text(
                                "Playlists",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      _selectedindex == 1 ? white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.07),
                          Column(
                            children: [
                              CustomButtonWidget(
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.solidHeart,
                                      size: 16,
                                      color: _selectedindex == 2
                                          ? white
                                          : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedindex = 2;
                                    });
                                  },
                                  size: 40),
                              Text(
                                "Favourites",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      _selectedindex == 2 ? white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.07),
                          Column(
                            children: [
                              CustomButtonWidget(
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.podcast,
                                      size: 16,
                                      color: _selectedindex == 3
                                          ? white
                                          : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedindex = 3;
                                    });
                                  },
                                  size: 40),
                              Text(
                                "Artists",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      _selectedindex == 3 ? white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: isLoading
                      ? ListView.builder(
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          itemBuilder: (context, index) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                child: buildShimmer(),
                              ),
                            ));
                          })
                      : IndexedStack(
                          index: _selectedindex,
                          children: [
                            AllSongs(
                                audioHelper: audioHelper, playsongs: songs),
                            PlayListWidget(
                                playlistProvider: playlistProvider,
                                audioHelper: audioHelper),
                            FavouritesWidget(audioHelper: audioHelper),
                            ArtistsWidget(
                                songs: playSongs,
                                playlistProvider: playlistProvider,
                                artists: artists,
                                audioHelper: audioHelper)
                          ],
                        )),
            ],
          ),
          SongPlayer(
              playlistProvider: playlistProvider, audioHelper: audioHelper)
        ],
      ),
    );
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Title or Author Name',
        onChanged: searchBook,
      );

  Future searchBook(String query) async => debounce(
        () async {
          final songs = await SongsApi.getSongs(query);
          if (!mounted) return;
          setState(() {
            this.query = query;
            this.songs = songs;
          });
          print('SONG IS');
          print(songs[0].id);
        },
      );

  Widget _searchResult() {
    final styleActive = TextStyle(color: white);
    final styleHint = TextStyle(color: white);
    final style = controller.text.isEmpty ? styleHint : styleActive;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: TypeAheadField<Songs?>(
        errorBuilder: (context, error) {
          return Center(
            child: Container(
                height: 100,
                decoration: BoxDecoration(color: Colors.black),
                child: Center(
                    child: Text('Unable to connect to cloud', style: style))),
          );
        },
        suggestionsBoxDecoration: SuggestionsBoxDecoration(color: Colors.black),
        textFieldConfiguration: TextFieldConfiguration(
            style: style,
            controller: controller,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                hintStyle: TextStyle(color: Colors.white),
                hintText: 'Title or Artist name',
                suffixIcon: controller.text == ""
                    ? null
                    : IconButton(
                        onPressed: (() {
                          setState(() {
                            controller.clear();
                          });
                        }),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ))),
        suggestionsCallback: SongsApi.getSongs,
        itemBuilder: (context, Songs? suggesion) {
          final song = suggesion;
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: song!.songImage,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  song.songArtist,
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 14), color: Colors.white),
                ),
                subtitle: Text(
                  song.songName,
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                selected: true,
                selectedTileColor: Colors.blueAccent.shade100.withOpacity(0.1),
              ),
            ),
          );
        },
        onSuggestionSelected: (Songs? suggesion) {
          List<Songs> list = [];
          list.add(suggesion!);
          audioHelper
              .setInitialPlaylist(list)
              .then((value) => audioHelper.play());
        },
      ),
    );
  }
}

Widget buildShimmer() => ListTile(
      leading: ShimmerWidget.circular(
        height: 80,
        width: 80,
        shapeBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      title: ShimmerWidget.rectangular(height: 16),
      subtitle: ShimmerWidget.rectangular(height: 14),
    );

@override
bool shouldRepaint(CustomPainter oldDelegate) {
  return true;
}
