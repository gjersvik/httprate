library httprate.rate_client;

import 'dart:async';
import 'package:http/src/base_client.dart';
import 'package:http/src/client.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/streamed_response.dart';
import 'package:httprate/src/rate_queue.dart';

class RateClient extends BaseClient {
  final Client inner;
  RateQueue queue;

  RateClient(this.inner, {this.queue}) {
    if (queue == null) {
      queue = rateQueue;
    }
  }

  Future<StreamedResponse> send(BaseRequest request) {
    var comp = new Completer();
    queue.runJob(request.url.host, (){
      comp.complete(inner.send(request).then((res){
        var streamController = new StreamController();
        streamController.addStream(res.stream).then((_) => streamController.close());
        return [_copy(res,streamController.stream),streamController.done];
      }));
      return comp.future.then((List dual) => dual.last);
    });
    return comp.future.then((List dual) => dual.first);
  }

  close() => inner.close();

  StreamedResponse _copy(StreamedResponse res, Stream stream){
    return new StreamedResponse(stream, res.statusCode,
    contentLength: res.contentLength,
    request: res.request,
    headers: res.headers,
    isRedirect: res.isRedirect,
    persistentConnection: res.persistentConnection,
    reasonPhrase: res.reasonPhrase);
  }
}
