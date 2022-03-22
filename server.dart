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
//Feature 2 The home screen should display a list of the questions that users have asked.
  router.get('/questions', (Request request) async {
    var results =
        await connection.query("SELECT title, summary, names From questions");
    var myList = results.toList();
    print(myList);
    return await Response.ok(jsonEncode(myList));
  });

// Feature 3 clicking on title and displayin all contents
  // router.get('/questions', (Request request) async {
  //   var load = await connection.query(
  //       "SELECT title, summary, description, user_id ,names From questions");
  //   var myList = load.toList();
  //   print(myList);
  //   return await Response.ok(jsonEncode(myList));
  // });

  // Feature 1 Posting questions

  router.post('/questions', (Request request) async {
    var uri = await request.url;
    Map<String, String> params = uri.queryParameters;
    var title = params['title'];
    var summary = params['summary'];
    var description = params['description'];
    var date = params['date'];
    var created_at = params['created_at'];

    await connection.query(
        'INSERT into questions(title, summary, description, date, created_at) VALUES(?, ?, ?, ?, ?)',
        [title, summary, description, date, created_at]);
    print('Sucessfully Added');

    return Response.ok(jsonEncode(params));
  });

  router.post('/answers', (Request request) async {
    var uri = await request.url;
    Map<String, String> load = uri.queryParameters;
    var answer = load['answer'];
    var question_id = load['question_id'];
    var user_id = load['user_id'];
    var date_answered = load['date_answered'];

    await connection.query(
        'INSERT into answers(answer, question_id, user_id, date_answered) VALUES(?, ?, ?, ?)',
        [answer, question_id, user_id, date_answered]);
    print('Done');

    return Response.ok(jsonEncode(load));
  });

  final server = await serve(
    router,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

// Response request(Request request) => Response.ok('result');
