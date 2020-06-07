import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
Future<List<Movie_J>> fetchPhotos(http.Client client) async {
  final response =
  await client.get('https://api.androidhive.info/json/movies.json');


  return compute(parseMovies, response.body);
}


List<Movie_J> parseMovies(String responseBody) {
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




