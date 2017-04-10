import 'dart:async';

import 'package:distributed/src/http_server_builder/http_server_builder.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/request_handlers.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:meta/meta.dart';

/// An HTTP server for the port daemon.
///
/// This class shares global state by modifying the default logger used by
/// package:express.  It's recommended that only once instance be created at a
/// time.
class PortDaemonHttpServer {
  final HttpServer _delegate;

  static Future<PortDaemonHttpServer> bind(String host, int port,
      {@required NodeDatabase db, @required Logger logger}) async {
    var server = await (new HttpServerBuilder()
          ..add(new LoggingHandler(matchAllMatcher, logger))
          ..add(new PingHandler(pingMatcher, logger, db))
          ..add(new AddNodeHandler(addNodeMatcher, logger, db))
          ..add(new RemoveNodeHandler(removeNodeMatcher, logger, db))
          ..add(new LookupNodeHandler(lookupNodeHandler, logger, db)))
        .bind(host, port);
    return new PortDaemonHttpServer._(server);
  }

  PortDaemonHttpServer._(this._delegate);

  String get url => _delegate.url;

  void stop() {
    _delegate.close();
  }
}
