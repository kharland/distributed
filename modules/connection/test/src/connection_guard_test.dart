import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/connection_guard.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$PasswordChecker', () {
    group('isSafe', () {
      test('should return true iff the given password is correct', () {});
    });
  });

  group('$ConnectionLimit', () {
    group('isSafe', () {
      test(
          'should return true iff the number of concurrent connections is '
          'less than the maximum number of allowed connections.', () {
        var guard = new ConnectionLimit(1)..currentConnections = 1;
        expect(guard.isSafe(new MockConnection()), isFalse);
      });
    });
  });

  group('$MultiGuard', () {
    group('isSafe', () {
      test(
          'should return true iff all of its delegate guards determine the '
          'connection is safe', () {
        var connectionLimitGuard = new ConnectionLimit(1);
        var guard = new MultiGuard([
          connectionLimitGuard,
          new ConnectionLimit(1),
        ]);

        expect(guard.isSafe(new MockConnection()), isTrue);

        connectionLimitGuard.currentConnections = 1;
        expect(guard.isSafe(new MockConnection()), isFalse);
      });
    });
  });
}

class MockConnection extends Mock implements Connection {}
