/// Created by :: VISHAL KUMAR (PRP)
/// Ranchi, Jharkhand - 834001

// Class name "MusicEvent" is because AudioEvent class used by AudioPlayer

abstract class MusicEvent  {
  const MusicEvent();

  @override
  List<Object> get props => [];
}

class PlayMusicEvent extends MusicEvent {
  String source;
  PlayMusicEvent({required this.source});
}

class PauseMusicEvent extends MusicEvent {}

class StopMusicEvent extends MusicEvent {}

class ChangeMusicEvent extends MusicEvent {
  String source;
  ChangeMusicEvent({required this.source});
}