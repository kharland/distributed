import 'dart:async';

import 'package:distributed.node/src/logging.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/src/api.dart';
import 'package:distributed.port_daemon/src/database_helpers.dart';
import 'package:express/express.dart' hide Logger;

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
    _daemon.keepAlive(ctx.params['name']);
    ctx.sendBytes([1]);
    ctx.end();
  }
}

class RegisterNodeHandler implements HttpRequestHandler {
  final DatabaseHelpers _daemon;

  RegisterNodeHandler(this._daemon);

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  String get route => '/node/:name';

  @override
  Future execute(HttpContext ctx) async {
    String name = ctx.params['name'];
    _daemon.registerNode(name).then((int port) {
      ctx.sendText(serialize(createRegistration(name, port), Registration));
      ctx.end();
    }).catchError((e, stacktrace) {
      globalLogger.error(e);
      globalLogger.error(stacktrace);
      ctx.sendText(serialize(createRegistration(), Registration));
      ctx.end();
    });
  }
}

class DeregisterNodeHandler implements HttpRequestHandler {
  final DatabaseHelpers _daemon;

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
      globalLogger.error(e);
      globalLogger.error(stacktrace);
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

class HttpMethod {
  final String value;

  const HttpMethod._(this.value);

  static const HttpMethod get = const HttpMethod._('get');
  static const HttpMethod put = const HttpMethod._('put');
  static const HttpMethod post = const HttpMethod._('post');
  static const HttpMethod delete = const HttpMethod._('delete');
}
