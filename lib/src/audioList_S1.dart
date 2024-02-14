import 'dart:convert';

import 'package:audio_player_app/src/playScreen_S2.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;

/// Created by :: VISHAL KUMAR (PRP)
/// Ranchi, Jharkhand - 834001

class AudioListScreen extends StatefulWidget {
  @override
  _AudioListScreenState createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  List<String> audioList = [];

  @override
  void initState() {
    super.initState();
    _fetchAudioList();
  }

  /*
  Fetching files from Assets/Audio folder.
   */
  Future<void> _fetchAudioList() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final audioPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/audio/'))
          .toList();

      setState(() {
        audioList = audioPaths.map((path) => path.split('/').last).toList();
      });
    } catch (e) {
      print('Error on loading: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Audio List'),
      ),
      body: ListView.builder(
        itemCount: audioList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(audioList[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlayScreen(audioList: audioList, index: index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

