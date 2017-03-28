import 'dart:async';
import 'dart:io';
import 'package:distributed/src/node/node.dart';
import 'package:distributed/src/node/node_server/request_handlers/control_handlers.dart';
import 'package:distributed/src/http_server/http_server.dart';

Future<HttpServer> createNodeServer(String address, int port, Node node) {
  return (new HttpServerBuilder()
        ..addHandler(new ConnectHandler(node, connectMatcher))
        ..addHandler(new DisconnectHandler(node, disconnectMatcher)))
      .bind(address, port);
}
