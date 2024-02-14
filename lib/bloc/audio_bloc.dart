import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio_event.dart';
import 'audio_state.dart';

/// Created by :: VISHAL KUMAR (PRP)
/// Ranchi, Jharkhand - 834001

class AudioBloc extends Bloc<MusicEvent, AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioBloc() : super(MusicInitialState());

  @override
  Stream<AudioState> mapEventToState(MusicEvent event) async* {
    if (event is PlayMusicEvent) {
      _audioPlayer.play(AssetSource("audio/${event.source}"));
      yield MusicPlayingState(audioPlayer: _audioPlayer);
    } else if (event is PauseMusicEvent) {
      _audioPlayer.pause();
      yield MusicPausedState();
    } else if (event is StopMusicEvent) {
      _audioPlayer.stop();
      yield MusicStoppedState();
    } else if (event is ChangeMusicEvent) {
      /* First Running player will stop and after that a new audio will assign */
      _audioPlayer.stop().then((value) => _audioPlayer.play(AssetSource("audio/${event.source}")));
      // _audioPlayer.play(AssetSource("audio/${event.source}"));

      yield MusicPlayingState(audioPlayer: _audioPlayer);
    }
  }
}