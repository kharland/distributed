import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/web_server.dart';
import 'package:express/express.dart' as express;
import 'package:express/express.dart' show HttpContext;
import 'package:meta/meta.dart';

/// A [WebServer] implementation that uses package:express.
///
/// This class shares global state by modifying the default logger used by
/// package:express.  It's recommended that only once instance be created at a
/// time.
class ExpressServer implements WebServer {
  final BuiltHostMachine _hostMachine;
  final express.Express _express;

  static Future<ExpressServer> start({
    @required BuiltHostMachine hostMachine,
    @required NodeDatabase nodeDatabase,
    @required Logger logger,
  }) async {
    express.logger = (_) => logger.error(_);
    var db = nodeDatabase;
    var expressInstance = new express.Express()
      ..get('/list/node',
          (express.HttpContext ctx) => throw new UnimplementedError())
      ..get(
          '/node/:name',
          (express.HttpContext ctx) =>
              _handleLookupNodeRequest(ctx, db, logger))
      ..post(
          '/node/:name',
          (express.HttpContext ctx) =>
              _handleRegisterNodeRequest(ctx, db, logger))
      ..delete(
          '/node/:name',
          (express.HttpContext ctx) =>
              _handleDeregisterNodeRequest(ctx, db, logger))
      ..get(
          '/node/server/:name',
          (express.HttpContext ctx) =>
              _handleLookupServerRequest(ctx, db, logger))
      ..post(
          '/node/server/:name',
          (express.HttpContext ctx) =>
              _handleRegisterServerRequest(ctx, db, logger))
      ..get('/ping/:name',
          (express.HttpContext ctx) => _handleKeepAliveRequest(ctx, db, logger))
      ..get('/ping',
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

  static Future _handleKeepAliveRequest(
    HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    db.keepAlive(ctx.params['name']);
    ctx.sendText('');
    ctx.end();
  }

  static Future _handleRegisterNodeRequest(
    HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    db.registerNode(ctx.params['name']).then((Registration registration) {
      logger.log('Registered ${ctx.params['name']} to ${registration.port}');
      ctx.sendText(serialize(registration));
      ctx.end();
    }).catchError((e, stacktrace) {
      logger..error(e)..error(stacktrace);
      ctx.sendText(serialize($registration(Ports.error, e.toString())));
      ctx.end();
    });
  }

  static Future _handleRegisterServerRequest(
    express.HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    db.registerNodeServer(ctx.params['name']).then((Registration registration) {
      logger.log(
          'Registered server for ${ctx.params['name']} to ${registration.port}');
      ctx.sendText(serialize(registration));
      ctx.end();
    }).catchError((e, stacktrace) {
      logger..error(e)..error(stacktrace);
      ctx.sendText(serialize($registration(Ports.error, e.toString())));
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

  static Future _handleLookupServerRequest(
    express.HttpContext ctx,
    NodeDatabase db,
    Logger logger,
  ) async {
    db.getServerPort(ctx.params['name']).then((int port) {
      ctx.sendText(port.toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      logger..error(e)..error(stacktrace);
      ctx.sendText(Ports.error.toString());
      ctx.end();
    });
  }
}
