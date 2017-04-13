import 'dart:async';

import 'package:distributed/src/http_server_builder/http_server_builder.dart';
import 'package:distributed/src/http_server_builder/request_handler.dart';
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
  static const _R_ping = '/ping';
  static const _R_addNode = '/node/:name';
  static const _R_removeNode = '/node/:name';
  static const _R_lookupNode = '/node/:name';

  /* Routes for future use */

  // ignore: unused_field
  static const _R_listNodes = '/list/node';
  // ignore: unused_field
  static const _R_controlServer = '/node/control_server/:name';
  // ignore: unused_field
  static const _R_diagnosticsServer = '/node/diagnostics_server/:name';
  // ignore: unused_field
  static const _R_keepAlive = '/ping/:name';

  final HttpServer _delegate;

  static Future<PortDaemonHttpServer> bind(
    String host,
    int port, {
    @required NodeDatabase db,
    @required Logger logger,
  }) async {
    var server = await (new HttpServerBuilder()
          ..add(any('/', createRequestLogger(logger)))
          ..add(get(_R_ping, createPingHandler(logger, db)))
          ..add(post(_R_addNode, createAddNodeHandler(logger, db)))
          ..add(delete(_R_removeNode, createRemoveNodeHandler(logger, db)))
          ..add(get(_R_lookupNode, createLookupNodeHandler(logger, db))))
        .bind(host, port);
    return new PortDaemonHttpServer._(server);
  }

  PortDaemonHttpServer._(this._delegate);

  /// The url for connecting to this server.
  String get url => _delegate.url;

  /// Shuts down this server.
  void stop() {
    _delegate.close();
  }
}
