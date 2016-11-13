import 'dart:async';

import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/io/node.dart';
import 'package:seltzer/platform/server.dart';

export 'package:distributed/src/io/node_repl.dart' show NodeREPL;

void configureDistributed() {
  useSeltzerInTheServer();
  setNodeProvider(new IONodeProvider());
}

class IONodeProvider implements NodeProvider {
  @override
  Future<IONode> create(String name, String hostname, String cookie,
          {int port: 9095, bool hidden: false}) =>
      IONode.create(
          name: name,
          hostname: hostname,
          port: port,
          cookie: cookie,
          isHidden: hidden);
}
