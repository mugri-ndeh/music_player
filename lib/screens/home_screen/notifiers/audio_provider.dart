import 'package:Excite/screens/home_screen/api/Songs.dart';
import 'package:Excite/screens/home_screen/notifiers/progress_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

import 'play_button_notifier.dart';
import 'repeat_button_notifier.dart';

class AudioHelper with ChangeNotifier {
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentSongSrcNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  List<Songs> currentSongs = [];
  List<AudioSource> playSongs = [];
  List<IndexedAudioSource> currentPlaylist = [];
  int? currentIndex;

  AudioHelper() {
    init();
  }
  getIndex() {
    _audioPlayer.currentIndexStream.listen((event) async {
      currentIndex = event;
    });
    notifyListeners();
    print('INDEX IS');
    print(currentIndex);
    return currentIndex;
  }

  setIndex(int index) {
    _audioPlayer.sequenceStateStream.listen((event) {
      currentIndex = event!.currentIndex;
    });
  }

  void init() async {
    _audioPlayer = AudioPlayer();
    // getIndex();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
  }

  Future setInitialPlaylist(List<Songs> songs) async {
    playSongs = [];
    currentSongs = songs;
    for (int i = 0; i < songs.length; i++) {
      var song = Uri.parse(songs[i].songSrc);
      var newThing = AudioSource.uri(song, tag: songs[i].toJson());
      print(newThing);
      playSongs.add(newThing);
    }
    _playlist = ConcatenatingAudioSource(children: playSongs);
    return _audioPlayer.setAudioSource(_playlist);
  }

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

  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // update current song title
      final currentItem = sequenceState.currentSource;
      final title = currentItem?.tag as Map<String, dynamic>?;
      currentSongTitleNotifier.value = title!['song_name'] ?? '';
      currentSongSrcNotifier.value = title['song_src'] ?? '';

      // update playlist
      final playlist = sequenceState.effectiveSequence;

      currentPlaylist = playlist;
      final titles =
          playlist.map((item) => item.tag['song_name'] as String).toList();
      playlistNotifier.value = titles;

      // update shuffle mode
      isShuffleModeEnabledNotifier.value = sequenceState.shuffleModeEnabled;

      // update previous and next buttons
      if (playlist.isEmpty || currentItem == null) {
        isFirstSongNotifier.value = true;
        isLastSongNotifier.value = true;
      } else {
        isFirstSongNotifier.value = playlist.first == currentItem;
        isLastSongNotifier.value = playlist.last == currentItem;
      }
    });
  }

  void playIndex(int position) async {
    await _audioPlayer.seek(null, index: position);
    getIndex();
    play();
    notifyListeners();
    // _audioPlayer.
  }

  void play() async {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
    notifyListeners();
  }

  void disposee() {
    _audioPlayer.dispose();
  }

  void onRepeatButtonPressed() {
    repeatButtonNotifier.nextState();
    switch (repeatButtonNotifier.value) {
      case RepeatState.off:
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatState.repeatSong:
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  void onPreviousSongButtonPressed() {
    _audioPlayer.seekToPrevious();
    getIndex();

    notifyListeners();
  }

  void onNextSongButtonPressed() {
    _audioPlayer.seekToNext();
    getIndex();
  }

  void onShuffleButtonPressed() async {
    final enable = !_audioPlayer.shuffleModeEnabled;
    if (enable) {
      await _audioPlayer.shuffle();
    }
    await _audioPlayer.setShuffleModeEnabled(enable);
  }
}
