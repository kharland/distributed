import 'dart:async';

import 'package:distributed.port_daemon/daemon.dart';
import 'package:distributed.port_daemon/src/api.dart';
import 'package:express/express.dart' hide Logger;
import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

abstract class RouteHandler {
  static const get = 'get';
  static const put = 'put';
  static const post = 'post';
  static const delete = 'delete';
  static const patch = 'patch';

  static const acceptAllCookie = '';

  final String _cookie;

  RouteHandler._([this._cookie = acceptAllCookie]);

  String get method;

  String get route;

  void execute(HttpContext ctx);

  void fail(HttpContext ctx, String reason, [String context = '']);
}

abstract class _AuthenticatingRouteHandler implements RouteHandler {
  final String _cookie;
  final Logger _logger;

  _AuthenticatingRouteHandler(this._cookie, this._logger);

  @override
  void execute(HttpContext ctx) {
    if (_cookie == RouteHandler.acceptAllCookie ||
        ctx.params['cookie'] == _cookie) {
      executeAuthenticated(ctx);
    } else {
      fail(ctx, 'Invalid cookie');
    }
  }

  @override
  @mustCallSuper
  void fail(HttpContext ctx, String reason, [String context = '']) {
    _logger.info('[request failed] $reason');
    if (context.isNotEmpty) {
      _logger.fine(context);
    }
  }

  void executeAuthenticated(HttpContext ctx);
}

class PingHandler extends _AuthenticatingRouteHandler {
  final Daemon _daemon;

  PingHandler(this._daemon, String cookie)
      : super(cookie, new Logger('$PingHandler'));

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/ping/:name';

  @override
  void executeAuthenticated(HttpContext ctx) {
    _daemon.acknowledgeNodeIsAlive(ctx.params['name']);
    ctx.sendBytes([1]);
    ctx.end();
  }

  @override
  void fail(HttpContext ctx, String reason, [String context = '']) {
    super.fail(ctx, reason, context);
    throw new UnimplementedError();
  }
}

class RegisterNodeHandler extends _AuthenticatingRouteHandler {
  final Daemon _daemon;

  RegisterNodeHandler(this._daemon, String cookie)
      : super(cookie, new Logger('$RegisterNodeHandler'));

  @override
  String get method => RouteHandler.post;

  @override
  String get route => '/node/:name';

  @override
  void executeAuthenticated(HttpContext ctx) {
    String name = ctx.params['name'];
    _daemon.registerNode(name).then((Int64 port) {
      ctx.sendText(new RegistrationResult(name, port).toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      fail(ctx, e.toString(), stacktrace.toString());
    });
  }

  @override
  void fail(HttpContext ctx, String reason, [String context = '']) {
    super.fail(ctx, reason, context);
    ctx.sendText(new RegistrationResult.failure().toString());
    ctx.end();
  }
}

class DeregisterNodeHandler extends _AuthenticatingRouteHandler {
  final Daemon _daemon;

  DeregisterNodeHandler(this._daemon, String cookie)
      : super(cookie, new Logger('$DeregisterNodeHandler'));

  @override
  String get method => RouteHandler.delete;

  @override
  String get route => '/node/:name';

  @override
  void executeAuthenticated(HttpContext ctx) {
    String name = ctx.params['name'];
    _daemon.deregisterNode(name).then((_) {
      ctx.sendText(new DeregistrationResult(name, false).toString());
      ctx.end();
    }).catchError((e, stacktrace) {
      fail(ctx, e.toString(), stacktrace.toString());
    });
  }

  @override
  void fail(HttpContext ctx, String reason, [String context = '']) {
    super.fail(ctx, reason, context);
    ctx.sendText(new DeregistrationResult(reason, true).toString());
    ctx.end();
  }
}

class LookupNodeHandler extends _AuthenticatingRouteHandler {
  final Daemon _daemon;

  LookupNodeHandler(this._daemon, String cookie)
      : super(cookie, new Logger('$LookupNodeHandler'));

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/node/:name';

  @override
  void executeAuthenticated(HttpContext ctx) {
    _daemon.lookupPort(ctx.params['name']).then((Int64 port) {
      ctx.sendText(port.toString());
      ctx.end();
    });
  }

  @override
  void fail(HttpContext ctx, String reason, [String context = '']) {
    super.fail(ctx, reason, context);
    ctx.sendText(reason);
    ctx.end();
  }
}

class ListNodesHandler extends _AuthenticatingRouteHandler {
  final Daemon _daemon;

  ListNodesHandler(this._daemon, String cookie)
      : super(cookie, new Logger('$ListNodesHandler'));

  @override
  String get method => RouteHandler.get;

  @override
  String get route => '/list/node';

  @override
  void executeAuthenticated(HttpContext ctx) {
    var nodes = _daemon.nodes;
    Future.wait(nodes.map(_daemon.lookupPort)).then((List<Int64> ports) {
      var assignments = <String, Int64>{};
      for (int i = 0; i < nodes.length; i++) {
        assignments[nodes.elementAt(i)] = ports[i];
      }
      ctx.sendText(new PortAssignmentList(assignments));
      ctx.end();
    });
  }

  @override
  void fail(HttpContext ctx, String reason, [String context = '']) {
    super.fail(ctx, reason, context);
    ctx.sendText(reason);
    ctx.end();
  }
}
