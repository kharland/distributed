import 'dart:async';

import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed.http/vm.dart';

// TODO: Refactor request framework to handle more than just POST requests.
final pingMatcher = new RequestMatcher(r'/ping');
final listNodesMatcher = new RequestMatcher(r'/list/node');
final lookupNodeHandler = new RequestMatcher(r'/get/node');
final addNodeMatcher = new RequestMatcher(r'/add/node');
final removeNodeMatcher = new RequestMatcher(r'/remove/node');
final matchAllMatcher = new RequestMatcher(r'/');

class LoggingHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Logger _logger;

  LoggingHandler(this._matcher, this._logger);

  @override
  Future handle(HttpRequest request) async {
    _logger.log('${request.method} ${request.uri.path}');
    super.handle(request);
  }
}

class PingHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Logger _logger;
  final NodeDatabase _db;

  PingHandler(this._matcher, this._logger, this._db);

  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var data = await request.first;
    _db.keepAlive(data);
    request.response
      ..add('PING')
      ..close();
  }
}

class ListNodesHandler extends RequestHandler {
  final RequestMatcher _matcher;

  final Logger _logger;
  final NodeDatabase _db;

  ListNodesHandler(this._matcher, this._logger, this._db);

  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var nodes = _db.nodes;
    var ports = await Future.wait(nodes.map(_db.getPort));
    var assignments = <String, int>{};
    for (int i = 0; i < nodes.length; i++) {
      assignments[nodes.elementAt(i)] = ports[i];
    }
    request.response
      ..add(serialize($portAssignmentList(assignments)))
      ..close();
  }
}

class LookupNodeHandler extends RequestHandler {
  final RequestMatcher _matcher;

  final Logger _logger;
  final NodeDatabase _db;

  LookupNodeHandler(this._matcher, this._logger, this._db);

  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var name = await request.first;
    _logger.log('Looking up $name');
    _db.getPort(name).then((int port) {
      request.response
        ..add(port.toString())
        ..close();
    }).catchError((e, stacktrace) {
      _logger..error(e)..error(stacktrace);
      request.response..add(Ports.error.toString());
    });
  }
}

class AddNodeHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Logger _logger;
  final NodeDatabase _db;

  AddNodeHandler(this._matcher, this._logger, this._db);

  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var name = await request.first;
    _db.registerNode(name).then((Registration registration) {
      _logger.log('Registered $name to ${registration.port}');
      request.response
        ..add(serialize(registration))
        ..close();
    }).catchError((e, stacktrace) {
      _logger..error(e)..error(stacktrace);
      request.response
        ..add(serialize($registration(Ports.error, e.toString())))
        ..close();
    });
  }
}

class RemoveNodeHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Logger _logger;
  final NodeDatabase _db;

  RemoveNodeHandler(this._matcher, this._logger, this._db);

  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);

    var name = await request.first;
    _db.deregisterNode(name).then((String result) {
      _logger.log('Deregistered $name');
      request.response
        ..add(result)
        ..close();
    }).catchError((e, stacktrace) {
      _logger..error(e)..error(stacktrace);
      request.response
        ..add(e.toString())
        ..close();
    });
  }
}
