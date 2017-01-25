import 'package:distributed.net/secret.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/configuration.dart';
import 'package:seltzer/platform/vm.dart' as seltzer;

export 'package:distributed.node/src/io/io_node.dart';

void configureDistributed() {
  setNodeProvider(new _IONodeProvider());
  seltzer.useSeltzerInVm();
}

class _IONodeProvider implements NodeProvider {
  @override
  Node create(
    String name, {
    String hostname,
    Secret secret,
    bool isHidden: false,
  }) =>
      throw new UnimplementedError();
}
