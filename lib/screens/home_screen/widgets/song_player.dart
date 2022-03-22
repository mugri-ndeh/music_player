import 'dart:ui';

import 'package:Excite/screens/home_screen/notifiers/audio_provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../api/Songs.dart';
import '../api/local_storage.dart';
import '../model/playlist.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import 'custom_button.dart';

class SongPlayer extends StatefulWidget {
  const SongPlayer(
      {Key? key, required this.playlistProvider, required this.audioHelper})
      : super(key: key);
  final PlaylistHelper playlistProvider;
  final AudioHelper audioHelper;

  @override
  State<SongPlayer> createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _expanded = false;
  bool isPlaying = false;
  var _cardColor = Colors.black;
  static const _maxHeight = 350.0;
  static const _minheight = 70.0;
  double _currentHeight = _minheight;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final menuwidth = MediaQuery.of(context).size.width * 0.5;
    _buildMenuContent();
    _buildExpandedContent();

    return GestureDetector(
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
                left: lerpDouble(size.width / 2 - menuwidth / 2, 0, value),
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
    );
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
            widget.audioHelper.onPreviousSongButtonPressed();
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
          child: widget.audioHelper.currentIndex == null
              ? CircleAvatar(
                  backgroundImage: AssetImage("assets/logo/logo.png"),
                  maxRadius: 20.0,
                )
              : Consumer<AudioHelper>(
                  builder: (_, helper, __) => CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(Songs.fromJson(
                            helper.playSongs[widget.audioHelper.currentIndex!]
                                .sequence[0].tag)
                        .songImage),
                    maxRadius: 20.0,
                  ),
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
            widget.audioHelper.onNextSongButtonPressed();
          },
          size: 40,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return widget.audioHelper.currentIndex == null
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1),
                        CustomButtonWidget(
                            child: Center(
                              child: FaIcon(
                                Icons.playlist_add,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () async {
                              var length = 1;
                              await widget.playlistProvider
                                  .getPLaylists()
                                  .then((value) => length = 1);
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        backgroundColor: Colors.black,
                                        content: SizedBox(
                                          height: 300,
                                          width: 300,
                                          child: Consumer<PlaylistHelper>(
                                            builder: (_, playProvider, __) {
                                              print(playProvider
                                                  .playlists.length);
                                              var p = widget
                                                  .playlistProvider.playlists
                                                  .map((e) =>
                                                      Playlist.fromJson(e))
                                                  .toList();
                                              return p.length == 0
                                                  ? Center(
                                                      child: Text(
                                                          'No playlist available',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)))
                                                  : ListView.builder(
                                                      itemCount: p.length,
                                                      shrinkWrap: true,
                                                      itemBuilder: (c, i) =>
                                                          GestureDetector(
                                                        onTap: () {
                                                          widget
                                                              .playlistProvider
                                                              .addToPlaylist(
                                                            p[i].title,
                                                            Songs.fromJson(widget
                                                                .audioHelper
                                                                .playSongs[widget
                                                                    .audioHelper
                                                                    .currentIndex!]
                                                                .sequence[0]
                                                                .tag),
                                                          );
                                                          setState(() {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    'Added to playlist');
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: ListTile(
                                                            title: Text(
                                                              p[i].title,
                                                              style: GoogleFonts.poppins(
                                                                  textStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0)),
                                                            selected: true,
                                                            selectedTileColor:
                                                                Colors
                                                                    .blueAccent
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
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06),
                        Consumer<AudioHelper>(
                          builder: (_, helper, __) {
                            return Center(
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
                                              Songs.fromJson(helper
                                                      .playSongs[widget
                                                          .audioHelper
                                                          .currentIndex!]
                                                      .sequence[0]
                                                      .tag)
                                                  .songImage),
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
                            );
                          },
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1),
                        Consumer<FavouritesHelper>(
                          builder: (_, fav, __) => CustomButtonWidget(
                              child: Center(
                                child: FaIcon(
                                  fav.isfavourite(Songs.fromJson(widget
                                          .audioHelper
                                          .playSongs[
                                              widget.audioHelper.currentIndex!]
                                          .sequence[0]
                                          .tag))
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () async {
                                print('HEART TAPPED');
                                if (fav.isfavourite(Songs.fromJson(widget
                                    .audioHelper
                                    .playSongs[widget.audioHelper.currentIndex!]
                                    .sequence[0]
                                    .tag))) {
                                  setState(() {
                                    fav.remove(Songs.fromJson(widget
                                        .audioHelper
                                        .playSongs[
                                            widget.audioHelper.currentIndex!]
                                        .sequence[0]
                                        .tag));
                                    fav.isfavourite(Songs.fromJson(widget
                                        .audioHelper
                                        .playSongs[
                                            widget.audioHelper.currentIndex!]
                                        .sequence[0]
                                        .tag));
                                  });
                                  setState(() {
                                    Fluttertoast.showToast(
                                        msg: 'Removed from favourites');
                                  });
                                  print('SONG IS A FAVOURITE');
                                } else {
                                  print('SONG IS NOT A FAVOURITE');

                                  fav.addFavourites(Songs.fromJson(widget
                                      .audioHelper
                                      .playSongs[
                                          widget.audioHelper.currentIndex!]
                                      .sequence[0]
                                      .tag));
                                  setState(() {
                                    fav.isfavourite(Songs.fromJson(widget
                                        .audioHelper
                                        .playSongs[
                                            widget.audioHelper.currentIndex!]
                                        .sequence[0]
                                        .tag));
                                  });
                                  setState(() {
                                    Fluttertoast.showToast(
                                        msg: 'Added to favourites');
                                  });
                                  // await favouritesProvider.getFavourites();
                                }

                                //print(provider.getFavourites().length);
                              },
                              size: 50),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Consumer<AudioHelper>(
                      builder: (_, helper, __) => Text(
                        helper.currentIndex == null
                            ? ''
                            : Songs.fromJson(helper
                                    .playSongs[widget.audioHelper.currentIndex!]
                                    .sequence[0]
                                    .tag)
                                .songName,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Consumer<AudioHelper>(
                      builder: (_, helper, __) => Text(
                        Songs.fromJson(helper
                                .playSongs[widget.audioHelper.currentIndex!]
                                .sequence[0]
                                .tag)
                            .songArtist,
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withAlpha(90))),
                      ),
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
                            valueListenable:
                                widget.audioHelper.progressNotifier,
                            builder: (_, value, __) {
                              return ProgressBar(
                                progressBarColor: lightBlue,
                                baseBarColor: Colors.white.withOpacity(0.24),
                                bufferedBarColor:
                                    Colors.white.withOpacity(0.24),
                                thumbColor: white,
                                timeLabelLocation: TimeLabelLocation.sides,
                                timeLabelTextStyle: TextStyle(color: white),
                                thumbRadius: 12.0,
                                barHeight: 12.0,
                                progress: value.current,
                                buffered: value.buffered,
                                total: value.total,
                                onSeek: widget.audioHelper.seek,
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
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              widget.audioHelper.isShuffleModeEnabledNotifier,
                          builder: (context, isEnabled, child) =>
                              CustomButtonWidget(
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.random,
                                      size: 20,
                                      color: isEnabled
                                          ? white
                                          : white.withAlpha(90),
                                    ),
                                  ),
                                  onTap: () {
                                    widget.audioHelper.onShuffleButtonPressed();
                                  },
                                  size: 40),
                        ),
                        SizedBox(width: 10),
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              widget.audioHelper.isFirstSongNotifier,
                          builder: (_, isFirst, __) => CustomButtonWidget(
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.stepBackward,
                                color: isFirst
                                    ? Colors.grey.withOpacity(0.5)
                                    : white,
                              ),
                            ),
                            onTap: () {
                              (isFirst)
                                  ? null
                                  : widget.audioHelper
                                      .onPreviousSongButtonPressed();
                            },
                            size: 50,
                          ),
                        ),
                        SizedBox(width: 10),
                        ValueListenableBuilder<ButtonState>(
                          valueListenable:
                              widget.audioHelper.playButtonNotifier,
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
                                    widget.audioHelper.play();
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
                                    widget.audioHelper.pause();
                                  },
                                  size: 70,
                                );
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              widget.audioHelper.isLastSongNotifier,
                          builder: (_, isLast, __) => CustomButtonWidget(
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.stepForward,
                                color: isLast
                                    ? Colors.grey.withOpacity(0.5)
                                    : white,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                if (isLast) {
                                } else {
                                  widget.audioHelper.onNextSongButtonPressed();
                                }
                              });
                            },
                            size: 50,
                          ),
                        ),
                        SizedBox(width: 10),
                        ValueListenableBuilder<RepeatState>(
                          valueListenable:
                              widget.audioHelper.repeatButtonNotifier,
                          builder: (context, value, child) {
                            var icon;
                            var color;
                            switch (value) {
                              case RepeatState.off:
                                icon = FontAwesomeIcons.retweet;
                                color = white.withAlpha(90);
                                break;
                              case RepeatState.repeatSong:
                                icon = Icons.repeat_one;
                                color = white;
                                break;
                              case RepeatState.repeatPlaylist:
                                icon = FontAwesomeIcons.retweet;
                                color = white;
                                break;
                            }

                            return CustomButtonWidget(
                                child: Center(
                                  child: FaIcon(
                                    icon,
                                    //Icons.repeat_one_sharp,
                                    size: 20,
                                    color: color,
                                  ),
                                ),
                                onTap: () {
                                  widget.audioHelper.onRepeatButtonPressed();
                                },
                                size: 40);
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
