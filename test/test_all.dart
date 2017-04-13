import 'package:distributed/platform/vm.dart';

import 'src/connection/message_channel_test.dart' as message_channel_test;
import 'src/connection/message_router_test.dart' as message_router_test;
import 'src/connection/peer_verifier_test.dart' as peer_verification_test;
import 'src/http/vm_testing/network_address_test.dart' as network_address_test;
import 'src/http/vm_testing/network_emulator_test.dart'
    as network_emulator_test;
import 'src/http/vm_testing/test_http_provider_test.dart'
    as test_http_provider_test;
import 'src/http_server_builder/http_server_builder_test.dart'
    as http_server_builder_test;
import 'src/http_server_builder/request_template_test.dart'
    as request_template_test;
import 'src/http_server_builder/request_handler_test.dart'
    as request_handler_test;
import 'src/monitoring/file_system_test.dart' as file_system_test;
import 'src/monitoring/periodic_function_test.dart' as periodic_function_test;
import 'src/monitoring/signal_monitor_test.dart' as resource_test;
import 'src/node/remote_control/remote_control_request_handlers_test.dart'
    as remote_control_handlers_test;
import 'src/node/remote_control/node_command_test.dart' as node_command_test;
import 'src/node/vm_node_test.dart' as vm_node_test;
import 'src/port_daemon/client_test.dart' as port_daemon_client_test;
import 'src/port_daemon/database_test.dart' as database_test;
import 'src/port_daemon/node_database_test.dart' as node_database_test;

void main() {
  configureDistributed(testing: true);

  /* HTTP tests */
  network_address_test.main();
  network_emulator_test.main();
  test_http_provider_test.main();

  /* HTTP server builder tests */
  http_server_builder_test.main();
  request_handler_test.main();
  request_template_test.main();

  /* Connection tests */
  message_channel_test.main();
  message_router_test.main();
  peer_verification_test.main();

  /* Monitoring tests */
  file_system_test.main();
  periodic_function_test.main();
  resource_test.main();

  /* Node tests */
  node_command_test.main();
  remote_control_handlers_test.main();
  //vm_node_test.run();

  /* Port daemon tests */
  database_test.main();
  node_database_test.main();
  port_daemon_client_test.main();
}
