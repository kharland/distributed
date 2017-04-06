import 'dart:async';

import 'package:distributed/src/http_server_builder/http_server_builder.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/request_handlers.dart';
import 'package:distributed.http/vm.dart';
import 'package:meta/meta.dart';

/// An HTTP server for the port daemon.
///
/// This class shares global state by modifying the default logger used by
/// package:express.  It's recommended that only once instance be created at a
/// time.
class PortDaemonHttpServer {
  final HttpServer _delegate;
  final BuiltHostMachine _hostMachine;

  static Future<PortDaemonHttpServer> start({
    @required BuiltHostMachine hostMachine,
    @required NodeDatabase db,
    @required Logger logger,
  }) async {
    var server = await (new HttpServerBuilder()
          ..addHandler(new LoggingHandler(matchAllMatcher, logger))
          ..addHandler(new PingHandler(pingMatcher, logger, db))
          ..addHandler(new AddNodeHandler(addNodeMatcher, logger, db))
          ..addHandler(new RemoveNodeHandler(removeNodeMatcher, logger, db))
          ..addHandler(new ListNodesHandler(listNodesMatcher, logger, db))
          ..addHandler(new LookupNodeHandler(lookupNodeHandler, logger, db)))
        .bind(hostMachine.address, hostMachine.portDaemonPort);
    return new PortDaemonHttpServer._(hostMachine, server);
  }

  PortDaemonHttpServer._(this._hostMachine, this._delegate);

  String get url => _hostMachine.portDaemonUrl;

  void stop() {
    _delegate.close();
  }
}
