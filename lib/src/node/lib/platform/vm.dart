import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/configuration.dart';

export 'package:distributed.node/node.dart';
export 'package:distributed.node/src/node/vm_node.dart';

void configureDistributed() {
  setNodeProvider(new _VmNodeProvider());
}

class _VmNodeProvider implements NodeProvider {
  @override
  Node create(
    String name, {
    String hostname,
    bool isHidden: false,
  }) =>
      throw new UnimplementedError();
}
