import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:lab2/pages/favorites_page.dart';
import 'package:lab2/pages/login_page.dart';
import 'package:lab2/pages/song_info.dart';
import 'package:lab2/providers/song_data_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool animateGlow = false;
  String statusMsg = "Toque para escuchar";
  String imageToShow = "assets/images/waves5.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(5, 80, 5, 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(statusMsg,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18)),
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 100, 0, 40),
              child: AvatarGlow(
                  endRadius: 200,
                  animate: animateGlow,
                  child: GestureDetector(
                    onTap: () {
                      SnackBar snackBar;
                      Map<String, dynamic> songData;

                      doRecording().then((recordingPath) => {
                            // Call API to identify song
                            context
                                .read<SongDataProvider>()
                                .identifySong(recordingPath)
                                .then((response) => {
                                      if (response == null)
                                        {
                                          // Show snackbar if API couldn't be fetched
                                          log("API failed"),
                                          snackBar = const SnackBar(
                                            content: Text(
                                                "Lo sentimos, hubo un error. Intenta de nuevo."),
                                          ),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar)
                                        }
                                      else
                                        {
                                          if (response["result"] == null)
                                            {
                                              // Show snackbar if no song matched
                                              log("No song matched"),
                                              snackBar = const SnackBar(
                                                content: Text(
                                                    "Lo sentimos, no encontramos esa canción.\nPuedes intentar de nuevo."),
                                              ),
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar)
                                            }
                                          else
                                            {
                                              songData = stripSongData(
                                                  response["result"]),
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SongInfoScreen(
                                                    songData: songData,
                                                    isFavorite: false,
                                                  ),
                                                ),
                                              ),
                                            }
                                        }
                                    })
                          });
                    },
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage(imageToShow),
                      backgroundColor: Colors.white,
                    ),
                  )),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                backgroundColor: Colors.white, // <-- Button color
                foregroundColor: Colors.red, // <-- Splash color
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
              child: Icon(
                size: 30,
                Icons.favorite,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                backgroundColor: Colors.white, // <-- Button color
                foregroundColor: Colors.red, // <-- Splash color
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: Icon(
                size: 30,
                Icons.logout,
                color: Colors.blueGrey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  stripSongData(response) {
    var allSongData = response;

    // Song matched, send song data to SongInfoScreen
    log("Song matched, sending to songInfo");
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

  Future<String> doRecording() async {
    log("Tapped big button");

    // Update UI variables
    animateGlow = true;
    statusMsg = "Escuchando...";
    imageToShow = "assets/images/waves5.gif";
    setState(() {});

    // Get temp folder route
    Directory appTempDir = await getTemporaryDirectory();
    log(appTempDir.path);

    // Record audio
    final myRecorder = Record();
    String? pathToRecording = "";

    // Check for recording permission
    if (await myRecorder.hasPermission()) {
      // Start recording
      myRecorder.start(path: "${appTempDir.path}/song_to_identify.m4a");
      log("Started recording");
    }

    // Wait 4 seconds to stop recording
    await Future.delayed(const Duration(seconds: 4));
    pathToRecording = await myRecorder.stop();
    log("Stopped recording");
    log("pathToRecording:");
    log(pathToRecording!);

    // Update UI variables
    animateGlow = false;
    statusMsg = "Toque para escuchar";
    imageToShow = "assets/images/waves5.jpg";
    setState(() {});

    return pathToRecording;
  }
}
