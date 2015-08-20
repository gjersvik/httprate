@TestOn("vm")
library httprate.rate_clinet.test;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:httprate/httprate.dart';
import 'package:http/http.dart';

const ms10 = const Duration(microseconds: 10);

main() => group('RateClient', () {
  //integration tests.
  test('that it actualy limits http request even if server do a slow return.', () async {
    // @todo make more general
    Process server = await Process.start('dart',['test/testserver.dart']);

    var maxConcurrently = 0;
    server.stdout.map(UTF8.decode).expand((String s) => s.split(':')).where((s)=> s.isNotEmpty).map(int.parse).listen(((i){
      if(i > maxConcurrently){
        maxConcurrently = i;
      }
    }));
    server.stderr.map(UTF8.decode).listen(print);

    RateClient client = new RateClient(new Client(), queue: new RateQueue.independent());
    client.queue.hostLimit = 2;
    var requests = new List.generate(5, (_) => client.get('http://127.0.0.1:8080/'));
    await Future.wait(requests).timeout(new Duration(seconds:2));
    server.kill();
    expect(maxConcurrently, 2);
  });
});
