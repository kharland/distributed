import 'package:distributed/src/connection/test/test_all.dart'
    as connection_tests;
import 'package:distributed/src/monitoring/test/test_all.dart'
    as monitoring_tests;
import 'package:distributed/src/node/test/test_all.dart' as node_tests;
import 'package:distributed/src/port_daemon/test/test_all.dart'
    as port_daemon_tests;

void main() {
  connection_tests.main();
  monitoring_tests.main();
  node_tests.main();
  port_daemon_tests.main();
}
