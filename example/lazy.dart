import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed/platform/vm.dart';

/// Spawns a node that does nothing.
Future main() async {
  configureDistributed();
  await Node.spawn('lazy', logger: new Logger('lazy'));
}
