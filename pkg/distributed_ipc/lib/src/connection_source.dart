import 'package:distributed.ipc/src/connection.dart';
import 'package:distributed.ipc/src/connection_config.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';

/// Notifies consumers when a [Connection] is opened.
abstract class ConnectionSource extends EventSource<Connection> {
  /// Attempts to open a connection configured from [config].
  ///
  /// A consumer can obtain the new connection by subscribing via [onEvent].
  void open(ConnectionConfig config);
}
