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
          'should return true iff the number of conncurrent connections is '
          'less than the maximum number of allowed connections.', () {
        expect(
            new ConnectionLimit(1)
              ..currentConnections = 1
              ..isSafe(new MockConnection()),
            isFalse);
      });
    });
  });
}

class MockConnection extends Mock implements Connection {}
