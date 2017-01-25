import 'connection_strategy_tests.dart' as connection_strategy_tests;
import 'daemon_based_node_finder_test.dart' as daemon_based_node_finder_test;
import 'socket_channels_test.dart' as socket_demux_test;

void main() {
  connection_strategy_tests.main();
  daemon_based_node_finder_test.main();
  socket_demux_test.main();
}
