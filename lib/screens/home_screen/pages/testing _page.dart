import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/model/playlist.dart';
import 'package:Excite/screens/home_screen/notifiers/audio_provider.dart';
import 'package:Excite/screens/home_screen/widgets/all_songs.dart';
import 'package:Excite/screens/home_screen/widgets/artists.dart';
import 'package:Excite/screens/home_screen/widgets/favourites.dart';
import 'package:Excite/screens/home_screen/widgets/playlists.dart';
import 'package:Excite/screens/home_screen/widgets/song_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/Songs.dart';
import '../api/services.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';

class TestHome extends StatefulWidget {
  @override
  State<TestHome> createState() => _TestHomeState();
}

// use GetIt or Provider rather than a global variable in a real project
late final AudioHelper _pageManager;
late final PlaylistHelper playlistProvider;

class _TestHomeState extends State<TestHome> {
  List<Songs> playlist = [];
  List<Artist> artists = [];
  bool loading = true;
  getSongs() async {
    final songs = await SongsApi.getSongs('');
    final artistss = await ArtistApi.getArtist('');

    setState(() {
      this.playlist = songs;
      print(playlist);
    });
    playlistProvider = Provider.of<PlaylistHelper>(context, listen: false);
    _pageManager = Provider.of<AudioHelper>(context, listen: false);
    _pageManager.init();
    _pageManager.setInitialPlaylist(playlist);
    setState(() {
      this.artists = artistss;
      print(artistss);
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getSongs();
    print(playlist);
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: loading == true
          ? Center(
              child: const CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ElevatedButton(
                  //     onPressed: () {
                  //       getSongs();
                  //     },
                  //     child: Text('Get em')),
                  // CurrentSongTitle(),
                  // Playlist(helper: _pageManager),
                  // AudioProgressBar(),
                  // AudioControlButtons(),

                  // PlayListWidget(
                  //   playlistProvider: playlistProvider,
                  //   audioHelper: _pageManager,
                  // ),
                  // FavouritesWidget(audioHelper: _pageManager),
                  ArtistsWidget(
                      audioHelper: _pageManager,
                      songs: playlist,
                      playlistProvider: playlistProvider,
                      artists: artists),
                  SongPlayer(
                      playlistProvider: playlistProvider,
                      audioHelper: _pageManager)
                ],
              ),
            ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(title, style: TextStyle(fontSize: 40)),
        );
      },
    );
  }
}

class Playlist extends StatelessWidget {
  const Playlist({Key? key, required this.helper}) : super(key: key);
  final AudioHelper helper;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  helper.playIndex(index);
                  //helper.shuffledList.map((e) => null)
                },
                title: Text(
                    '${_pageManager.playSongs[index].sequence[0].tag['song_name']}'),
              );
            },
          );
        },
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: _pageManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed:
              (isFirst) ? null : _pageManager.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: _pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: _pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: (isLast) ? null : _pageManager.onNextSongButtonPressed,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? Icon(Icons.shuffle)
              : Icon(Icons.shuffle, color: Colors.grey),
          onPressed: _pageManager.onShuffleButtonPressed,
        );
      },
    );
  }
}
