import 'dart:async';

import 'package:distributed.port_mapping_daemon/daemon.dart';
import 'package:distributed.port_mapping_daemon/src/api.dart';
import 'package:express/express.dart';
import 'package:fixnum/fixnum.dart';

//TODO: Add logging support to this library

abstract class RouteHandler {
  static const get = 'get';
  static const put = 'put';
  static const post = 'post';
  static const delete = 'delete';
  static const patch = 'patch';

  static const ACCEPT_ALL_COOKIE = '';

  final String _cookie;

  RouteHandler._([this._cookie = ACCEPT_ALL_COOKIE]);

  String get method;

  String get route;

  void execute(HttpContext ctx) {
    if (_cookie == ACCEPT_ALL_COOKIE || ctx.params['cookie'] == _cookie) {
      executeChild(ctx);
    } else {
      fail(ctx, 'Invalid cookie');
    }
  }

  void executeChild(HttpContext ctx);

  void fail(HttpContext ctx, String reason);
}

class PingHandler extends RouteHandler {
  PingHandler() : super._();

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/ping';

  @override
  void executeChild(HttpContext ctx) {
    ctx.sendBytes([1]);
    ctx.end();
  }

  @override
  void fail(HttpContext ctx, String reason) {
    throw new UnimplementedError();
  }
}

class RegisterNodeHandler extends RouteHandler {
  final Daemon _daemon;

  RegisterNodeHandler(this._daemon, String cookie) : super._(cookie);

  @override
  String get method => RouteHandler.post;

  @override
  String get route => '/node/:name';

  @override
  void executeChild(HttpContext ctx) {
    String name = ctx.params['name'];
    _daemon.registerNode(name).then((Int64 port) {
      ctx.sendText(new RegistrationResult(name, port).toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      print(e);
      print(stacktrace);
      fail(ctx, e.toString());
    });
  }

  @override
  void fail(HttpContext ctx, String reason) {
    ctx.sendText(new RegistrationResult.failure().toString());
    ctx.end();
  }
}

class DeregisterNodeHandler extends RouteHandler {
  final Daemon _daemon;

  DeregisterNodeHandler(this._daemon, String cookie) : super._(cookie);

  @override
  String get method => RouteHandler.delete;

  @override
  String get route => '/node/:name';

  @override
  void executeChild(HttpContext ctx) {
    String name = ctx.params['name'];
    _daemon.deregisterNode(name).then((_) {
      ctx.sendText(new DeregistrationResult(name, false).toString());
      ctx.end();
    }).catchError((e) {
      fail(ctx, name);
    });
  }

  @override
  void fail(HttpContext ctx, String reason) {
    ctx.sendText(new DeregistrationResult(reason, true).toString());
    ctx.end();
  }
}

class LookupNodeHandler extends RouteHandler {
  final Daemon _daemon;

  LookupNodeHandler(this._daemon, String cookie) : super._(cookie);

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/node/:name';

  @override
  void executeChild(HttpContext ctx) {
    _daemon.lookupPort(ctx.params['name']).then((Int64 port) {
      ctx.sendText(port.toString());
      ctx.end();
    });
  }

  @override
  void fail(HttpContext ctx, String reason) {
    ctx.sendText(reason);
    ctx.end();
  }
}

class ListNodesHandler extends RouteHandler {
  final Daemon _daemon;

  ListNodesHandler(this._daemon, String cookie) : super._(cookie);

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/list/node';

  @override
  void executeChild(HttpContext ctx) {
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

  @override
  void fail(HttpContext ctx, String reason) {
    ctx.sendText(reason);
    ctx.end();
  }
}
