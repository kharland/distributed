import 'dart:io';

import 'package:distributed.port_mapping_daemon/daemon.dart';
import 'package:distributed.port_mapping_daemon/src/daemon_handle.dart';
import 'package:distributed.port_mapping_daemon/src/route_handler.dart';
import 'package:express/express.dart';

class DaemonServerBuilder {
  int _port = DaemonServerHandle.Default.port;
  String _hostname = DaemonServerHandle.Default.hostname;
  String _cookie = DaemonServerHandle.Default.cookie;
  Daemon _daemon;

  DaemonServerBuilder setCookie(String value) {
    _cookie = value;
    return this;
  }

  DaemonServerBuilder setPort(int value) {
    assert(value > 0);
    _port = value;
    return this;
  }

  DaemonServerBuilder setHost(String hostname) {
    _hostname = hostname;
    return this;
  }

  DaemonServerBuilder setDaemon(Daemon daemon) {
    _daemon = daemon;
    return this;
  }

  DaemonServer build() {
    assert(_port != null &&
        _hostname != null &&
        _cookie != null &&
        _daemon != null);
    return new DaemonServer._(
        _daemon, new DaemonServerHandle(_hostname, _port, _cookie));
  }
}

class DaemonServer {
  final Express _express = new Express();
  final Daemon _daemon;
  final DaemonServerHandle handle;

  DaemonServer._(this._daemon, this.handle);

  /// Starts listening for requests.
  ///
  /// Returns a future that completes when the server is ready for connections.
  void start() {
    [
      const PingHandler(),
      new RegisterNodeHandler(_daemon),
      new DeregisterNodeHandler(_daemon),
      new LookupNodeHandler(_daemon),
      new ListNodesHandler(_daemon)
    ].forEach((route) {
      _installRoute(route, _express, cookie: handle.cookie);
    });
    _express.listen(InternetAddress.LOOPBACK_IP_V4.host, handle.port);

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

    installer('${route.route}/:cookie', (HttpContext ctx) {
      if (cookie.isEmpty || ctx.params['cookie'] == cookie) {
        route.run(ctx);
      }
    });
  }
}
