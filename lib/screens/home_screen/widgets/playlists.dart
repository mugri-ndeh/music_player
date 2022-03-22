import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/widgets/songlist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../api/Songs.dart';
import '../api/Songs.dart';
import '../model/playlist.dart';
import '../notifiers/audio_provider.dart';
import 'custom_button.dart';

class PlayListWidget extends StatefulWidget {
  PlayListWidget(
      {Key? key, required this.playlistProvider, required this.audioHelper})
      : super(key: key);
  final PlaylistHelper playlistProvider;
  final AudioHelper audioHelper;

  @override
  State<PlayListWidget> createState() => _PlayListWidgetState();
}

class _PlayListWidgetState extends State<PlayListWidget> {
  TextEditingController _textController = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                                      widget.playlistProvider
                                          .addItem(_textController.text, []);
                                      setState(() {
                                        Fluttertoast.showToast(
                                            msg: 'Playlist created');
                                      });
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
      body: widget.playlistProvider.playlists.length == 0
          ? Center(
              child: Text(
                'No playlist available',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Consumer<PlaylistHelper>(
              builder: (_, playlistProvider, __) => ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                itemCount: widget.playlistProvider.playlists.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SongList(
                                    audioHelper: widget.audioHelper,
                                    playlistProvider: playlistProvider,
                                    child: PlaylistDetail(
                                        index: index,
                                        songs: Playlist.fromJson(widget
                                                .playlistProvider
                                                .playlists[index])
                                            .songs
                                            .map((e) => Songs.fromJson(e))
                                            .toList(),
                                        audioHelper: widget.audioHelper,
                                        playlistProvider: playlistProvider,
                                        playlistName: Playlist.fromJson(widget
                                                .playlistProvider
                                                .playlists[index])
                                            .title))));
                      },
                      child: _buildPlayCard(
                          Playlist.fromJson(
                                  widget.playlistProvider.playlists[index])
                              .songs
                              .map((e) => Songs.fromJson(e))
                              .toList(),
                          Playlist.fromJson(
                                  widget.playlistProvider.playlists[index])
                              .title),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildPlayCard(List<Songs> playlists, String playlistName) {
    return Padding(
        padding: const EdgeInsets.all(1),
        child: Card(
            elevation: 2,
            shadowColor: Colors.white38,
            color: Colors.black,
            clipBehavior: Clip.antiAlias,
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Dismissible(
                  background: Container(color: Colors.grey),
                  key: Key(playlistName),
                  onDismissed: (direction) {
                    debugPrint('DELETE');
                    setState(() {
                      widget.playlistProvider.removePlaylist(playlistName);
                      Fluttertoast.showToast(msg: 'Playlist deleted');
                    });
                  },
                  child: Container(
                    child: ListTile(
                        title: Text(
                          playlistName,
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              color: Colors.white),
                        ),
                        // trailing: TextButton(
                        //   child: Text(
                        //     'Remove',
                        //     style: TextStyle(color: Colors.red),
                        //   ),
                        //   onPressed: () {
                        //     debugPrint('DELETE');
                        //     widget.playlistProvider.removePlaylist(playlistName);
                        //     setState(() {
                        //       Fluttertoast.showToast(msg: 'PLaylist deleted');
                        //     });
                        //   },
                        // ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        selected: true,
                        selectedTileColor: Colors.black),
                  ),
                ))));
  }
}

class PlaylistDetail extends StatefulWidget {
  PlaylistDetail({
    Key? key,
    required this.songs,
    required this.audioHelper,
    required this.playlistProvider,
    required this.playlistName,
    required this.index,
  }) : super(key: key);
  final List<Songs> songs;
  final PlaylistHelper playlistProvider;
  final AudioHelper audioHelper;
  final String playlistName;
  final int index;

  @override
  State<PlaylistDetail> createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  @override
  Widget build(BuildContext context) {
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
                    backgroundColor: Colors.grey,
                    content: SizedBox(
                        height: 400,
                        width: 300,
                        child: Consumer<PlaylistHelper>(
                          builder: (_, playlist, __) => ListView.builder(
                            itemCount: playlist.allSongs.length,
                            itemBuilder: (c, i) => ListTile(
                              onTap: () {
                                setState(() {
                                  playlist.addToPlaylist(widget.playlistName,
                                      playlist.allSongs[i]);
                                  setState(() {
                                    Fluttertoast.showToast(
                                        msg: 'Added to playlist');
                                  });
                                  Navigator.pop(context);
                                });
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: playlist.allSongs[i].songImage,
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                playlist.allSongs[i].songName,
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              selected: true,
                              // selectedTileColor:
                              //     Colors.blueAccent.shade100.withOpacity(0.1),
                            ),
                          ),
                        )),
                  ));
        },
      ),
      backgroundColor: black,
      body: Consumer<PlaylistHelper>(
        builder: (_, playlist, __) => Column(
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
                          playlist.playlists[widget.index]['title'],
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  color: white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          '${playlist.playlists[widget.index]['songs'].length} Track${playlist.playlists[widget.index]['songs'].length > 1 ? 's' : ''}',
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
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlist.playlists[widget.index]['songs'].length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () {
                    print(widget.songs[i].songName);
                    widget.audioHelper.setInitialPlaylist(widget.songs);
                    widget.audioHelper.playIndex(i);
                  },
                  child: Dismissible(
                    key: Key(
                      Playlist.fromJson(
                              widget.playlistProvider.playlists[widget.index])
                          .songs
                          .map((e) => Songs.fromJson(e))
                          .toList()[i]
                          .songName,
                    ),
                    background: Container(color: Colors.grey),
                    onDismissed: (direction) {
                      debugPrint('DELETE');
                      Songs deleteSong = Playlist.fromJson(
                              widget.playlistProvider.playlists[widget.index])
                          .songs
                          .map((e) => Songs.fromJson(e))
                          .toList()[i];
                      String title = playlist.playlists[widget.index]['title'];
                      setState(() {
                        playlist.removeSong(title, deleteSong);
                        Fluttertoast.showToast(msg: 'Removed from playlist');
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
                                imageUrl: Playlist.fromJson(widget
                                        .playlistProvider
                                        .playlists[widget.index])
                                    .songs
                                    .map((e) => Songs.fromJson(e))
                                    .toList()[i]
                                    .songImage,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              Playlist.fromJson(widget
                                      .playlistProvider.playlists[widget.index])
                                  .songs
                                  .map((e) => Songs.fromJson(e))
                                  .toList()[i]
                                  .songName,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            selected: true,
                            // selectedTileColor:
                            //     Colors.blueAccent.shade100.withOpacity(0.1),
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
