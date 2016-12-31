import 'dart:async';
import 'dart:io';

import 'package:distributed.port_daemon/daemon.dart';
import 'package:distributed.port_daemon/src/route_handler.dart';
import 'package:express/express.dart';
import 'package:fixnum/fixnum.dart';

class DaemonServer {
  static const int defaultPort = 4369;
  static const String defaultHostname = 'localhost';
  static const String defaultCookie = RouteHandler.acceptAllCookie;

  final Express _express = new Express();
  final Daemon _daemon;
  final String cookie;
  final String hostname;
  final Int64 port;

  DaemonServer(this._daemon,
      {this.hostname: DaemonServer.defaultHostname,
      int port: DaemonServer.defaultPort,
      this.cookie: DaemonServer.defaultCookie})
      : this.port = new Int64(port) {
    logger = (_) {};
  }

  static String url(String hostname, Int64 port) => 'http://$hostname:$port';

  /// Starts listening for requests.
  ///
  /// Returns a future that completes when the server is ready for connections.
  Future<Null> start() async {
    [
      new PingHandler(),
      new RegisterNodeHandler(_daemon, cookie),
      new DeregisterNodeHandler(_daemon, cookie),
      new LookupNodeHandler(_daemon, cookie),
      new ListNodesHandler(_daemon, cookie)
    ].forEach((route) {
      _installRoute(route, _express, cookie: cookie);
    });
    await _express.listen(InternetAddress.LOOPBACK_IP_V4.host, port.toInt());
  }

  /// Stops listening for new connections.
  void stop() {
    _express.close();
  }

  void _installRoute(RouteHandler route, Express express, {String cookie: ''}) {
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

    installer('${route.route}/:cookie', route.execute);
  }
}
