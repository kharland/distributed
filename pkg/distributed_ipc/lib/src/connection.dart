import 'package:distributed.ipc/src/internal/pipe.dart';
import 'package:distributed.ipc/src/message.dart';

/// A connection between two [Nodes].
abstract class Connection implements Pipe<NodeMessage> {
  /// This connection's local address.
  String get localAddress;

  /// This connection's local port.
  int get localPort;

  /// This connection's remote address.
  String get remoteAddress;

  /// This connection's remote port.
  int get remotePort;
}
