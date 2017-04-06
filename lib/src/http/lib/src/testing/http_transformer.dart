import 'dart:async';

import 'package:distributed.http/vm.dart';

// TODO: Move to someplace non-global. perhaps in NetworkManager
int _requestId = 0;
final _idToRequest = <String, HttpRequest>{};

class HttpRequestSerializer {
  HttpRequest deserialize(String serialized) {
    assert(_idToRequest.containsKey(serialized));
    return _idToRequest.remove(serialized);
  }

  String serialize(HttpRequest request) {
    _requestId++;
    _idToRequest['$_requestId'] = request;
    return '$_requestId';
  }
}

class HttpRequestTransformer implements StreamTransformer<String, HttpRequest> {
  @override
  Stream<HttpRequest> bind(Stream<String> stream) {
    return stream.map(new HttpRequestSerializer().deserialize);
  }
}
