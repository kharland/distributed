import 'dart:async';

import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/objects.dart';

final matchAllMatcher = new RequestMatcher(r'/');
final pingMatcher = new RequestMatcher(r'/ping');
final listNodesMatcher = new RequestMatcher(r'/list/node');
final lookupNodeHandler = new RequestMatcher(r'/get/node');
final addNodeMatcher = new RequestMatcher(r'/add/node');
final removeNodeMatcher = new RequestMatcher(r'/remove/node');

class LoggingHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Logger _logger;

  LoggingHandler(this._matcher, this._logger);

  @override
  Future handle(ServerHttpRequest request) async {
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
  Future handle(ServerHttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    await request.first;
    request.response
      ..add('')
      ..close();
  }
}

class LookupNodeHandler extends RequestHandler {
  final RequestMatcher _matcher;

  final Logger _logger;
  final NodeDatabase _db;

  LookupNodeHandler(this._matcher, this._logger, this._db);

  @override
  Future handle(ServerHttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var name = await request.first;
    _logger.log('Looking up $name');
    _db.getPorts(name).then((NodePorts ports) {
      request.response
        ..add(ports.serialize())
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
  Future handle(ServerHttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var nodeName = await request.first;
    var nodePorts = NodePorts.deserialize(await request.last);
    _db.registerNode(nodeName, nodePorts).then((error) {
      _logger.log('Registered $nodeName');
      request.response.add('');
    }).catchError((e, stacktrace) {
      _logger..error(e)..error(stacktrace);
      request.response.add(e.toString());
    }).then((_) {
      request.response.close();
    });
  }
}

class RemoveNodeHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Logger _logger;
  final NodeDatabase _db;

  RemoveNodeHandler(this._matcher, this._logger, this._db);

  @override
  Future handle(ServerHttpRequest request) async {
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
