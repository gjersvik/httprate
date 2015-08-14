import 'dart:async';
import 'dart:io';

main() async {
  int concurrent = 0;
  HttpServer server = HttpServer.bind('127.0.0.1',8080);
  await for(HttpRequest req in server){
    concurrent += 1;
    stdout.write(concurrent);
    await req.toList();
    for(int i = 0; i < 10; i += 1){
      await wait();
      req.response.write(i);
    }
    req.response.write(concurrent);
    await req.response.close();
    concurrent -= 1;
    stdout.write(concurrent);
  }
}

wait() => new Future.delayed(new Duration(milliseconds: 10));