import 'dart:async';

import 'package:distributed.port_mapping_daemon/daemon.dart';
import 'package:distributed.port_mapping_daemon/src/api.dart';
import 'package:express/express.dart';
import 'package:meta/meta.dart';

//TODO: Add logging support to this library

abstract class RouteHandler {
  static const get = 'get';
  static const put = 'put';
  static const post = 'post';
  static const delete = 'delete';
  static const patch = 'patch';

  String get method;

  String get route;

  void run(HttpContext ctx);
}

class PingHandler implements RouteHandler {
  @literal
  const PingHandler();

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/ping';

  @override
  void run(HttpContext ctx) {
    ctx.sendBytes([1]);
    ctx.end();
  }
}

class RegisterNodeHandler implements RouteHandler {
  final Daemon _daemon;

  @literal
  const RegisterNodeHandler(this._daemon);

  @override
  String get method => RouteHandler.post;

  @override
  String get route => '/node/:name';

  @override
  void run(HttpContext ctx) {
    String name = ctx.params['name'];
    _daemon.registerNode(name).then((int port) {
      ctx.sendText(new RegistrationResult(name, port).toString());
      ctx.end();
    }).catchError((e) {
      ctx.sendText(new RegistrationResult.failure().toString());
      ctx.end();
    });
  }
}

class DeregisterNodeHandler implements RouteHandler {
  final Daemon _daemon;

  @literal
  const DeregisterNodeHandler(this._daemon);

  @override
  String get method => RouteHandler.delete;

  @override
  String get route => '/node/:name';

  @override
  void run(HttpContext ctx) {
    String name = ctx.params['name'];
    _daemon.deregisterNode(name).then((_) {
      ctx.sendText(new DeregistrationResult(name, false).toString());
      ctx.end();
    }).catchError((e) {
      ctx.sendText(new DeregistrationResult(name, true).toString());
      ctx.end();
    });
  }
}

class LookupNodeHandler implements RouteHandler {
  final Daemon _daemon;

  @literal
  const LookupNodeHandler(this._daemon);

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/node/:name';

  @override
  void run(HttpContext ctx) {
    _daemon.lookupPort(ctx.params['name']).then((int port) {
      ctx.sendText(port.toString());
      ctx.end();
    });
  }
}

class ListNodesHandler implements RouteHandler {
  final Daemon _daemon;

  @literal
  const ListNodesHandler(this._daemon);

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/list/node';

  @override
  void run(HttpContext ctx) {
    var nodes = _daemon.nodes;
    Future.wait(nodes.map(_daemon.lookupPort)).then((List<int> ports) {
      var assignments = <String, int>{};
      for (int i = 0; i < nodes.length; i++) {
        assignments[nodes.elementAt(i)] = ports[i];
      }
      ctx.sendText(new PortAssignmentList(assignments));
      ctx.end();
    });
  }
}
