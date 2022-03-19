/* server.dart */

/* the simplest possible web server */

import 'dart:io' show InternetAddress;
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart' show Request, Response;
import 'package:shelf/shelf_io.dart' show serve;
import 'package:shelf_router/shelf_router.dart' show Router;
// import 'package:mysql_client/mysql_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future main() async {
  final connection = await MySqlConnection.connect(ConnectionSettings(
    host: "localhost",
    port: 3307,
    user: "root",
    password: "fatoki@dimeji1A",
    db: "faqs",
  ));

  Router router = Router();
// Feature 2 The home screen should display a list of the questions that users have asked.
  router.get('/questions', (Request request) async {
    var results =
        await connection.query("SELECT title, summary, names From questions");
    var myList = results.toList();
    print(myList);
    return await Response.ok(jsonEncode(myList));
  });

// Feature 3 clicking on title and displayin all contents
  router.get('/questions', (Request request) async {
    var results = await connection.query(
        "SELECT title, summary, description, user_id ,names From questions");
    var myList = results.toList();
    print(myList);
    return await Response.ok(jsonEncode(myList));
  });

  // Feature 1

  // router.get('/questions', (Request request) async {
  //   var results = await connection.query("SELECT * FROM questions");
  //   var row;
  //   var myList = <Map>[];
  //   for (row in results) {
  //     myList.add({
  //       "question_id": row[0],
  //       "title": row[1],
  //       "summary": row[2],
  //       "description": row[3],
  //       "user_id": row[4],
  //       "date": DateTime.parse(row['date']),
  //       "created_at": DateTime.parse(row['created_at'])
  //     });
  //     print(myList);
  //   }

  //   Map<String, dynamic> output = {
  //     "status": "success",
  //     "myList": myList,
  //     "message": "Success, Gotten Details"
  //   };
  //   String json = jsonEncode(output);
  //   print(json);

  //   return Response.ok(json,
  //       headers: {'Content-type': 'application/json'},
  //       encoding: convert.Encoding.getByName('utf-8'));
  //   // return Response.ok(jsonEncode(myList));
  // });

  // await connection.close();

  final server = await serve(
    router,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

// Response request(Request request) => Response.ok('result');
