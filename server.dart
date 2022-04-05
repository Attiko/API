/* server.dart */

/* the simplest possible web server */

import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
// import 'package:mysql_client/mysql_client.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
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
        "SELECT title, summary, description, user_id, CAST(created_at AS char), CAST(date AS char), names FROM questions;");

    // await connection.close();
    List<dynamic> data = List.filled(0, 0, growable: true);

    results.forEach((row) {
      Map x = new Map();
      for (int i = 0; i < results.fields.length; i++) {
        x[results.fields[i].name] = row[i];
      }
      data.add(x);
    });
    print(data);
    return await Response.ok(jsonEncode(data)
        // headers: {'Content-type': 'application/json'},
        // encoding: convert.Encoding.getByName('utf-8'),
        );
  });
  // Feature 1 Posting questions API

  router.post('/questions', (Request request) async {
    var uri = await request.url;
    // Map<String, String> params = uri.queryParameters;
    var data = jsonDecode(await request.readAsString());
    var title = data['title'];
    var summary = data['summary'];
    var description = data['description'];
    var date = data['date'];
    var created_at = data['created_at'];
    var names = data['names'];

    await connection.query(
        'INSERT into questions(title, summary, description, date, created_at, names) VALUES(?, ?, ?, ?, ?,?)',
        [title, summary, description, date, created_at, names]);
    print('Sucessfully Added');

    // await connection.close();
    return Response.ok(jsonEncode(data));
  });

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

  //Answer Api
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
    await connection.close();
    return Response.ok(jsonEncode(load));
  });

// ANSWER POST MEHTOD API

  router.get('/answers', (Request request) async {
    print(request);
    var results = await connection.query(
        "SELECT answer, question_id, user_id, CAST(date_answered AS char) FROM answers;");

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

  //END ANSWER GET METHOD API
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

// Response request(Request request) => Response.ok('result');




// /* server.dart */

// /* the simplest possible web server */

// // import 'dart:html';
// import 'dart:io';
// import 'package:mysql1/mysql1.dart';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart';
// import 'package:shelf_router/shelf_router.dart';
// // import 'package:mysql_client/mysql_client.dart';
// import 'dart:convert' as convert;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// Future main() async {
//   final connection = await MySqlConnection.connect(ConnectionSettings(
//     host: "localhost",
//     port: 3307,
//     user: "root",
//     password: "fatoki@dimeji1A",
//     db: "faqs",
//   ));

//   Router router = Router();
// //Feature 2 The home screen should display a list of the questions that users have asked.
//   router.get('/questions', (Request request) async {
//     print(request);
//     var results = await connection.query(
//         "SELECT title, summary, description, user_id, CAST(created_at AS char), CAST(date AS char), names FROM questions;");

//     // await connection.close();
//     List<dynamic> data = List.filled(0, 0, growable: true);

//     results.forEach((row) {
//       Map x = new Map();
//       for (int i = 0; i < results.fields.length; i++) {
//         x[results.fields[i].name] = row[i];
//       }
//       data.add(x);
//     });
//     print(data);
//     return await Response.ok(jsonEncode(data)
//         // headers: {'Content-type': 'application/json'},
//         // encoding: convert.Encoding.getByName('utf-8'),
//         );
//   });

//   /********************************************************* */
//   // Feature 1 Posting questions API

//   router.post('/questions', (Request request) async {
//     var uri = await request.url;
//     Map<String, String> params = uri.queryParameters;
//     // var data = jsonDecode(await request.readAsString());
//     var title = params['title'];
//     var summary = params['summary'];
//     var description = params['description'];
//     var date = params['date'];
//     var created_at = params['created_at'];
//     var names = params['names'];
//     print(params);
//     try {
//       await connection.query(
//           'INSERT into questions(title, summary, description, CAST(date AS char), CAST(created_at AS char), names) VALUES(?, ?, ?, ?, ?, ?)',
//           [title, summary, description, date, created_at, names]);
//       print('Sucessfully Added');
//     } catch (e) {
//       print("Exception type $e");
//     }

//     // await connection.close();
//     return Response.ok(jsonEncode(params));
//   });

// //login Page Api/authen
//   router.get('/users', (Request request) async {
//     var uri = await request.url;
//     Map<String, String> queryString = uri.queryParameters;
//     var name = queryString['name'];
//     var password = queryString['password'];
//     var results = await connection
//         .query('SELECT name, password FROM users WHERE name=?', [name]);
//     Map dim;
//     results.forEach((row) {
//       dim = new Map();
//       for (int i = 0; i < results.fields.length; i++) {
//         dim[results.fields[i].name] = row[i];
//       }
//     });

//     print(dim);
//     if (password == dim['password']) {
//       return Response.ok('You got it! ');
//     } else {
//       return Response.ok('Try again, this time think HARDER!');
//     }
//     // await connection.close();
//   });

// // END LOGIN AUTHEN/ API

//   //Answer Api
//   router.post('/answers', (Request request) async {
//     var uri = await request.url;
//     Map<String, String> load = uri.queryParameters;
//     var answer = load['answer'];
//     var question_id = load['question_id'];
//     var user_id = load['user_id'];
//     var date_answered = load['date_answered'];

//     await connection.query(
//         'INSERT into answers(answer, question_id, user_id, date_answered) VALUES(?, ?, ?, ?)',
//         [answer, question_id, user_id, date_answered]);
//     print('Done');
//     // await connection.close();
//     return Response.ok(jsonEncode(load));
//   });

// // ANSWER POST MEHTOD API

//   router.get('/answers/<question_id>/answers',
//       (Request request, String question_id) async {
//     int id = int.parse(question_id);
//     print(request);
//     var results = await connection.query(
//         "SELECT answer, user_id, CAST(date_answered AS char) FROM answers WHERE question_id=?",
//         [id]);

//     // await connection.close();
//     List<dynamic> data = List.filled(0, 0, growable: true);

//     results.forEach((row) {
//       Map x = new Map();
//       for (int i = 0; i < results.fields.length; i++) {
//         x[results.fields[i].name] = row[i];
//       }
//       data.add(x);
//     });
//     print(data);
//     return await Response.ok(jsonEncode(data));
//   });

//   //END ANSWER GET METHOD API
//   final cascade = new Cascade().add(router);

//   const _headers = {
//     'Access-Control-Allow-Origin': '*',
//     'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
//     'Access-Control-Allow-Headers': '*',
//   };

//   var handler = const Pipeline()
//       .addMiddleware(logRequests())
//       .addMiddleware(corsHeaders(headers: _headers))
//       .addHandler(cascade.handler);

//   final server = await serve(
//     handler,
//     InternetAddress.anyIPv4,
//     8080,
//   );

//   server.autoCompress = true;

//   print('Serving at http://${server.address.host}:${server.port}');
// }

// // Response request(Request request) => Response.ok('result');
