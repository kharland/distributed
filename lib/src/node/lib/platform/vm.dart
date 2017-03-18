import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/src/configuration.dart';
import 'package:distributed.node/src/node/vm_node.dart';

export 'package:distributed.node/node.dart';
export 'package:distributed.node/src/node/vm_node.dart';

void configureDistributed() {
  setNodeProvider(new _VmNodeProvider());
}

class _VmNodeProvider implements NodeProvider {
  @override
  Future<VmNode> spawn(String name, {Logger logger}) =>
      VmNode.spawn(name: name, logger: logger ?? new Logger(name));
}
