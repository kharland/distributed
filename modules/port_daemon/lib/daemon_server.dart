import 'dart:async';
import 'dart:io';

import 'package:distributed.port_daemon/src/port_daemon.dart';
import 'package:distributed.port_daemon/src/route_handler.dart';
import 'package:distributed.net/secret.dart';
import 'package:express/express.dart' as express;
import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';

class DaemonServer {
  static const int defaultPort = 4369;
  static const String defaultHostname = 'localhost';

  final express.Express _express = new express.Express();
  final Logger _logger = new Logger('$DaemonServer');
  final PortDaemon _daemon;
  final Secret secret;
  final String hostname;
  final Int64 port;

  factory DaemonServer({
    String hostname: DaemonServer.defaultHostname,
    Secret secret: Secret.acceptAny,
    int port: DaemonServer.defaultPort,
  }) =>
      new DaemonServer.withDaemon(
          new PortDaemon(new NodeDatabase(new File('node.db'))),
          hostname: hostname,
          secret: secret,
          port: port);

  DaemonServer.withDaemon(
    this._daemon, {
    this.hostname: DaemonServer.defaultHostname,
    int port: DaemonServer.defaultPort,
    this.secret: Secret.acceptAny,
  })
      : this.port = new Int64(port) {
    express.logger = (Object obj) {
      _logger.info(obj);
    };
  }

  static String url(String hostname, Int64 port) => 'http://$hostname:$port';

  /// Starts listening for requests.
  ///
  /// Returns a future that completes when the server is ready for connections.
  Future start() async {
    [
      new PingHandler(_daemon, secret),
      new RegisterNodeHandler(_daemon, secret),
      new DeregisterNodeHandler(_daemon, secret),
      new LookupNodeHandler(_daemon, secret),
      new ListNodesHandler(_daemon, secret)
    ].forEach((route) {
      _installRoute(route, _express, secret: secret);
    });
    await _express.listen(InternetAddress.LOOPBACK_IP_V4.host, port.toInt());
  }

  /// Stops listening for new connections.
  void stop() {
    _express.close();
  }

  void clearDatabase() {
    _daemon.clearDatabase();
  }

  void _installRoute(
    RouteHandler route,
    express.Express express, {
    Secret secret: Secret.acceptAny,
  }) {
    var installer;

    switch (route.method) {
      case RouteHandler.get:
        installer = express.get;
        break;
      case RouteHandler.put:
        installer = express.put;
        break;
      case RouteHandler.post:
        installer = express.post;
        break;
      case RouteHandler.delete:
        installer = express.delete;
        break;
      case RouteHandler.patch:
        installer = express.patch;
        break;
      default:
        throw new UnimplementedError(route.method);
    }

    installer('${route.route}/:secret', route.execute);
  }
}
