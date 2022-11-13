import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab2/pages/favorites_page.dart';
import 'package:lab2/pages/login_page.dart';
import 'package:lab2/pages/song_info.dart';
import 'package:lab2/providers/song_data_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool animateGlow = false;
  String statusMsg = "Toque para escuchar";
  String imageToShow = "assets/images/waves5.jpg";

  late SnackBar snackBar;

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
                    onTap: () async {
                      Map<String, dynamic> songData;

                      uiStartScan();
                      // Do recording and get path to file
                      var recordingPath =
                          await context.read<SongDataProvider>().doRecording();
                      uiStopScan();

                      // Call API to identify song
                      if (!mounted) return;
                      var response = await context
                          .read<SongDataProvider>()
                          .identifySong(recordingPath);

                      if (!mounted) return;
                      if (response == null) {
                        // Show snackbar if API couldn't be fetched
                        showApiErrorSnackbar(context);
                      } else if (response["result"] == null) {
                        // Show snackbar if no song matched
                        showNoMatchSnackbar(context);
                      } else {
                        // Song matched. Go to song info page
                        songData = context
                            .read<SongDataProvider>()
                            .stripSongData(response["result"]);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SongInfoScreen(
                              songData: songData,
                              isFavorite: false,
                            ),
                          ),
                        );
                      }
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
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

  uiStartScan() {
    // Update UI variables
    animateGlow = true;
    statusMsg = "Escuchando...";
    imageToShow = "assets/images/waves5.gif";
    setState(() {});
  }

  uiStopScan() {
    // Update UI variables
    animateGlow = false;
    statusMsg = "Toque para escuchar";
    imageToShow = "assets/images/waves5.jpg";
    setState(() {});
  }

  void showApiErrorSnackbar(context) {
    snackBar = const SnackBar(
      content: Text("Lo sentimos, hubo un error. Intenta de nuevo."),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showNoMatchSnackbar(BuildContext context) {
    snackBar = const SnackBar(
      content: Text(
          "Lo sentimos, no encontramos esa canción.\nPuedes intentar de nuevo."),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
