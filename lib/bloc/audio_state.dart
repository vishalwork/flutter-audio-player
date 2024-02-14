import 'package:audioplayers/audioplayers.dart';

/// Created by :: VISHAL KUMAR (PRP)
/// Ranchi, Jharkhand - 834001

abstract class AudioState {
  const AudioState();

  @override
  List<Object> get props => [];
}

class MusicInitialState extends AudioState {}

class MusicPlayingState extends AudioState {
  AudioPlayer audioPlayer;
  MusicPlayingState({required this.audioPlayer});
}

class MusicPausedState extends AudioState {}

class MusicStoppedState extends AudioState {}

class MusicChangedState extends AudioState {}