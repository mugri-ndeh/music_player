import 'dart:async';
import 'dart:ui';
import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/api/services.dart';
import 'package:Excite/screens/home_screen/notifiers/play_button_notifier.dart';
import 'package:Excite/screens/home_screen/notifiers/progress_notifier.dart';
import 'package:Excite/screens/home_screen/widgets/custom_button.dart';
import 'package:Excite/screens/home_screen/widgets/search_widget.dart';
import 'package:Excite/screens/home_screen/widgets/shimmer_widget.dart';
import 'package:Excite/screens/profile_screen/profile.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Excite/constants/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';

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
  List<Songs> songs = [];
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

  // Create an animation with value of type "double

  @override
  void initState() {
    init();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
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
    _listenForChangesInBufferedPosition();
    _listenForChangesInPlayerPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInPlayerState();
    final songs = await SongsApi.getSongs(query);
    setState(() {
      isLoading = false;
    });
    setState(() => this.songs = songs);
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
                    buildSearch(),
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
                                      FontAwesomeIcons.podcast,
                                      size: 16,
                                      color: white,
                                    ),
                                  ),
                                  onTap: () {},
                                  size: 40),
                              Text(
                                "Artists",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: white,
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
                                      color: white,
                                    ),
                                  ),
                                  onTap: () {},
                                  size: 40),
                              Text(
                                "Favourites",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: white,
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
                                      color: white,
                                    ),
                                  ),
                                  onTap: () {},
                                  size: 40),
                              Text(
                                "Playlists",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: white,
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
                        padding:
                            EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                        itemBuilder: (context, index) {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: buildShimmer(),
                            ),
                          ));
                        })
                    : ListView.builder(
                        padding:
                            EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                        itemCount: songs.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  CurrentSong.currentSong = index;
                                });
                                _audioPlayer.setUrl(songs[index].songSrc);
                                _audioPlayer.play();
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
                                            color: white),
                                      ),
                                      subtitle: Text(
                                        songs[index].songName,
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                color: white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0)),
                                      selected: true,
                                      selectedTileColor: Colors
                                          .blueAccent.shade100
                                          .withOpacity(0.1),
                                    ),
                                  )),
                            ),
                          );
                        },
                      ),
              ),
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
                        onTap: () {},
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
                                    songs[CurrentSong.currentSong!].songImage,
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
                            FontAwesomeIcons.heart,
                            size: 20,
                            color: white,
                          ),
                        ),
                        onTap: () {},
                        size: 50),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  songs[CurrentSong.currentSong!].songName,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  songs[CurrentSong.currentSong!].songArtist,
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
                                songs[CurrentSong.currentSong!].songSrc);
                            _audioPlayer.play();
                          }
                          ;
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
                          if (CurrentSong.currentSong != songs.length - 1) {
                            CurrentSong.currentSong =
                                CurrentSong.currentSong! + 1;
                            _audioPlayer.stop();
                            _audioPlayer.setUrl(
                                songs[CurrentSong.currentSong!].songSrc);
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
              ;
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
                      songs[CurrentSong.currentSong!].songImage),
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

  Future searchBook(String query) async => debounce(() async {
        final songs = await SongsApi.getSongs(query);
        if (!mounted) return;
        setState(() {
          this.query = query;
          this.songs = songs;
        });
      });

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
          if (CurrentSong.currentSong != songs.length - 1) {
            CurrentSong.currentSong = CurrentSong.currentSong! + 1;
            _audioPlayer.stop();
            _audioPlayer.setUrl(songs[CurrentSong.currentSong!].songSrc);
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
}

class CurrentSong with ChangeNotifier {
  static int? currentSong;
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