import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';

/// Created by :: VISHAL KUMAR (PRP)
/// Ranchi, Jharkhand - 834001

class PlayScreen extends StatelessWidget {
  final List<String> audioList;
  final int index;

  const PlayScreen({super.key, required this.audioList, required this.index, });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioBloc(),
      child: PlayScreenContent(audioList: audioList, index: index,),
    );
  }
}

class PlayScreenContent extends StatefulWidget {
  final List<String> audioList;
  final int index;

  const PlayScreenContent({super.key, required this.audioList, required this.index, });

  @override
  State<PlayScreenContent> createState() => _PlayScreenContentState();
}

class _PlayScreenContentState extends State<PlayScreenContent> {
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';


  AudioPlayer _audioPlayer = AudioPlayer();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;


    return PopScope(
      onPopInvoked:(t){
        context.read<AudioBloc>().add(StopMusicEvent());
      },
      child: BlocProvider(
        create: (context) => AudioBloc(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.audioList[currentIndex]),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                context.read<AudioBloc>().add(StopMusicEvent());
                Navigator.of(context).pop();
              },
            ),
          ),
          body: BlocConsumer<AudioBloc, AudioState>(
            listener: (context,state) {
              print(state);

              if(state is MusicPlayingState){
                _audioPlayer = state.audioPlayer;
                state.audioPlayer.getDuration().then(
                      (value) => setState(() {
                    _duration = value;
                  }),
                );
                state.audioPlayer.getCurrentPosition().then(
                      (value) => setState(() {
                    _position = value;
                  }),
                );
                _initStreams(state.audioPlayer);
              }

              if(state is MusicStoppedState){
                _position = Duration.zero; // PRP: Reset seek
              }
            },
            builder: (context,state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    Image.asset("assets/image/music_record.jpeg"),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              key: const Key('previous_button'),
                              onPressed: (){

                                if( 0 <  currentIndex){
                                  setState(() {
                                    currentIndex --;
                                  });
                                  // context.read<AudioBloc>().add(StopMusicEvent());
                                  context.read<AudioBloc>().add(ChangeMusicEvent(source: widget.audioList[currentIndex]));

                                }
                                },
                              iconSize: 48.0,
                              icon: const Icon(Icons.skip_previous),
                              color: color,
                            ),

                            if(state is! MusicPlayingState)...[
                              IconButton(
                                key: const Key('play_button'),
                                onPressed: (){
                                  context.read<AudioBloc>().add(PlayMusicEvent(source: widget.audioList[currentIndex]));
                                },
                                iconSize: 48.0,
                                icon: const Icon(Icons.play_arrow),
                                color: color,
                              ),
                            ]else...[
                              IconButton(
                                key: const Key('pause_button'),
                                onPressed: (){
                                  context.read<AudioBloc>().add(PauseMusicEvent());
                                },
                                iconSize: 48.0,
                                icon: const Icon(Icons.pause),
                                color: color,
                              ),
                            ],

                            IconButton(
                              key: const Key('stop_button'),
                              onPressed: (){
                                context.read<AudioBloc>().add(StopMusicEvent());
                              },
                              iconSize: 48.0,
                              icon: const Icon(Icons.stop),
                              color: color,
                            ),

                            IconButton(
                              key: const Key('next_button'),
                              onPressed: (){
                                if(widget.audioList.length-1 >  currentIndex){
                                  setState(() {
                                    currentIndex ++;
                                  });
                                  // context.read<AudioBloc>().add(StopMusicEvent());
                                  context.read<AudioBloc>().add(ChangeMusicEvent(source: widget.audioList[currentIndex]));

                                }
                               },
                              iconSize: 48.0,
                              icon: const Icon(Icons.skip_next),
                              color: color,
                            ),
                          ],
                        ),

                        /*Package pre-written code*/
                        Slider(
                          onChanged: (value) {
                            final duration = _duration;
                            if (duration == null) {
                              return;
                            }
                            final position = value * duration.inMilliseconds;
                            _audioPlayer.seek(Duration(milliseconds: position.round()));
                          },
                          value: (_position != null &&
                              _duration != null &&
                              _position!.inMilliseconds > 0 &&
                              _position!.inMilliseconds < _duration!.inMilliseconds)
                              ? _position!.inMilliseconds / _duration!.inMilliseconds
                              : 0.0,
                        ),
                        Text(
                          _position != null
                              ? '$_positionText / $_durationText'
                              : _duration != null
                              ? _durationText
                              : '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),

                    Text('Now Playing: ${widget.audioList[currentIndex]}'),
                    const SizedBox(height: 20),

                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  /*Package pre-written code block*/
  void _initStreams(AudioPlayer player) {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
          (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
          setState(() {
          });
        });
  }

}
