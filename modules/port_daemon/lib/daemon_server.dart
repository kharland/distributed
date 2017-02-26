import 'dart:async';
import 'dart:io' show File, InternetAddress;

import 'package:distributed.port_daemon/src/daemon_server_info.dart';
import 'package:distributed.port_daemon/src/http_method.dart';
import 'package:distributed.port_daemon/src/http_request_handler.dart';
import 'package:distributed.port_daemon/src/port_daemon.dart';
import 'package:distributed.port_daemon/src/request_authenticator.dart';
import 'package:distributed.objects/secret.dart';
import 'package:express/express.dart' as express;
import 'package:express/express.dart' show HttpContext;
import 'package:logging/logging.dart';

class DaemonServer {
  static const int defaultPort = 4369;
  static const String defaultHostname = 'localhost';

  final DaemonServerInfo serverInfo;
  final PortDaemon _portDaemon;

  final express.Express _express = new express.Express();
  final Logger _logger = new Logger('$DaemonServer');
  final RequestAuthenticator _requestAuthenticator;

  DaemonServer(
      {PortDaemon portDaemon,
      DaemonServerInfo serverInfo,
      RequestAuthenticator requestAuthenticator})
      : serverInfo = serverInfo ?? new DaemonServerInfo(),
        _portDaemon =
            portDaemon ?? new PortDaemon(new NodeDatabase(new File('node.db'))),
        _requestAuthenticator =
            requestAuthenticator ?? new SecretAuthenticator(Secret.acceptAny) {
    express.logger = (Object obj) {
      _logger.info(obj);
    };
  }

  String get url => serverInfo.url;

  /// Starts listening for requests.
  ///
  /// Returns a future that completes when the server is ready for connections.
  Future start() async {
    [
      new PingHandler(_portDaemon),
      new RegisterNodeHandler(_portDaemon),
      new DeregisterNodeHandler(_portDaemon),
      new LookupNodeHandler(_portDaemon),
      new ListNodesHandler(_portDaemon)
    ].forEach((route) {
      _installRoute(route, _express);
    });
    await _express.listen(
        InternetAddress.LOOPBACK_IP_V4.host, serverInfo.port.toInt());
  }

  /// Stops listening for new connections.
  void stop() {
    _express.close();
  }

  void clearDatabase() {
    _portDaemon.clearDatabase();
  }

  void _installRoute(
    HttpRequestHandler route,
    express.Express express, {
    Secret secret: Secret.acceptAny,
  }) {
    var installer;

    switch (route.method) {
      case HttpMethod.get:
        installer = express.get;
        break;
      case HttpMethod.put:
        installer = express.put;
        break;
      case HttpMethod.post:
        installer = express.post;
        break;
      case HttpMethod.delete:
        installer = express.delete;
        break;
      default:
        throw new UnimplementedError(route.method.value);
    }

    installer('${route.route}/:secret', (HttpContext context) {
      if (_requestAuthenticator.isContextValid(context)) {
        route.execute(context);
      } else {
        context.sendText('Autentication failed');
        context.end();
      }
    });
  }
}
