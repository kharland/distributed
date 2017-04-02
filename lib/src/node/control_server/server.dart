import 'dart:async';
import 'dart:io';

import 'package:distributed/src/http_server/http_server.dart';
import 'package:distributed/src/node/node.dart';
import 'package:distributed/src/node/control_server/request_handlers.dart';

Future<HttpServer> bindControlServer(
    String address, int port, Node node) async {
  return await (new HttpServerBuilder()
        ..addHandler(new ConnectHandler(node, connectMatcher))
        ..addHandler(new DisconnectHandler(node, disconnectMatcher))
        ..addHandler(new PingHandler(pingMatcher)))
      .bind(address, port);
}
