import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/src/api.dart';
import 'package:distributed.port_daemon/src/node_database.dart';
import 'package:distributed.port_daemon/src/web_server.dart';
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
  }) async {
    express.logger = (Object obj) {
      globalLogger.log(obj);
    };
    var db = nodeDatabase;
    var expressInstance = new express.Express()
      ..get('/ping/:name',
          (express.HttpContext ctx) => _handlePingRequest(ctx, db))
      ..get('/node/:name',
          (express.HttpContext ctx) => _handleNodeLookupRequest(ctx, db))
      ..get('/list/node',
          (express.HttpContext ctx) => _handleNodeListRequest(ctx, db))
      ..post('/node/:name',
          (express.HttpContext ctx) => _handleRegisterNodeRequest(ctx, db))
      ..delete('/node/:name',
          (express.HttpContext ctx) => _handleDeregisterNodeRequest(ctx, db));
    await expressInstance.listen(hostMachine.address, hostMachine.daemonPort);
    return new ExpressServer._(hostMachine, expressInstance);
  }

  ExpressServer._(this._hostMachine, this._express);

  @override
  String get url => _hostMachine.daemonUrl;

  @override
  void stop() {
    _express.close();
  }

  static Future _handlePingRequest(HttpContext ctx, NodeDatabase db) async {
    db.keepAlive(ctx.params['name']);
    ctx.sendBytes([1]);
    ctx.end();
  }

  static Future _handleRegisterNodeRequest(
    HttpContext ctx,
    NodeDatabase db,
  ) async {
    String name = ctx.params['name'];
    db.registerNode(name).then((int port) {
      ctx.sendText(serialize(createRegistration(name, port), Registration));
      ctx.end();
    }).catchError((e, stacktrace) {
      globalLogger.error(e);
      globalLogger.error(stacktrace);
      ctx.sendText(serialize(createRegistration(), Registration));
      ctx.end();
    });
  }

  static Future _handleDeregisterNodeRequest(
    HttpContext ctx,
    NodeDatabase db,
  ) async {
    String name = ctx.params['name'];
    db.deregisterNode(name).then((isSuccess) {
      ctx.sendText(new DeregistrationResult(name, !isSuccess).toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      globalLogger.error(e);
      globalLogger.error(stacktrace);
      ctx.sendText(new DeregistrationResult(e.toString(), true).toString());
      ctx.end();
    });
  }

  static Future _handleNodeLookupRequest(
    HttpContext ctx,
    NodeDatabase db,
  ) async {
    db.getPort(ctx.params['name']).then((int port) {
      ctx.sendText(port.toString());
      ctx.end();
    });
  }

  static Future _handleNodeListRequest(HttpContext ctx, NodeDatabase db) async {
    var nodes = db.nodes;
    var ports = await Future.wait(nodes.map(db.getPort));
    var assignments = <String, int>{};
    for (int i = 0; i < nodes.length; i++) {
      assignments[nodes.elementAt(i)] = ports[i];
    }
    ctx.sendText(new PortAssignmentList(assignments));
    ctx.end();
  }
}
