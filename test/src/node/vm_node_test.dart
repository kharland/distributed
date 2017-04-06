import 'package:distributed/platform/vm.dart';

import 'common_node_tests.dart';

void main() {
  configureDistributed(testing: true);
  run();
}

void run() {
  runNodeTests();
}
