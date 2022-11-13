import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:lab2/items/favorite.dart';

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
          child: FirestoreQueryBuilder(
              query: FirebaseFirestore.instance
                  .collection("song_favorites")
                  .where("user",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid),
              builder: ((context, snapshot, child) {
                return ListView.builder(
                    itemCount: snapshot.docs.length,
                    itemBuilder: ((context, index) {
                      return Favorite(songData: snapshot.docs[index].data());
                    }));
              }))),
    );
  }
}
