import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/objects.dart';

HandlerCallback createRequestLogger(Logger logger) =>
    (ServerHttpRequest request, __) async {
      logger.log('${request.method} ${request.uri.path}');
    };

HandlerCallback createPingHandler(Logger logger, NodeDatabase db) =>
    (ServerHttpRequest request, Map<String, String> args) async {
      request.response
        ..add('')
        ..close();
    };

HandlerCallback createLookupNodeHandler(Logger logger, NodeDatabase db) =>
    (ServerHttpRequest request, Map<String, String> args) async {
      var name = await request.first;
      logger.log('Looking up $name');
      db.getPorts(name).then((NodePorts ports) {
        request.response
          ..add(ports.serialize())
          ..close();
      }).catchError((e, stacktrace) {
        logger..error(e)..error(stacktrace);
        request.response..add(Ports.error.toString());
      });
    };

HandlerCallback createAddNodeHandler(Logger logger, NodeDatabase db) =>
    (ServerHttpRequest request, Map<String, String> args) async {
      var nodeName = await request.first;
      var nodePorts = NodePorts.deserialize(await request.last);
      db.registerNode(nodeName, nodePorts).then((error) {
        logger.log('Registered $nodeName');
        request.response.add('');
      }).catchError((e, stacktrace) {
        logger..error(e)..error(stacktrace);
        request.response.add(e.toString());
      }).then((_) {
        request.response.close();
      });
    };

HandlerCallback createRemoveNodeHandler(Logger logger, NodeDatabase db) =>
    (ServerHttpRequest request, Map<String, String> args) async {
      var name = await request.first;
      db.deregisterNode(name).then((String result) {
        logger.log('Deregistered $name');
        request.response
          ..add(result)
          ..close();
      }).catchError((e, stacktrace) {
        logger..error(e)..error(stacktrace);
        request.response
          ..add(e.toString())
          ..close();
      });
    };
