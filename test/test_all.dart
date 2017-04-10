import 'package:distributed/platform/vm.dart';

import 'src/connection/message_channel_test.dart' as message_channel_test;
import 'src/connection/message_router_test.dart' as message_router_test;
import 'src/connection/peer_verifier_test.dart' as peer_verification_test;
import 'src/http/vm_testing/network_address_test.dart' as network_address_test;
import 'src/http/vm_testing/network_emulator_test.dart'
    as network_emulator_test;
import 'src/http/vm_testing/test_http_provider_test.dart'
    as test_http_provider_test;
import 'src/http_server/server_builder_test.dart' as http_server_builder_test;
import 'src/monitoring/file_system_test.dart' as file_system_test;
import 'src/monitoring/periodic_function_test.dart' as periodic_function_test;
import 'src/monitoring/signal_monitor_test.dart' as resource_test;
import 'src/node/control_handlers_test.dart' as control_handlers_test;
import 'src/node/vm_node_test.dart' as vm_node_test;
import 'src/port_daemon/client_test.dart' as client_test;
import 'src/port_daemon/database_test.dart' as database_test;
import 'src/port_daemon/node_database_test.dart' as node_database_test;

void main() {
  configureDistributed(testing: true);
  network_emulator_test.main();
  network_address_test.main();
  test_http_provider_test.main();
  http_server_builder_test.main();
  control_handlers_test.main();
  message_channel_test.main();
  message_router_test.main();
  periodic_function_test.main();
  resource_test.main();
  file_system_test.main();
  peer_verification_test.main();
  vm_node_test.run(); // Hanging after completion.
  client_test.main();
  database_test.main();
  node_database_test.main(); // Hanging after completion
}
