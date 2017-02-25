import 'src/connection_guard_test.dart' as connection_guard_test;
import 'src/socket_channels_test.dart' as socket_channels_test;
import 'src/socket_test.dart' as socket_test;

void main() {
  connection_guard_test.main();
  socket_test.main();
  socket_channels_test.main();
}
