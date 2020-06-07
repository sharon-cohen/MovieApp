
import 'package:getflutter/getflutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'movie_sql.dart';
import 'movie_json.dart';
import 'home.dart';
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
              ? MovieList(photos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MovieList extends StatefulWidget {
  final List<Movie_J> photos;

  MovieList({Key key, this.photos}) : super(key: key);
  final MovieBloc movieBloc = MovieBloc();
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  @override
  Widget build(BuildContext context) {
    List<Widget> mov = new List.generate(widget.photos.length, (i)=> CustomCard(movie: widget.photos[i],movieBloc: widget.movieBloc,));
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
                child: new ListView(
                  children: mov,
                )
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
                child:  FlatButton(
                  child: const Text('Submit', style: TextStyle(color: Colors.black12)),
                  onPressed: () {
                    Navigator.pushNamed(context,MoviesApp.id);
                  },
                ),
            ),
          ),
        ],
      ),
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
          Button(movie: movie,movieBloc: movieBloc,),
        ],
      ),
    );

  }
}

class Button extends StatefulWidget {
  Button({this.movie,this.movieBloc});
  final Movie_J movie;
  final MovieBloc movieBloc;
  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  Color _iconColor = Colors.blue;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        final newMovie = Movie(
          title: widget.movie.title,
          year: widget.movie.year.toString(),
          genre: widget.movie.genre.toString(),
          rating: widget.movie.rating.toString(),
          poster: widget.movie.image,

        );

        widget.movieBloc.getMovie();
        widget.movieBloc.addMovie(newMovie);
        setState(() {
          _iconColor = Colors.red;
        });
      },
      child:Icon( Icons.save,
        color: _iconColor,
        size: 30.0,)
    );
  }
}
