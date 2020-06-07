import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home.dart';
import 'welcom_page.dart';
import 'QR.dart';
import 'movie-after_QR.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      initialRoute:WelcomPage.id,
      routes: {
        MoviesApp.id: (context) => MoviesApp(),
        WelcomPage.id: (context) => WelcomPage(),
        QR.id: (context) => QR(),
        MovieItem.id: (context) => MovieItem(),
      },
    );
  }

}



