import 'src/message_channel_test.dart' as message_channel_test;
import 'src/database_test.dart' as database_test;
import 'src/file_system_test.dart' as file_system_test;
import 'src/node_database_test.dart' as node_database_test;
import 'src/peer_verifier_test.dart' as peer_verification_test;
import 'src/periodic_function_test.dart' as periodic_function_test;
import 'src/signal_monitor_test.dart' as resource_test;
import 'src/message_router_test.dart' as message_router_test;
import 'src/vm_node_test.dart' as vm_node_test;
import 'src/client_server_test.dart' as client_server_test;
import 'src/http_server/router_test.dart' as router_test;

void main() {
  router_test.main();
  message_channel_test.main();
  message_router_test.main();
  periodic_function_test.main();
  resource_test.main();
  file_system_test.main();
  peer_verification_test.main();
  vm_node_test.main();
  client_server_test.main();
  database_test.main();
  node_database_test.main();
}
