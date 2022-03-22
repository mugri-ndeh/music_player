import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/model/playlist.dart';
import 'package:Excite/screens/home_screen/notifiers/audio_provider.dart';
import 'package:Excite/screens/home_screen/widgets/custom_button.dart';
import 'package:Excite/screens/home_screen/widgets/songlist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/constants.dart';
import '../api/Songs.dart';

class ArtistsWidget extends StatefulWidget {
  ArtistsWidget({
    Key? key,
    required this.songs,
    required this.playlistProvider,
    required this.artists,
    required this.audioHelper,
  }) : super(key: key);
  final List<Songs> songs;
  final PlaylistHelper playlistProvider;
  final List<Artist> artists;
  final AudioHelper audioHelper;

  @override
  State<ArtistsWidget> createState() => _ArtistsWidgetState();
}

class _ArtistsWidgetState extends State<ArtistsWidget> {
  List<List<Songs>> artistSongs = [];

  getArtistsSongs() {
    Artist artist = Artist();
    artistSongs = artist.getArtists(widget.songs);
    print(artistSongs);
    return artistSongs;
  }

  getArt(String namefrom) {
    var src = '';
    for (var item in widget.artists) {
      if (item.name == namefrom) {
        src = item.imageSrc!;
        print(src);
      }
    }
    return src;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getArtistsSongs();
  }

  @override
  Widget build(BuildContext context) {
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
            return Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => SongList(
                          playlistProvider: widget.playlistProvider,
                          audioHelper: widget.audioHelper,
                          child: ArtistSongDetails(
                              artists: widget.artists,
                              audioHelper: widget.audioHelper,
                              songs: artistSongs[index],
                              artistName: artistSongs[index][index].songArtist,
                              url: artistSongs[index][index].songImage))),
                    ),
                  );
                },
                child: _buildCard(
                  artistSongs[index],
                  artistSongs[index][index].songArtist,
                  artistSongs[index][index].songImage,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(List artists, String artistName, String url) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Card(
          elevation: 2,
          shadowColor: Colors.blueAccent.withOpacity(0.1),
          color: Colors.black,
          clipBehavior: Clip.antiAlias,
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10.0),
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
                ),
              ))),
    );
  }
}

class ArtistSongDetails extends StatefulWidget {
  ArtistSongDetails(
      {Key? key,
      required this.songs,
      required this.artistName,
      required this.url,
      required this.audioHelper,
      required this.artists})
      : super(key: key);
  final List<Songs> songs;
  final String artistName;
  final String url;
  final AudioHelper audioHelper;
  final List<Artist> artists;

  @override
  State<ArtistSongDetails> createState() => _ArtistSongDetailsState();
}

class _ArtistSongDetailsState extends State<ArtistSongDetails> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getArt(String namefrom) {
    var src = '';
    for (var item in widget.artists) {
      if (item.name == namefrom) {
        src = item.imageSrc!;
        print(src);
      }
    }
    return src;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
          height: 150,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          CachedNetworkImageProvider(getArt(widget.artistName)),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                  height: 80,
                  width: 80,
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artistName,
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      '${widget.songs.length} Tracks',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    )
                  ],
                )
              ],
            ),
          ),
          decoration: BoxDecoration(
              color: Colors.blueAccent.shade100.withOpacity(0.5),
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(100))),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Card(
              elevation: 2,
              shadowColor: Colors.white38,
              color: Colors.black,
              clipBehavior: Clip.antiAlias,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.songs.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () async {
                    widget.audioHelper
                        .setInitialPlaylist(widget.songs)
                        .then((value) {
                      widget.audioHelper.getIndex();
                      widget.audioHelper.playIndex(i);
                      print('CLICKED $i');
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: widget.songs[i].songImage,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            widget.songs[i].songName,
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
