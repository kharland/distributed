import 'dart:async';

import 'package:distributed.http/vm.dart';

// TODO: Move to someplace non-global. perhaps in NetworkManager
int _requestId = 0;
final _idToRequest = <String, ServerHttpRequest>{};

class HttpRequestSerializer {
  ServerHttpRequest deserialize(String serialized) {
    assert(_idToRequest.containsKey(serialized));
    return _idToRequest.remove(serialized);
  }

  String serialize(ServerHttpRequest request) {
    _requestId++;
    _idToRequest['$_requestId'] = request;
    return '$_requestId';
  }
}

class HttpRequestTransformer
    implements StreamTransformer<String, ServerHttpRequest> {
  @override
  Stream<ServerHttpRequest> bind(Stream<String> stream) {
    return stream.map(new HttpRequestSerializer().deserialize);
  }
}
