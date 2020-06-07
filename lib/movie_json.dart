import 'dart:async';
import 'dart:convert';
import 'package:getflutter/getflutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'movie_sql.dart';
import 'home.dart';
Future<List<Movie_J>> fetchPhotos(http.Client client) async {
  final response =
  await client.get('https://api.androidhive.info/json/movies.json');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePhotos, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Movie_J> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Movie_J>((json) => Movie_J.fromJson(json)).toList();
}

class Movie_J {
  final String title;
  final String image;
  final dynamic year;
  final dynamic rating;
  final List<dynamic> genre;
  Movie_J({this.image, this.title, this.year, this.rating, this.genre});

  factory Movie_J.fromJson(Map<String, dynamic> json) {
    return Movie_J(
      image: json['image'] as String,
      title: json['title'] as String,
      year: json['releaseYear'].toDouble() as double,
      rating: json['rating'].toDouble() as double,
      genre: json['genre'],
    );
  }
}


class WelcomPage extends StatelessWidget {
  static const String id = 'WelcomPage';

  WelcomPage ({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<Movie_J>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? PhotosList(photos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PhotosList extends StatelessWidget {
  final List<Movie_J> photos;

  PhotosList({Key key, this.photos}) : super(key: key);
  final MovieBloc movieBloc = MovieBloc();
  @override
  Widget build(BuildContext context) {
    List<Widget> poto = new List.generate(photos.length, (i)=> CustomCard(movie: this.photos[i],movieBloc: movieBloc,));
    return Container(
        child: new ListView(
          children: poto,
        )

    );
  }
}
class CustomCard extends StatelessWidget {
  CustomCard({this.movie,this.movieBloc});
  final Movie_J movie;
  final MovieBloc movieBloc;
  @override
  Widget build(BuildContext context) {
    return  GFCard(
      boxFit: BoxFit.cover,

      title: GFListTile(
        avatar: GFAvatar(
          backgroundImage:NetworkImage(this.movie.image),
          shape: GFAvatarShape.square,

        ),
        title: Text(this.movie.title),
        subTitle: Text(this.movie.year.toString()+this.movie.rating.toString()),
      ),
      content: Text(this.movie.genre.toString()),
      buttonBar: GFButtonBar(

        children: <Widget>[
          GFButton(
            onPressed: () {
              final newMovie = Movie(
                title: this.movie.title,
                year: this.movie.year.toString(),
                genre: this.movie.genre.toString(),
                rating: this.movie.rating.toString(),
                poster: this.movie.image,
              );
              Navigator.pushNamed(context,MoviesApp.id
              );
              movieBloc.addMovie(newMovie);

            },
            text: 'save',
          )
        ],
      ),
    );

  }
}


class alin_text extends StatelessWidget {
  final String text;
  alin_text({this.text});
  @override
  Widget build(BuildContext context) {
    return Align(
      child: Text(
        // "${movieList[id]['title']}",
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
