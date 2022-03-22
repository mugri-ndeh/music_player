import 'package:Excite/constants/constants.dart';
import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/widgets/song_player.dart';
import 'package:flutter/material.dart';

import '../notifiers/audio_provider.dart';

class SongList extends StatefulWidget {
  SongList(
      {Key? key,
      required this.child,
      required this.playlistProvider,
      required this.audioHelper})
      : super(key: key);
  final Widget child;
  final PlaylistHelper playlistProvider;
  final AudioHelper audioHelper;

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  @override
  void initState() {
    // TODO: implement initState
    //widget.audioHelper.setInitialPlaylist(widget.playlistProvider.playlists)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          SongPlayer(
              playlistProvider: widget.playlistProvider,
              audioHelper: widget.audioHelper)
        ],
      ),
    );
  }
}
