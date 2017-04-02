import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed/src/port_daemon/routes.dart' as routes;
import 'package:distributed/src/port_daemon/web_server.dart';
import 'package:distributed.objects/private.dart' hide serialize;
import 'package:distributed.objects/public.dart';
import 'package:express/express.dart' as express;
import 'package:express/express.dart' show HttpContext;
import 'package:meta/meta.dart';

/// A [WebServer] implementation that uses package:express.
///
/// This class shares global state by modifying the default logger used by
/// package:express.  It's recommended that only once instance be created at a
/// time.
class ExpressServer implements WebServer {
  final HostMachine _hostMachine;
  final express.Express _express;

  static Future<ExpressServer> start({
    @required HostMachine hostMachine,
    @required NodeDatabase nodeDatabase,
    @required Logger logger,
  }) async {
    express.logger = (_) => logger.error(_);
    var db = nodeDatabase;
    var expressInstance = new express.Express()
      ..get(routes.listNodes,
          (express.HttpContext ctx) => throw new UnimplementedError())
      ..get(
          routes.nodeByName,
          (express.HttpContext ctx) =>
              _handleLookupNodeRequest(ctx, db, logger))
      ..post(
          routes.nodeByName,
          (express.HttpContext ctx) =>
              _handleRegisterNodeRequest(ctx, db, logger))
      ..delete(
          routes.nodeByName,
          (express.HttpContext ctx) =>
              _handleDeregisterNodeRequest(ctx, db, logger))
      ..get(
          routes.controlServer,
          (express.HttpContext ctx) =>
              _handleControlServerRequest(ctx, db, logger))
      ..get(routes.ping,
          (express.HttpContext ctx) => _handlePingRequest(ctx, logger));
    await expressInstance.listen(
        hostMachine.address, hostMachine.portDaemonPort);
    return new ExpressServer._(hostMachine, expressInstance);
  }

  ExpressServer._(this._hostMachine, this._express);

  @override
  String get url => _hostMachine.portDaemonUrl;

  @override
  void stop() {
    _express.close();
  }

  static Future _handlePingRequest(HttpContext ctx, Logger logger) async {
    ctx.sendText('');
    ctx.end();
  }

  static Future _handleRegisterNodeRequest(
    HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    final name = ctx.params['name'];
    db.registerNode(name).then((Registration registration) {
      if (registration.error.isEmpty) {
        logger
          ..log('Registered $name to ${registration.ports.first}')
          ..log('Registered $name server to ${registration.ports.last}');
      } else {
        logger.error(registration.error);
      }
      ctx.sendText(Registration.serialize(registration));
      ctx.end();
    }).catchError((e, stacktrace) {
      logger..error(e.toString())..error(stacktrace.toString());
      ctx.sendText(
          Registration.serialize($registration(errorPortList, e.toString())));
      ctx.end();
    });
  }

  static Future _handleDeregisterNodeRequest(
    HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    db.deregisterNode(ctx.params['name']).then((String result) {
      logger.log('Deregistered ${ctx.params['name']}');
      ctx.sendText(result);
      ctx.end();
    }).catchError((e, stacktrace) {
      logger..error(e)..error(stacktrace);
      ctx.sendText(e.toString());
      ctx.end();
    });
  }

  static Future _handleLookupNodeRequest(
    HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    db.getPort(ctx.params['name']).then((int port) {
      ctx.sendText(port.toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      logger..error(e)..error(stacktrace);
      ctx.sendText(Ports.error.toString());
      ctx.end();
    });
  }

  static Future _handleControlServerRequest(
    express.HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    db.getControlServerPort(ctx.params['name']).then((int port) {
      ctx.sendText(port.toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      logger..error(e)..error(stacktrace);
      ctx.sendText(Ports.error.toString());
      ctx.end();
    });
  }
}
