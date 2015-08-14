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
    server.stdout.listen(((s){
      var i = int.parse(UTF8.decode(s));
      if(i > maxConcurrently){
        maxConcurrently = i;
      }
    }));

    RateClient clinet = new RateCline(new Clinet(), queue: new RateQueue.independent());
    clinet.queue.hostLimit = 2;
    var requests = new Iterable.generate(5, () => clinet.read('http://localhost:8080/'));
    await Future.wait(requests);
    server.kill();
    expect(maxConcurrently, 2);
  });
});
