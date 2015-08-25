library httprate.rate_client;

import 'dart:async';
import 'package:http/src/base_client.dart';
import 'package:http/src/client.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/streamed_response.dart';
import 'package:httprate/src/rate_queue.dart';

/// A Client proxy that rate limit the requests.
///
/// This proxy will defer the http request until the number of request is the
/// limit set by [RateQueue].
class RateClient extends BaseClient {
  final Client inner;
  /// The [RateQueue] that is used by this client.
  ///
  /// It is possible to change this property at any time. Request made in the
  /// future will use the new queue that you have set. But active tasks will
  /// not move over. So setting this value generally a bad idea to sett this
  /// property.
  RateQueue queue;

  /// Create a new [RateClient] that proxies calls to the inner [Client].
  ///
  /// You must set an inner [Client]. But if you don't set a [queue] the
  /// global [rateQueue] for this isolate will be used. That is mot likly
  /// what you want in a none testing setting.
  RateClient(this.inner, {this.queue}) {
    if (queue == null) {
      queue = rateQueue;
    }
  }

  /// Please see [Client.send] for documentations for how to use this method.
  Future<StreamedResponse> send(BaseRequest request) {
    var comp = new Completer();
    queue.runJob(request.url.host, () {
      comp.complete(inner.send(request).then((res) {
        var streamController = new StreamController();
        streamController
            .addStream(res.stream)
            .then((_) => streamController.close());
        return [_copy(res, streamController.stream), streamController.done];
      }));
      return comp.future.then((List dual) => dual.last);
    });
    return comp.future.then((List dual) => dual.first);
  }

  close() => inner.close();

  StreamedResponse _copy(StreamedResponse res, Stream stream) {
    return new StreamedResponse(stream, res.statusCode,
        contentLength: res.contentLength,
        request: res.request,
        headers: res.headers,
        isRedirect: res.isRedirect,
        persistentConnection: res.persistentConnection,
        reasonPhrase: res.reasonPhrase);
  }
}
