/* server.dart */

/* the simplest possible web server */

import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql_client/mysql_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future main() async {
  final connection = await MySQLConnection.createConnection(
    host: "localhost",
    port: 3307,
    userName: "root",
    password: "fatoki@dimeji1A",
    databaseName: "faqs",
  );
  await connection.connect();

  Router router = Router();

  router.get('/faqs', (Request request) async {
    var results = await connection.execute("select * from questions");

    for (final row in results.rows) {
      print(row.assoc());
    }
    var myList = results.rows.toList();
    print(myList);
    return await Response.ok(jsonEncode(myList));

    //Map<String, dynamic> jsonResponse = convert.jsonDecode(response.body);
    // List<String> results = new List.empty()

    // String encodedData = convert.jsonEncode(jsonResponse['questions'][0]);
    // print(encodedData);
    // return await Response.ok(jsonEncode(load));
  });

  // await connection.close();

  final server = await serve(
    router,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

// Response request(Request request) => Response.ok('result');
