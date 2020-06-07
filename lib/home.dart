import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'moveinfo.dart';
import 'movie_sql.dart';
import'QR.dart' ;
import 'dart:async';
const API_KEY = 'ae3a2294';
const API_URL = "http://www.omdbapi.com/?apikey=";

class MoviesApp extends StatelessWidget {
  static const String id = 'Moviepage';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies Sample',
      home: MoviesAppHome(),
    );
  }
}

//tt8851668
//tt7569592
//tt1099212
Future<MovieInfo> getMovie(movieId) async {
  final response = await http.get('$API_URL$API_KEY&i=$movieId');

  if (response.statusCode == 200) {
    Map data = json.decode(response.body);

    if (data['Response'] == "True") {
      return MovieInfo.fromJSON(data);
    } else {
      throw Exception(data['Error']);
    }
  } else {
    throw Exception('Something went wrong !');
  }
}

class MoviesAppHome extends StatefulWidget {
  static const String id = 'MoviesAppHome';

  MoviesAppHome({Key key}) : super(key: key);
  @override
  MoviesAppHomeState createState() => MoviesAppHomeState();
}

class MoviesAppHomeState extends State<MoviesAppHome> {
  final searchTextController = new TextEditingController();
  final DismissDirection _dismissDirection = DismissDirection.vertical;
   MovieBloc movieBloc = MovieBloc();
  @override

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(child: SizedBox()),
                IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                     movieBloc.getMovie();
                    }),
                IconButton(
                  icon: Icon(Icons.camera,color: Colors.white,),
                  tooltip: 'CAMERA',
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QR(
                              )));
                    });
                  },
                ),

              ]),

              Expanded(
                child: SizedBox(
                    height: 100,
                    child :getMovesWidget(movieBloc,_dismissDirection)),
              ),
            ],
          ),
        ));
  }
}

class PaddedText extends StatelessWidget {
  final String text;

  PaddedText(this.text);

  @override
  Widget build(BuildContext contex) {
    return Padding(
        child: Text(this.text), padding: EdgeInsets.only(top: 5, bottom: 5));
  }
}
