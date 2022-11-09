import 'package:flutter/material.dart';
import 'package:lab2/pages/home_page.dart';
import 'package:lab2/providers/song_data_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChangeNotifierProvider(
      create: (context) => SongDataProvider(),
      child: const MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindTrackApp',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
