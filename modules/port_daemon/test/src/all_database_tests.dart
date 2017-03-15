import 'package:distributed.port_daemon/src/database.dart';
import 'package:test/test.dart';

import 'database_test.dart';

void main() {
  group('$MemoryDatabase', () {
    testDatabase(
        setup: () => new MemoryDatabase<String, String>(),
        teardown: () => null);
  });
}
