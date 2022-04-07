/* server.dart */

/* the simplest possible web server */

import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

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
    print(request);

    var results = await connection.query(
        "SELECT title, summary, description, user_id, question_id, CAST(date AS char), names FROM questions");

    await connection.close();
    List<dynamic> data = List.filled(0, 0, growable: true);

    results.forEach((row) {
      Map x = new Map();
      for (int i = 0; i < results.fields.length; i++) {
        x[results.fields[i].name] = row[i];
      }
      data.add(x);
    });
    print(data);
    return await Response.ok(jsonEncode(data));
  });
  // Feature 1 Posting questions API

  router.post('/questions', (Request request) async {
    var uri = await request.url;

    var data = jsonDecode(await request.readAsString());
    var title = data['title'];
    var summary = data['summary'];
    var description = data['description'];
    var date = data['date'];
    // var created_at = data['created_at'];
    var names = data['names'];
    try {
      await connection.query(
          'INSERT into questions(title, summary, description, date, names) VALUES(?, ?, ?, ?,?)',
          [title, summary, description, date, names]);
      print('Sucessfully Added');
    } catch (e) {
      print('Exception type $e');
    }

    await connection.close();
    return Response.ok(jsonEncode(data));
  });

//**************************************************************************************************** */

//login Page Api/authen
  router.post('/users', (Request request) async {
    // var uri = await request.url;
    // Map<String, String> queryString = uri.queryParameters;
    var data = jsonDecode(await request.readAsString());
    print(data);
    var name = data['username'];
    var password = data['password'];
    var results = await connection
        .query('SELECT name, password FROM users WHERE name=?', [name]);
    print(results);
    Map dim;
    results.forEach((row) {
      dim = new Map();
      for (int i = 0; i < results.fields.length; i++) {
        dim[results.fields[i].name] = row[i];
      }
    });

    print(dim['password']);

    if (password == dim['password']) {
      return Response.ok('yes');
    } else {
      return Response.ok('no');
    }

    // await connection.close();
  });

// END LOGIN AUTHEN/ API

//**************************************************************************************************************************** */

  //Answer Api
  router.post('/answers', (Request request) async {
    var uri = await request.url;
    // Map<String, String> load = uri.queryParameters;
    var data = jsonDecode(await request.readAsString());
    var answer = data['answer'];
    var question_id = data['question_id'];
    var user_id = data['user_id'];
    var date_answered = data['date_answered'];
    try {
      await connection.query(
          'INSERT into answers(answer, question_id, user_id, date_answered) VALUES(?, ?, ?, ?)',
          [answer, question_id, user_id, date_answered]);
      print('Done');
    } catch (e) {
      print('Exception type $e');
    }
    print(data);
    await connection.close();
    return Response.ok(jsonEncode(data));
  });

//************************************************************************************************************************************ */

// ANSWER POST MEHTOD API

  router.get('/answers', (Request request) async {
    print(request);

    var results = await connection.query("select * from answers");
    print(results);
    await connection.close();
    List<dynamic> data = List.filled(0, 0, growable: true);

    results.forEach((row) {
      Map x = new Map();
      for (int i = 0; i < results.fields.length; i++) {
        x[results.fields[i].name] = row[i];
      }
      data.add(x);
    });
    print(data);
    return await Response.ok(jsonEncode(data));
  });

  //END ANSWER GET METHOD API*******************************************************************************************************

  final cascade = new Cascade().add(router);

  const _headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  };

  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: _headers))
      .addHandler(cascade.handler);

  final server = await serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}
