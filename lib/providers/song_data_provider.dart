import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../credentials/credentials.dart' as credentials;

class SongDataProvider with ChangeNotifier {
  final List<dynamic> _favoritesList = [];

  String statusMsg = "Toque para escuchar";
  bool animate = false;

  List<dynamic> get getFavoritesList => _favoritesList;

  void addFavorite(dynamic songData) async {
    _favoritesList.add(songData);
    log(_favoritesList.toString());
    log(_favoritesList.length.toString());
    notifyListeners();
  }

  void removeFavorite() async {
    _favoritesList.removeLast();
    log(_favoritesList.toString());
    log(_favoritesList.length.toString());
    notifyListeners();
  }

  Future<dynamic> identifySong(String recordingPath) async {
    try {
      log("Started identifySong method");

      // Convert audio to binary data
      File audioFile = File(recordingPath);
      Uint8List fileBytes = audioFile.readAsBytesSync();
      String fileBase64 = base64Encode(fileBytes);
      log("Converted audio to base64");

      // Send file to API
      log("Attempting to send file to API");
      Uri url = Uri.parse("https://api.audd.io/");
      var response = await http.post(url, body: {
        'api_token': credentials.apiKey,
        'return': 'apple_music,spotify,deezer',
        'audio': fileBase64,
        'method': 'recognize',
      });

      log("Response arrived");

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
}
