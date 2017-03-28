import 'dart:async';
import 'dart:io' as io;

import 'package:distributed/src/http_server/router.dart';

/// An HttpServer that
class HttpServer {
  final io.HttpServer _delegate;

  static Future<HttpServer> bind(
      String address, int port, Router router) async {
    var httpServer = await io.HttpServer.bind(address, port);
    httpServer.listen(router.route);
    return new HttpServer._(httpServer);
  }

  HttpServer._(this._delegate);

  Future close() => _delegate.close(force: true);
}
