import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/api/services.dart';
import 'package:Excite/screens/home_screen/model/playlist.dart';
import 'package:Excite/screens/home_screen/notifiers/play_button_notifier.dart';
import 'package:Excite/screens/home_screen/notifiers/progress_notifier.dart';
import 'package:Excite/screens/home_screen/widgets/custom_button.dart';
import 'package:Excite/screens/home_screen/widgets/search_widget.dart';
import 'package:Excite/screens/home_screen/widgets/shimmer_widget.dart';
import 'package:Excite/screens/profile_screen/profile.dart';
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

var _cardColor = Colors.black;
const _maxHeight = 350.0;
const _minheight = 70.0;
final progressNotifier = ProgressNotifier();
final playButtonNotifier = PlayButtonNotifier();

class NewHomePage extends StatefulWidget {
  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage>
    with TickerProviderStateMixin {
  List songs = [];
  String query = '';
  bool isShuffle = false;
  bool isRepeat = false;
  Timer? debouncer;
  late AnimationController _controller;
  bool _expanded = false;
  bool isPlaying = false;
  double _currentHeight = _minheight;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isLoading = true;
  bool isFavSong = false;
  var _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  int _selectedindex = 0;
  TextEditingController _textController = TextEditingController();

  late FavouritesHelper favouritesProvider;
  late PlaylistHelper playlistProvider;

  // Create an animation with value of type "double

  late List<Songs> playSongs;
  late List currentPlaylist;
  late List favouriteSongs;
  late List artistSongs;
  late List temp;
  late List playlists;
  late List<Songs> searchedSongs;
  late List<Artist> artists;

  Future<List> getFav() async {
    var provider = Provider.of<FavouritesHelper>(context, listen: false);
    var temp = (await provider.getFavourites()) ?? [];
    setState(() {
      songs = temp.map((e) => Songs.fromJson(e)).toList() ?? [];
      favouriteSongs = songs;
    });
    print('SONGS $songs');
    return songs;
  }

  getArtistsSongs() {
    Artist artist = Artist();
    //artistSongs = artist.getArtists(temp);
    return artistSongs;
  }

  getArt(String namefrom) {
    var src = '';
    for (var item in artists) {
      if (item.name == namefrom) {
        src = item.imageSrc!;
        print(src);
      }
    }
    return src;
  }

  playlistsInit() {
    playlistProvider = Provider.of<PlaylistHelper>(
      context,
      listen: false,
    );
  }

  getPlayList(String title) {
    List songsfrom = [];
    for (var playlist in playlistProvider.playlists) {
      if (Playlist.fromJson(playlist).title == title) {
        songsfrom = Playlist.fromJson(playlist).songs;
      }
    }
    return songsfrom;
  }

  @override
  void initState() {
    init();
    playlistsInit();
    getFav();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    super.initState();
  }

  bool isfavourite(Songs song) {
    bool favourite = false;
    int i;
    for (i = 0; i < favouriteSongs.length; i++) {
      if (song.id == favouriteSongs[i].id) {
        favourite = true;
      }
    }
    print(favourite);
    return favourite;
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
    _listenForChangesInBufferedPosition();
    _listenForChangesInPlayerPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInPlayerState();
    final songs = await SongsApi.getSongs(query);
    final artists = await ArtistApi.getArtist(query);
    print('ARTISTS ');
    print(artists);
    setState(() {
      isLoading = false;
      playSongs = songs;
      temp = songs;
      favouritesProvider = Provider.of<FavouritesHelper>(
        context,
        listen: false,
      );
      playlistProvider = Provider.of<PlaylistHelper>(
        context,
        listen: false,
      );
    });
    setState(() {
      this.songs = songs;
      this.artists = artists;
    });
  }

  @override
  void dispose() async {
    super.dispose();
    _controller.dispose();
    await _audioPlayer.stop();
    _audioPlayer.dispose();
    debouncer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _buildPlaylist();
    final size = MediaQuery.of(context).size;
    final menuwidth = MediaQuery.of(context).size.width * 0.5;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _audioPlayer.pause();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
            },
            icon: FaIcon(FontAwesomeIcons.user),
            iconSize: 16,
            padding: EdgeInsets.symmetric(horizontal: 24),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          )
        ],
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
                                      songs = playSongs;
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
                                      songs = playSongs;
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
                                    setState(() async {
                                      _selectedindex = 2;
                                      getFav();
                                      favouriteSongs = await getFav();
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
                                      getArtistsSongs();
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
                            _buildAllSongs(),
                            _buildPlaylist(),
                            _buildFavourites(),
                            _buildArtists(),
                          ],
                        )),
            ],
          ),
          GestureDetector(
            onVerticalDragUpdate: _expanded
                ? (details) {
                    setState(() {
                      final newHeight = _currentHeight - details.delta.dy;
                      _controller.value = _currentHeight / _maxHeight;
                      _currentHeight = newHeight.clamp(_minheight, _maxHeight);
                    });
                  }
                : null,
            onVerticalDragEnd: _expanded
                ? (details) {
                    if (_currentHeight < _maxHeight / 1.5) {
                      _controller.reverse();
                      _expanded = false;
                    } else {
                      _expanded = true;
                      _controller.forward(from: _currentHeight / _maxHeight);
                      _currentHeight = _maxHeight;
                    }
                  }
                : null,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, snapshot) {
                final value =
                    const ElasticInOutCurve(0.7).transform(_controller.value);
                return Stack(
                  children: [
                    Positioned(
                      height: lerpDouble(_minheight, _currentHeight, value),
                      left:
                          lerpDouble(size.width / 2 - menuwidth / 2, 0, value),
                      width: lerpDouble(menuwidth, size.width, value),
                      bottom: lerpDouble(40.0, 0.0, value),
                      child: Container(
                        child: _expanded
                            ? Opacity(
                                opacity: _controller.value,
                                child: _buildExpandedContent())
                            : _buildMenuContent(),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                            bottom: Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List artists, String artistName, String url) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(2),
      child: Card(
        elevation: 2,
        shadowColor: Colors.white38,
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  iconColor: Colors.white,
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: getArt(artistName),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            artistName,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          selected: true,
                          selectedTileColor: Colors.blue.withOpacity(0.1)),
                    )),
                collapsed: Text(
                  '',
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < artists.length; i++)
                      GestureDetector(
                        onTap: () {
                          print('TAPP');
                          setState(() {
                            isFavSong = isfavourite(artists[i]);
                            CurrentSong.currentSong = i;
                            currentPlaylist = artists;
                            _audioPlayer.setUrl(artists[i].songSrc);
                            _audioPlayer.play();
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: CachedNetworkImage(
                                    imageUrl: artists[i].songImage,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  artists[i].songName,
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0)),
                                selected: true,
                              ),
                            )),
                      ),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: ExpandableThemeData(
                          crossFadePoint: 0, iconColor: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildArtists() {
    getArtistsSongs();
    return Scaffold(
      backgroundColor: Colors.black,
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
          itemCount: artistSongs.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            print(songs);
            return ExpandableNotifier(
              child: Center(
                child: GestureDetector(
                    onTap: () {
                      //setState(() async {});
                      List list = artistSongs[index]
                          .map((e) => Songs.fromJson(e))
                          .toList()[index];
                      print(list.toString());
                    },
                    child: _buildCard(
                        artistSongs[index]
                            .map((e) => Songs.fromJson(e))
                            .toList(),
                        artistSongs[index]
                            .map((e) => Songs.fromJson(e))
                            .toList()[index]
                            .songArtist,
                        artistSongs[index]
                            .map((e) => Songs.fromJson(e))
                            .toList()[index]
                            .songImage)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavourites() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<FavouritesHelper>(
        builder: (_, favProv, __) => favProv.favourites.length == 0
            ? Center(
                child: Text(
                  'No favourites',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                itemCount: favProv.favourites.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() async {
                          currentPlaylist = await getFav();
                          isFavSong = isfavourite(songs[index]);
                          CurrentSong.currentSong = index;
                          CurrentSong.favourite = true;
                          _audioPlayer.setUrl(songs[index].songSrc);
                          _audioPlayer.play();
                        });
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: songs[index].songImage,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                songs[index].songArtist,
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(fontSize: 14),
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                songs[index].songName,
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              selected: true,
                              selectedTileColor:
                                  Colors.blueAccent.shade100.withOpacity(0.1),
                            ),
                          )),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPlaylist() {
    return Scaffold(
      floatingActionButton: CustomButtonWidget(
        size: 50,
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.plus,
            color: Colors.white,
          ),
        ),
        onTap: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                    backgroundColor: black,
                    content: SizedBox(
                      height: 200,
                      width: 300,
                      child: Column(
                        children: [
                          Text(
                            'Enter name of playlist',
                            style: TextStyle(color: Colors.white),
                          ),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (val) => val!.isEmpty
                                  ? 'Please enter playlist name'
                                  : null,
                              controller: _textController,
                              textAlignVertical: TextAlignVertical.center,
                              onSaved: (String? val) {},
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.white),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                        color: Colors.white, width: 2.0)),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      playlistProvider
                                          .addItem(_textController.text, []);
                                      _textController.clear();
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text('Add')),
                              SizedBox(width: 20),
                              ElevatedButton(
                                  onPressed: () {
                                    _textController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel')),
                            ],
                          )
                        ],
                      ),
                    ),
                  ));
        },
      ),
      backgroundColor: Colors.black,
      body: playlistProvider.playlists.length == 0
          ? Center(
              child: Text(
                'No playlist available',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
              itemCount: playlistProvider.playlists.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      String title =
                          Playlist.fromJson(playlistProvider.playlists[index])
                              .title;
                      setState(() {
                        currentPlaylist = getPlayList(title);
                        songs = currentPlaylist;
                        isFavSong = isfavourite(currentPlaylist[index]);

                        CurrentSong.currentSong = index;
                        print('IS Current song: ${CurrentSong.favourite}');
                      });
                      _audioPlayer.setUrl(currentPlaylist[index].songSrc);
                      _audioPlayer.play();
                    },
                    child: _buildPlayCard(
                        Playlist.fromJson(playlistProvider.playlists[index])
                            .songs
                            .map((e) => Songs.fromJson(e))
                            .toList(),
                        Playlist.fromJson(playlistProvider.playlists[index])
                            .title),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildExpandedContent() {
    if (CurrentSong.currentSong == null) {
      return SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                    CustomButtonWidget(
                        child: Center(
                          child: FaIcon(
                            Icons.playlist_add,
                            color: white,
                          ),
                        ),
                        onTap: () async {
                          var length = 1;
                          await playlistProvider
                              .getPLaylists()
                              .then((value) => length = 1);
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    backgroundColor: black,
                                    content: SizedBox(
                                      height: 300,
                                      width: 300,
                                      child: Consumer<PlaylistHelper>(
                                        builder: (_, playProvider, __) {
                                          print(playProvider.playlists.length);
                                          var p = playlistProvider.playlists
                                              .map((e) => Playlist.fromJson(e))
                                              .toList();
                                          return p.length == 0
                                              ? Center(
                                                  child: Text(
                                                      'No playlist available',
                                                      style: TextStyle(
                                                          color: Colors.white)))
                                              : ListView.builder(
                                                  itemCount: p.length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (c, i) =>
                                                      GestureDetector(
                                                    onTap: () {
                                                      playlistProvider
                                                          .addToPlaylist(
                                                              p[i].title,
                                                              currentPlaylist[
                                                                  CurrentSong
                                                                      .currentSong!]);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ListTile(
                                                        title: Text(
                                                          p[i].title,
                                                          style: GoogleFonts.poppins(
                                                              textStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          14),
                                                              color: white),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0)),
                                                        selected: true,
                                                        selectedTileColor:
                                                            Colors.blueAccent
                                                                .shade100
                                                                .withOpacity(
                                                                    0.1),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                        },
                                      ),
                                    ),
                                  ));
                        },
                        size: 50),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomButtonWidget(
                            onTap: () {},
                            size: 120,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    currentPlaylist[CurrentSong.currentSong!]
                                        .songImage,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                shape: BoxShape.circle,
                              ),
                              height: 120,
                              width: 120,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                    CustomButtonWidget(
                        child: Center(
                          child: FaIcon(
                            isFavSong
                                ? FontAwesomeIcons.solidHeart
                                : FontAwesomeIcons.heart,
                            size: 20,
                            color: white,
                          ),
                        ),
                        onTap: () async {
                          print('HEART TAPPED');
                          if (isfavourite(
                              currentPlaylist[CurrentSong.currentSong!])) {
                            setState(() {
                              favouritesProvider.remove(
                                  currentPlaylist[CurrentSong.currentSong!]);
                              isFavSong = false;
                              getFav();
                            });

                            await favouritesProvider.getFavourites();
                          } else {
                            setState(() {
                              favouritesProvider.addFavourites(
                                  currentPlaylist[CurrentSong.currentSong!]);
                              isFavSong = true;
                              getFav();
                            });

                            // await favouritesProvider.getFavourites();
                          }

                          //print(provider.getFavourites().length);
                        },
                        size: 50),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  currentPlaylist[CurrentSong.currentSong!].songName,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  currentPlaylist[CurrentSong.currentSong!].songArtist,
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 16, color: Colors.white.withAlpha(90))),
                ),
                const SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ValueListenableBuilder<ProgressBarState>(
                        valueListenable: progressNotifier,
                        builder: (_, value, __) {
                          return ProgressBar(
                            progressBarColor: lightBlue,
                            baseBarColor: Colors.white.withOpacity(0.24),
                            bufferedBarColor: Colors.white.withOpacity(0.24),
                            thumbColor: white,
                            timeLabelLocation: TimeLabelLocation.sides,
                            timeLabelTextStyle: TextStyle(color: white),
                            thumbRadius: 12.0,
                            barHeight: 12.0,
                            progress: value.current,
                            buffered: value.buffered,
                            total: value.total,
                            onSeek: _audioPlayer.seek,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButtonWidget(
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.random,
                            size: 20,
                            color: isShuffle ? white : white.withAlpha(90),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            isShuffle = !isShuffle;
                            _audioPlayer.shuffleIndices;
                            _audioPlayer.setShuffleModeEnabled(isShuffle);
                            var tempo = [];
                            if (isShuffle) {
                              tempo = currentPlaylist;

                              currentPlaylist
                                  .shuffle(Random(CurrentSong.currentSong));
                            } else {
                              currentPlaylist = tempo;
                            }
                          });
                        },
                        size: 40),
                    SizedBox(width: 10),
                    CustomButtonWidget(
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.stepBackward,
                          color: white,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (CurrentSong.currentSong == 0) {
                            return null;
                          } else {
                            CurrentSong.currentSong =
                                CurrentSong.currentSong! - 1;
                            _audioPlayer.stop();
                            _audioPlayer.setUrl(
                                currentPlaylist[CurrentSong.currentSong!]
                                    .songSrc);
                            _audioPlayer.play();
                          }
                        });
                      },
                      size: 50,
                    ),
                    SizedBox(width: 10),
                    ValueListenableBuilder<ButtonState>(
                      valueListenable: playButtonNotifier,
                      builder: (_, value, __) {
                        switch (value) {
                          case ButtonState.loading:
                            return CustomButtonWidget(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: white,
                                ),
                              ),
                              onTap: () {},
                              size: 70,
                            );
                          case ButtonState.paused:
                            return CustomButtonWidget(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.play,
                                  color: white,
                                ),
                              ),
                              onTap: () {
                                _audioPlayer.play();
                              },
                              size: 70,
                            );
                          case ButtonState.playing:
                            return CustomButtonWidget(
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.pause,
                                  color: white,
                                ),
                              ),
                              onTap: () {
                                _audioPlayer.pause();
                              },
                              size: 70,
                            );
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    CustomButtonWidget(
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.stepForward,
                          color: white,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (CurrentSong.currentSong !=
                              currentPlaylist.length - 1) {
                            CurrentSong.currentSong =
                                CurrentSong.currentSong! + 1;
                            _audioPlayer.stop();
                            _audioPlayer.setUrl(
                                currentPlaylist[CurrentSong.currentSong!]
                                    .songSrc);
                            _audioPlayer.play();
                          } else {
                            return null;
                          }
                        });
                      },
                      size: 50,
                    ),
                    SizedBox(width: 10),
                    CustomButtonWidget(
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.retweet,
                            size: 20,
                            color: isRepeat ? white : white.withAlpha(90),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            isRepeat = !isRepeat;
                          });
                          if (isRepeat) {
                            _audioPlayer.setLoopMode(LoopMode.one);
                          } else {
                            _audioPlayer.setLoopMode(LoopMode.off);
                          }
                        },
                        size: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMenuContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomButtonWidget(
          size: 40,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.stepBackward,
              color: white,
              size: 16,
            ),
          ),
          onTap: () {
            setState(() {
              if (CurrentSong.currentSong == 0) {
                return null;
              } else {
                CurrentSong.currentSong = CurrentSong.currentSong! - 1;
                _audioPlayer.stop();
                _audioPlayer.setUrl(songs[CurrentSong.currentSong!].songSrc);
                _audioPlayer.play();
              }
            });
          },
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = true;
              _currentHeight = _maxHeight;
              _controller.forward(from: 0.0);
            });
          },
          child: CurrentSong.currentSong == null
              ? CircleAvatar(
                  backgroundImage: AssetImage("assets/logo/logo.png"),
                  maxRadius: 20.0,
                )
              : CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      currentPlaylist[CurrentSong.currentSong!].songImage),
                  maxRadius: 20.0,
                ),
        ),
        CustomButtonWidget(
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.stepForward,
              color: white,
              size: 16,
            ),
          ),
          onTap: () {
            setState(() {
              if (CurrentSong.currentSong != songs.length - 1) {
                CurrentSong.currentSong = CurrentSong.currentSong! + 1;
                _audioPlayer.stop();
                _audioPlayer.setUrl(songs[CurrentSong.currentSong!].songSrc);
                _audioPlayer.play();
              } else {
                return null;
              }
            });
          },
          size: 40,
        ),
      ],
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

  void _listenForChangesInPlayerState() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
        setState(() {
          if (CurrentSong.currentSong != currentPlaylist.length - 1) {
            CurrentSong.currentSong = CurrentSong.currentSong! + 1;
            _audioPlayer.stop();
            _audioPlayer
                .setUrl(currentPlaylist[CurrentSong.currentSong!].songSrc);
            _audioPlayer.play();
          } else {
            return null;
          }
        });
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInBufferedPosition() {
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInTotalDuration() {
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

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
          setState(() {
            currentPlaylist = [];
            currentPlaylist.add(suggesion);
            isFavSong = isfavourite(suggesion!);
            CurrentSong.currentSong = 0;
            _audioPlayer.setUrl(suggesion.songSrc);
            _audioPlayer.play();
          });
        },
      ),
    );
  }

  Widget _buildAllSongs() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      itemCount: songs.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                currentPlaylist = playSongs;
                CurrentSong.currentSong = index;
              });
              _audioPlayer.setUrl(playSongs[index].songSrc);
              _audioPlayer.play();
            },
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: playSongs[index].songImage,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      playSongs[index].songArtist,
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14), color: white),
                    ),
                    subtitle: Text(
                      playSongs[index].songName,
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    selected: true,
                    selectedTileColor:
                        Colors.blueAccent.shade100.withOpacity(0.1),
                  ),
                )),
          ),
        );
      },
    );
  }

  Widget _buildPlayCard(List playlists1, String playlistName) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(1),
      child: Card(
        elevation: 2,
        shadowColor: Colors.white38,
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        child: ScrollOnExpand(
          scrollOnExpand: true,
          scrollOnCollapse: false,
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              iconColor: Colors.white,
              headerAlignment: ExpandablePanelHeaderAlignment.center,
            ),
            header: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: ListTile(
                      title: Text(
                        playlistName,
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            color: Colors.white),
                      ),
                      trailing: TextButton(
                        child: Text(
                          'Remove',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          debugPrint('DELETE');
                          playlistProvider.removePlaylist(playlistName);
                          setState(() {});
                        },
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      selected: true,
                      selectedTileColor: Colors.black),
                )),
            collapsed: Text(
              '',
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < playlists1.length; i++)
                  GestureDetector(
                    onTap: () {
                      print('TAPP');
                      setState(() {
                        isFavSong = isfavourite(playlists1[i]);
                        CurrentSong.currentSong = i;
                        currentPlaylist = playlists1;
                        _audioPlayer.setUrl(playlists1[i].songSrc);
                        _audioPlayer.play();
                      });
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.shade100.withOpacity(0.1),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                imageUrl: playlists1[i].songImage,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              playlists1[i].songName,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            trailing: playlistName == 'All songs'
                                ? SizedBox.shrink()
                                : TextButton(
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      debugPrint('DELETE');
                                      playlistProvider.removeSong(
                                          playlistName, playlists1[i]);
                                      setState(() {});
                                    },
                                  ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            selected: true,
                            // selectedTileColor:
                            //     Colors.blueAccent.shade100.withOpacity(0.1),
                          ),
                        )),
                  ),
              ],
            ),
            builder: (_, collapsed, expanded) {
              return Padding(
                padding: EdgeInsets.only(left: 0, right: 0, bottom: 0),
                child: Expandable(
                  collapsed: collapsed,
                  expanded: expanded,
                  theme: const ExpandableThemeData(
                      crossFadePoint: 0,
                      iconColor: Colors.white,
                      hasIcon: true,
                      iconSize: 400),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }
}

class CurrentSong with ChangeNotifier {
  static int? currentSong;
  static bool favourite = false;
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
