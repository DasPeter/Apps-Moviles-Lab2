import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../utils/secrets.dart' as secrets;

class SongDataProvider with ChangeNotifier {
  final List<dynamic> _favoritesList = [];

  String statusMsg = "Toque para escuchar";
  bool animate = false;

  List<dynamic> get getFavoritesList => _favoritesList;

  Future<bool> isSongFavorite(dynamic songData) async {
    // Check is song already favorite in user database info
    bool isFavorite = await FirebaseFirestore.instance
        .collection('song_favorites')
        .where("user", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("title", isEqualTo: songData["title"])
        .where("artist", isEqualTo: songData["artist"])
        .where("album", isEqualTo: songData["album"])
        .where("release_date", isEqualTo: songData["release_date"])
        .get()
        .then((qs) {
      // ignore: prefer_is_empty
      if (qs.docs.length == 0) {
        // Song not in favorites list

        return false;
      } else {
        // Song  in favorites list

        return true;
      }
    });
    return isFavorite;
  }

  void addFavorite(songData) async {
    await FirebaseFirestore.instance.collection('song_favorites').add(songData);
  }

  void removeFavorite(songData) async {
    await FirebaseFirestore.instance
        .collection('song_favorites')
        .where("user", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("title", isEqualTo: songData["title"])
        .where("artist", isEqualTo: songData["artist"])
        .where("album", isEqualTo: songData["album"])
        .where("release_date", isEqualTo: songData["release_date"])
        .get()
        .then((qs) {
      for (var document in qs.docs) {
        document.reference.delete();
      }
    });
  }

  Future<String> doRecording() async {
    // Get temp folder route
    Directory appTempDir = await getTemporaryDirectory();

    // Record audio
    final myRecorder = Record();
    String? pathToRecording = "";

    // Check for recording permission
    if (await myRecorder.hasPermission()) {
      // Start recording
      myRecorder.start(path: "${appTempDir.path}/song_to_identify.m4a");
    }

    // Wait 4 seconds to stop recording
    await Future.delayed(const Duration(seconds: 4));
    pathToRecording = await myRecorder.stop();

    return pathToRecording!;
  }

  Future<dynamic> identifySong(String recordingPath) async {
    try {
      // Convert audio to binary data
      File audioFile = File(recordingPath);
      Uint8List fileBytes = audioFile.readAsBytesSync();
      String fileBase64 = base64Encode(fileBytes);

      // Send file to API

      Uri url = Uri.parse("https://api.audd.io/");
      var response = await http.post(url, body: {
        'api_token': secrets.auddApiKey,
        'return': 'apple_music,spotify,deezer',
        'audio': fileBase64,
        'method': 'recognize',
      });

      // Handle response
      var res = jsonDecode(response.body);
      if (res["status"] == "success") {
        return res;
      } else if (res["status"] == "error") {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Map<String, dynamic> stripSongData(response) {
    var allSongData = response;

    // Song matched, send song data to SongInfoScreen

    // Strip unnecessary data for Firebase collection
    Map<String, dynamic> songData = {
      "user": FirebaseAuth.instance.currentUser!.uid,
      "title": allSongData["title"],
      "artist": allSongData["artist"],
      "album": allSongData["album"],
      "release_date": allSongData["release_date"],
      "image": allSongData["spotify"]["album"]["images"][0]["url"],
      "spotify_link": allSongData["spotify"]["external_urls"]["spotify"],
      "deezer_link": allSongData["deezer"]["link"],
      "apple_link": allSongData["apple_music"]["url"],
      "generic_link": allSongData["song_link"],
    };
    return songData;
  }
}
