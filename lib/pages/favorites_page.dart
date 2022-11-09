import 'package:flutter/material.dart';
import 'package:lab2/items/favorite.dart';
import 'package:lab2/providers/song_data_provider.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: ListView.builder(
          itemCount: context.watch<SongDataProvider>().getFavoritesList.length,
          itemBuilder: (BuildContext context, int index) {
            return Favorite(
              songData:
                  context.read<SongDataProvider>().getFavoritesList[index],
            );
          },
        ),
      ),
    );
  }
}
