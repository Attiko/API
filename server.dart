/* server.dart */

/* the simplest possible web server */

import 'dart:io' show InternetAddress;

import 'package:shelf/shelf.dart' show Request, Response;
import 'package:shelf/shelf_io.dart' show serve;
/* import 'package:shelf_router/shelf_router.dart' show Router; */
// import 'package:mysql1/mysql1.dart';
import 'package:mysql_client/mysql_client.dart';

Future main() async {
  // final connection = await MySqlConnection.connect(new ConnectionSettings(
  //   host: 'localhost',
  //   port: 3307,
  //   user: 'root',
  //   password: 'fatoki@dimeji1A',
  //   db: 'faqs',
  // ));
  final connection = await MySQLConnection.createConnection(
    host: "localhost",
    port: 3307,
    userName: "root",
    password: "fatoki@dimeji1A",
    databaseName: "faqs", // optional
  );
  await connection.connect();
  await connection.execute(
      'insert into questions(title, summary, description) values("name","jndckdck","kdjcbkd")');
  // await connection.execute('delete from questions where title = "name";');
  // var results = await connection.execute('select * from questions');
  var result = await connection.execute('select * from answers');
  // print(result);
  print(result.rows);
  for (var row in result.rows) {
    print('${row.colAt(1)}');
  }

  await connection.close();
  /*final server = await serve(
    helloWorld,
    InternetAddress.anyIPv4,
    8080,
  );*/

  /* print('Serving at http://${server.address.host}:${server.port}');*/
}

/*Response helloWorld(Request request) => Response.ok('Hello World!');*/
