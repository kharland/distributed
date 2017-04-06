import 'dart:async';

import 'package:distributed.http/vm.dart';
import 'package:distributed/src/http_server_builder/http_server_builder.dart';
import 'package:distributed/src/node/node.dart';
import 'package:distributed/src/node/remote_interaction/request_handlers.dart';

Future<HttpServer> bindServer(String address, int port, Node node) async {
  return await (new HttpServerBuilder()
        ..addHandler(new ConnectHandler(node, connectMatcher))
        ..addHandler(new DisconnectHandler(node, disconnectMatcher)))
      .bind(address, port);
}
