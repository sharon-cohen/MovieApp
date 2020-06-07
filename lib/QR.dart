
import 'package:flutter/material.dart';
import 'movie_json.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'moveinfo.dart';
import 'movie-after_QR.dart';
import 'package:flutter/scheduler.dart';
import 'movie_sql.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const API_KEY = '<YOUR KEY>';
const API_URL = "http://www.omdbapi.com/?apikey=";
const flash_on = "FLASH ON";
const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";
const back_camera = "BACK CAMERA";

class QR extends StatefulWidget {
  static const String id = 'QR';
  const QR({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => QRState();
}
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


class QRState extends State<QR> {
  bool Done_Button = false;
  var qrText = "";
  String result='';
  final searchTextController = new TextEditingController();
  final DismissDirection _dismissDirection = DismissDirection.vertical;
  final MovieBloc movieBloc = MovieBloc();
  bool exsist=false;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Widget get_id(){
    result=qrText.toString();
    if(result.length>27) {
      result = result.substring(27, 36);
      return   Text("$result", style: TextStyle(color: Colors.black,),);
    }
    return   Text("$qrText", style: TextStyle(color: Colors.black,),);

  }
  @override


  Widget build(BuildContext context) {
    get_id();
    return Scaffold(
      appBar: AppBar(
          backgroundColor:  Colors.grey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            controller?.pauseCamera();
          },
        ),
        elevation: 0.0,

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey,),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.grey,
                borderRadius: 10,
                borderLength: 130,
                borderWidth: 5,
                overlayColor: Colors.grey,
              ),
            ),

            flex: 4,
          ),
          if (result.length > 1)
            FutureBuilder<MovieInfo>(
                future: getMovie('$result'),
                builder: (context, snapshot) {
                  // ignore: unrelated_type_equality_checks
                  if (snapshot.hasData ) {
                    exsist=true;
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MovieItem(
                                movie: snapshot.data,
                              )));
                    });
                  // ignore: unrelated_type_equality_checks
                  } else if (snapshot.hasError ) {
                    exsist=true;
                    return Text("ERROR");
                  }
                  return Container();
                }),

          Expanded(
            child: Container(
              child: exsist?Text('done'):Text('exsist'),

            ),
          ),

          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  get_id(),
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          gradient: LinearGradient(colors: [
                          Colors.black12,
                            Colors.grey,
                          ])),
                      child: Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Play',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        qrText = "";
                        controller?.resumeCamera();
                        Done_Button = false;
                      });
                    },
                    child: Container(
                      width: 100.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          gradient: LinearGradient(colors: [
                            Colors.black12,
                            Colors.grey,
                          ])),
                      child: Center(
                        child: Text(
                          'Again',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Play',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            flex: 1,
          ),
        ],
      ),

    );

  }


  _isBackCamera(String current) {
    return back_camera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        controller?.pauseCamera();
        Done_Button = true;
      });
    });
  }
  @override
  void Dispose() {
    controller.dispose();
    super.dispose();
  }


}
Widget getMovesWidget(MovieBloc movieBloc ,DismissDirection _dismissDirection) {

  return StreamBuilder(
    stream: movieBloc.todos,
    builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
    if(!snapshot.hasData){

      Navigator.pushNamed(context,WelcomPage.id
      );

    }
      return getMovieCardWidget(snapshot,movieBloc,_dismissDirection,context);
    },
  );
}

Widget getMovieCardWidget(AsyncSnapshot<List<Movie>> snapshot,MovieBloc movieBloc,DismissDirection _dismissDirection,BuildContext) {
 int count=0;
  if (snapshot.hasData) {
    print("dsgs");
    return snapshot.data.length != 0
        ? ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: snapshot.data.length,
      itemBuilder: (context, itemPosition) {
        Movie movie = snapshot.data[itemPosition];
        count++;
        final Widget dismissibleCard = new Dismissible(
            background: Container(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Deleting",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              color: Colors.redAccent,
            ),
            onDismissed: (direction) {
              /*The magic
                    delete Todo item by ID whenever
                    the card is dismissed
                    */
              movieBloc.deleteMovieById(movie.id);
            },
            direction: _dismissDirection,
            key: new ObjectKey(movie),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width ,
               height: MediaQuery.of(context).size.height / 1.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(

                        blurRadius: 5.0, color: Colors.grey[400], offset: Offset(0, 3))
                  ],
                ),
                child: Stack(
                  children: <Widget>[

                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                         movie.poster,
                          fit: BoxFit.cover,

                        ),
                      ),

                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(

                        children: [
                          Container(
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(10),
                              ),
                              color: Colors.black45,
                            ),
                            child: Column(
                              children: [
                                Align(
                                  child: Text(
                                    // "${movieList[id]['title']}",
                                    movie.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                               SizedBox(height: 50,),
                              ],
                            ),
                          ),
                          SizedBox(height: 310,),
                          Container(
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(10),
                              ),
                              color: Colors.black45,
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                    child: Text(
                                     " $count /${snapshot.data.length}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:  10,
                                      ),
                                      softWrap: true,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    // "${movieList[id]['title']}",
                                    movie.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:  13,
                                    ),
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            Divider(
                                  color: Colors.white

                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'year ',
                                      style: TextStyle(color: Colors.blue), /*defining default style is optional */
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: movie.year, style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'genre ',
                                      style: TextStyle(color: Colors.blue), /*defining default style is optional */
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: movie.genre, style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'rating ',
                                      style: TextStyle(color: Colors.blue), /*defining default style is optional */
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: movie.rating, style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),);
        return dismissibleCard;
      },
    )
        : Container(
        child: Center(

          child: noMovieMessageWidget(),
        ));
  } else {

  }

 return Center(
      /*since most of our I/O operations are done
        outside the main thread asynchronously
        we may want to display a loading indicator
        to let the use know the app is currently
        processing*/

    );
  }


Widget loadingData(MovieBloc movieBloc) {
  //pull todos again
  movieBloc.getMovie();
  return Container(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Text("Loading...",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))
        ],
      ),
    ),
  );
}

Widget noMovieMessageWidget() {
  return Container(
    child: Text(
      "Start adding Todo...",
      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
    ),
  );
}

dispose(MovieBloc movieBloc) {
  /*close the stream in order
    to avoid memory leaks
    */
  movieBloc.dispose();
}
_isFlashOn(String current) {
  return flash_on == current;
}