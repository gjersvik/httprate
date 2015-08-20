import 'dart:async';
import 'dart:io';

main() async {
  String oneKiloByte = new List.filled(32,new List.filled(32, 'a').join()).join();
  int concurrent = 0;
  HttpServer server = await HttpServer.bind('127.0.0.1',8080);
  server.listen((HttpRequest req) async{
    concurrent += 1;
    stdout.write('$concurrent:');
    await req.toList();
    for(int i = 0; i < 10; i += 1){
      await wait();
      req.response.write(oneKiloByte);
    }
    await req.response.close();
    concurrent -= 1;
    stdout.write('$concurrent:');
  });
}

wait() => new Future.delayed(new Duration(milliseconds: 10));