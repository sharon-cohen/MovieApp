
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
class Movie {
  int id;
  String title;
  String year;
  String rating;
  String genre;
  String poster;

  Movie({this.id, this.rating,this.year,this.title,this.genre,this.poster});
  factory Movie.fromDatabaseJson(Map<String, dynamic> data) => Movie(
    id: data['id'],
    title: data ['title'],
    rating:data ['rating'],
    year: data['year'],
    genre:data['genre'],
    poster:data ['poster'],
  );
  Map<String, dynamic> toDatabaseJson() => {
    "id": this.id,
    "title":this.title,
    "year":this.year,
    "genre":this.genre,
    "poster":this.poster,
    "rating":this.rating,
  };
}
final moveTABLE = 'Movie';
class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();
  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }
  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "ReactiveMove.db");
    var database = await openDatabase(path,
        version: 1, onCreate: initDB, onUpgrade: onUpgrade);
    return database;
  }
  //This is optional, and only used for changing DB schema migrations
  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }
  void initDB(Database database, int version) async {
    await database.execute("CREATE TABLE $moveTABLE ("
        "id INTEGER PRIMARY KEY, "
        "title TEXT, "
        "poster TEXT, "
        "genre TEXT, "
        "year TEXT,"
        "rating TEXT  "
        ")");
  }
}

class MovieDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> getCount() async {
    //database connection
    final db = await dbProvider.database;
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM moveTABLE'));
    print(count);
    return count;
  }
  //Adds new Todo records
  Future<int> createMovie(Movie movie) async {
    final db = await dbProvider.database;
    String m_title= movie.title;
    print (m_title);
    List<String> columns;
    List<Map<String, dynamic>> res;
    res = await db.query(moveTABLE,
        columns: columns,
        where: 'title LIKE ?',
        whereArgs: ["%$m_title%"]);
    print(res);
    if(res.isEmpty){
      var result = db.insert(moveTABLE, movie.toDatabaseJson());
      return result;

    }
    else {
      throw('alredy exists');
    }

  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<Movie>> getMovies({List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(moveTABLE,
            columns: columns,
            where: 'title LIKE ?',
            whereArgs: ["%$query%"]);
    } else {
      result = await db.query(moveTABLE, columns: columns);
    }

    List<Movie> movies = result.isNotEmpty
        ? result.map((item) => Movie.fromDatabaseJson(item)).toList()
        : [];
    return movies;
  }

  //Update Todo record

  Future<int> updateMovie(Movie movie) async {
    final db = await dbProvider.database;

    var result = await db.update(moveTABLE, movie.toDatabaseJson(),
        where: "id = ?", whereArgs: [movie.id]);

    return result;
  }

  //Delete Todo records
  Future<int> deleteMovie(int id) async {
    final db = await dbProvider.database;
    var result = await db.delete(moveTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllMovies() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      moveTABLE,
    );

    return result;
  }
}
class MovieRepository {
  final movieDao = MovieDao();

  Future getAllMove({String query}) => movieDao.getMovies(query: query);
  Future<int> getCount ({String query}) => movieDao.getCount();
  Future insertMovie(Movie movie) => movieDao.createMovie(movie);

  Future updateMove(Movie movie) => movieDao.updateMovie(movie);

  Future deleteMovieById(int id) => movieDao.deleteMovie(id);

  //We are not going to use this in the demo
  Future deleteAllMovies() => movieDao.deleteAllMovies();
}

class MovieBloc {
  //Get instance of the Repository
  final _todoRepository = MovieRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _todoController = StreamController<List<Movie>>.broadcast();

  get todos => _todoController.stream;

  MovieBloc() {
    getMovie();
  }

  getMovie({String query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _todoController.sink.add(await _todoRepository.getAllMove(query: query));
  }

  addMovie(Movie movie) async {
    await _todoRepository.insertMovie(movie);
    getMovie();
  }

  updateMovie(Movie movie) async {
    await _todoRepository.updateMove(movie);
    getMovie();
  }

  deleteMovieById(int id) async {
    _todoRepository.deleteMovieById(id);
    getMovie();
  }

  Future<int> count()async{
    int num =await _todoRepository. getCount();

  }
  dispose() {
    _todoController.close();
  }
}
