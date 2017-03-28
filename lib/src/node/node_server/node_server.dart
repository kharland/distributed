import 'dart:async';
import 'package:distributed/src/node/node.dart';
import 'package:distributed/src/node/node_server/control_route/control_route.dart';
import 'package:distributed/src/node/node_server/control_route/control_handlers.dart';
import 'package:distributed/src/http_server/request_handler.dart';
import 'package:distributed/src/http_server/route.dart';
import 'package:distributed/src/http_server/router.dart';
import 'package:distributed/src/http_server/http_server.dart';

Future<HttpServer> createNodeServer(String address, int port, Node node) {
  return HttpServer.bind(
      address,
      port,
      new Router.fromRoutes(<Route>[
        new ControlRoute(<RequestHandler>[
          new ConnectHandler(node),
          new DisconnectHandler(node),
        ])
        // TODO: Status Route
        // TODO: Security Route
      ]));
}
