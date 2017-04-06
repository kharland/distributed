import 'dart:async';

import 'package:distributed.http/vm.dart';
import 'package:distributed/src/http_server_builder/request_handler.dart';

class HttpServerBuilder {
  RequestHandler _firstHandler;
  RequestHandler _lastHandler;

  void addHandler(RequestHandler handler) {
    if (_firstHandler == null) {
      _firstHandler = handler;
      _lastHandler = _firstHandler;
    } else {
      _lastHandler.successor = handler;
      _lastHandler = handler;
    }
  }

  Future<HttpServer> bind(String address, int port) async =>
      await HttpServer.bind(address, port)
        ..listen(_firstHandler.handle);
}
