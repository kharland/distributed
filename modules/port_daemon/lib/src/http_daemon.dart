import 'dart:async';
import 'dart:io' show InternetAddress;

import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/database/database.dart';
import 'package:distributed.port_daemon/src/database_helpers.dart';
import 'package:distributed.port_daemon/src/http_request_handler.dart';
import 'package:express/express.dart' as express;
import 'package:express/express.dart' show HttpContext;
import 'package:logging/logging.dart';

class ExpressHttpDaemon extends Object
    with DatabaseHelpers
    implements PortDaemon {
  final HostMachine _hostMachine;
  final express.Express _express = new express.Express();
  final Logger _logger = new Logger('$ExpressHttpDaemon');

  ExpressHttpDaemon({HostMachine hostMachine})
      : _hostMachine = hostMachine ??
            createHostMachine(InternetAddress.LOOPBACK_IP_V4, 4369) {
    express.logger = (Object obj) {
      _logger.info(obj);
    };
    database = new MemoryDatabase<String, int>();
  }

  @override
  String get url => _hostMachine.daemonUrl;

  @override
  Future start() async {
    [
      new PingHandler(this),
      new RegisterNodeHandler(this),
      new DeregisterNodeHandler(this),
      new LookupNodeHandler(this),
      new ListNodesHandler(this)
    ].forEach((route) {
      _installRoute(route, _express);
    });
    await _express.listen(
        InternetAddress.LOOPBACK_IP_V4.host, _hostMachine.daemonPort.toInt());
  }

  @override
  void stop() {
    _express.close();
  }

  void _installRoute(HttpRequestHandler route, express.Express express) {
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

    installer('${route.route}', (HttpContext context) {
      route.execute(context);
    });
  }
}
