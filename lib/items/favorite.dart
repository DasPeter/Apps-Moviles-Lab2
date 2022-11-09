import 'package:flutter/material.dart';

import '../pages/song_info.dart';

class Favorite extends StatelessWidget {
  final dynamic songData;
  final String placeholderAlbum =
      "https://image.radioking.io/radios/460007/cover/custom/a2daa88f-05b2-408c-a554-57701ad526dc.png";

  const Favorite({super.key, this.songData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(),
      child: MaterialButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  SongInfoScreen(songData: songData, isFavorite: false),
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                  "${songData.containsKey("spotify") ? songData["spotify"]["album"]["images"][0]["url"] : placeholderAlbum}"),
            ),
            const Positioned(
              top: 10,
              left: 10,
              child: Icon(
                Icons.favorite,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(150, 33, 149, 243),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                child: Column(
                  children: [
                    Text(songData["title"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        )),
                    Text(songData["artist"],
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
