import 'dart:async';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/io/node.dart';
import 'package:seltzer/platform/server.dart';

void configureDistributed() {
  useSeltzerInTheServer();
  setNodeProvider(_createNode);
}

/// Creates a new [Node] identified by [name] and [hostname].
Future<IONode> _createNode(String name, String hostname, String cookie,
        {int port: 9095, bool hidden: false}) =>
    IONode.create(
        name: name,
        hostname: hostname,
        port: port,
        cookie: cookie,
        isHidden: hidden);
