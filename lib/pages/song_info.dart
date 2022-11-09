// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/song_data_provider.dart';

class SongInfoScreen extends StatelessWidget {
  final dynamic songData;
  bool isFavorite;
  String placeholderAlbum =
      "https://image.radioking.io/radios/460007/cover/custom/a2daa88f-05b2-408c-a554-57701ad526dc.png";

  SongInfoScreen({super.key, required this.songData, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song info'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: (() {
                if (!isFavorite) {
                  context.read<SongDataProvider>().addFavorite(songData);
                  isFavorite = true;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("¡Canción agregada a favoritos!"),
                  ));
                } else {
                  showRemoveFavoriteWarning(context);
                }
              }),
              child: const Icon(Icons.favorite),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Image.network(
                  "${songData.containsKey("spotify") ? songData["spotify"]["album"]["images"][0]["url"] : placeholderAlbum}"),
              Container(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${songData["title"]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        )),
                    Text("${songData["album"]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        )),
                    Text("${songData["artist"]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        )),
                    Text("${songData["release_date"]}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Divider(),
              ),
              Column(
                children: [
                  const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text("Abrir con:")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.spotify, size: 40),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await launch(songData.containsKey("spotify")
                              ? songData["spotify"]["external_urls"]["spotify"]
                              : songData["song_link"]);
                        },
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.podcast, size: 40),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await launch(songData.containsKey("deezer")
                              ? songData["deezer"]["link"]
                              : songData["song_link"]);
                        },
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.apple, size: 40),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await launch(songData.containsKey("apple_music")
                              ? songData["apple_music"]["url"]
                              : songData["song_link"]);
                        },
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void showRemoveFavoriteWarning(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("¿Eliminar de favoritos?"),
              content: const Text(
                  "La canción será eliminada de tus favoritos. ¿Quieres continuar?"),
              actions: [
                TextButton(
                    onPressed: () {
                      log("Clicked cancel");
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar")),
                TextButton(
                    onPressed: () {
                      log("Clicked remove favorite");
                      Navigator.pop(context);
                      context.read<SongDataProvider>().removeFavorite();
                      isFavorite = false;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Canción eliminada de favoritos."),
                      ));
                      log("Removed favorite");
                    },
                    child: const Text("Eliminar")),
              ],
            ));
  }
}
