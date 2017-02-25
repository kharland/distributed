import 'package:distributed.connection/connection.dart';

/// An interface for verifying whether a given [Connection] is safe.
///
/// It is left up to the implementer to define what "safe" means.
abstract class ConnectionGuard {
  /// Returns true iff [connection] is safe.
  ///
  /// If this method returns false, a standard response is to close [connection]
  /// immediately.
  bool isSafe(Connection connection);
}

/* Common connection guards */

/// A [ConnectionGuard] that warns when the number of concurrent connections
/// exceeds some specified limit.
class ConnectionLimit implements ConnectionGuard {
  /// The maximum number of allowed connections.
  final int maxConnections;

  /// The current number of open connections.
  int currentConnections = 0;

  ConnectionLimit(this.maxConnections);

  @override
  bool isSafe(_) => currentConnections + 1 <= maxConnections;
}

/// A [ConnectionGuard] that warns when the peer at the other end of a
/// [Connection] fails to correctly verify itself with some specified password.
class PasswordChecker implements ConnectionGuard {
  @override
  bool isSafe(Connection connection) {
    // TODO: implement isSafe
    return true;
  }
}
