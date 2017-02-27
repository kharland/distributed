import 'dart:async';

import 'package:distributed.port_daemon/src/http_method.dart';
import 'package:distributed.port_daemon/src/database_helpers.dart';
import 'package:distributed.port_daemon/src/api.dart';
import 'package:express/express.dart' hide Logger;
import 'package:logging/logging.dart';

abstract class HttpRequestHandler {
  HttpMethod get method;

  String get route;

  Future execute(HttpContext ctx);
}

class PingHandler implements HttpRequestHandler {
  final DatabaseHelpers _daemon;

  PingHandler(this._daemon);

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get route => '/ping/:name';

  @override
  Future execute(HttpContext ctx) async {
    _daemon.acknowledgeNodeIsAlive(ctx.params['name']);
    ctx.sendBytes([1]);
    ctx.end();
  }
}

class RegisterNodeHandler implements HttpRequestHandler {
  final DatabaseHelpers _daemon;
  final Logger _logger = new Logger('$RegisterNodeHandler');

  RegisterNodeHandler(this._daemon);

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get route => '/node/:name';

  @override
  Future execute(HttpContext ctx) async {
    String name = ctx.params['name'];
    _daemon.registerNode(name).then((int port) {
      ctx.sendText(new RegistrationResult(name, port).toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      _logger.severe(e);
      _logger.severe(stacktrace);
      ctx.sendText(new RegistrationResult.failure().toString());
      ctx.end();
    });
  }
}

class DeregisterNodeHandler implements HttpRequestHandler {
  final DatabaseHelpers _daemon;
  final Logger _logger = new Logger('$DeregisterNodeHandler');

  DeregisterNodeHandler(this._daemon);

  @override
  HttpMethod get method => HttpMethod.delete;

  @override
  String get route => '/node/:name';

  @override
  Future execute(HttpContext ctx) async {
    String name = ctx.params['name'];
    _daemon.deregisterNode(name).then((_) {
      ctx.sendText(new DeregistrationResult(name, false).toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      _logger.severe(e);
      _logger.severe(stacktrace);
      ctx.sendText(new DeregistrationResult(e.toString(), true).toString());
      ctx.end();
    });
  }
}

class LookupNodeHandler implements HttpRequestHandler {
  final DatabaseHelpers _daemon;

  LookupNodeHandler(this._daemon);

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get route => '/node/:name';

  @override
  Future execute(HttpContext ctx) async {
    _daemon.lookupPort(ctx.params['name']).then((int port) {
      ctx.sendText(port.toString());
      ctx.end();
    });
  }
}

class ListNodesHandler implements HttpRequestHandler {
  final DatabaseHelpers _daemon;

  ListNodesHandler(this._daemon);

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  String get route => '/list/node';

  @override
  Future execute(HttpContext ctx) async {
    var nodes = _daemon.nodes;
    var ports = await Future.wait(nodes.map(_daemon.lookupPort));
    var assignments = <String, int>{};
    for (int i = 0; i < nodes.length; i++) {
      assignments[nodes.elementAt(i)] = ports[i];
    }
    ctx.sendText(new PortAssignmentList(assignments));
    ctx.end();
  }
}
