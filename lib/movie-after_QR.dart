import 'package:flutter/material.dart';
import 'package:fluttersql/moveinfo.dart';
import 'dart:ui' as ui;
import 'home.dart';
import 'movie_sql.dart';

class MovieItem extends StatelessWidget {
  final MovieInfo movie;
  final MovieBloc movieBloc = MovieBloc();
  MovieItem({this.movie});
  static const String id = 'MovieItem';
  Color mainColor = const Color(0xff3C3261);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      body: new Stack(fit: StackFit.expand, children: [
        new Image.network(
          this.movie.poster,
          fit: BoxFit.cover,
        ),
        new BackdropFilter(
          filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: new Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        new SingleChildScrollView(
          child: new Container(
            margin: const EdgeInsets.all(20.0),
            child: new Column(
              children: <Widget>[
                new Container(
                  alignment: Alignment.center,
                  child: new Container(
                    width: 400.0,
                    height: 400.0,
                  ),
                  decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(10.0),
                      image: new DecorationImage(
                          image: new NetworkImage(this.movie.poster),
                          fit: BoxFit.cover),
                      boxShadow: [
                        new BoxShadow(
                            color: Colors.black,
                            blurRadius: 20.0,
                            offset: new Offset(0.0, 10.0))
                      ]),
                ),
                new Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          child: new Text(
                            this.movie.title,
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontFamily: 'Arvo'),
                          )),
                    ],
                  ),
                ),
                new Text(this.movie.year,
                    style:
                    new TextStyle(color: Colors.white, fontFamily: 'Arvo')),
                new Text(this.movie.rating,
                    style:
                    new TextStyle(color: Colors.white, fontFamily: 'Arvo')),
                new Row(
                  children: <Widget>[
                    new Expanded(
                        flex: 2,
                        child: new Text(
                          this.movie.genre,
                          style: new TextStyle(
                              color: Colors.white,
                              fontFamily: 'Arvo',
                              fontSize: 10),
                        )),
                    new Expanded(
                      child: new Container(
                        alignment: Alignment.center,
                        child: new IconButton(
                            icon: Icon(
                              Icons.save,
                              size: 23,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              final newMovie = Movie(
                                title: this.movie.title,
                                year: this.movie.year,
                                genre: this.movie.genre,
                                rating: this.movie.rating,
                                poster: this.movie.poster,
                              );

                              movieBloc.addMovie(newMovie);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MoviesApp(
                                      )));
                            }),
                        decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.circular(10.0),
                            color: const Color(0xaa3C3261)),
                      ),
                    ),
                    new Expanded(
                        child: new Container(
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.center,
                          child: new Icon(
                            Icons.bookmark,
                            color: Colors.white,
                          ),
                          decoration: new BoxDecoration(
                              borderRadius: new BorderRadius.circular(10.0),
                              color: const Color(0xaa3C3261)),
                        )),
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
