import 'package:distributed.ipc/src/typedefs.dart';
import 'package:meta/meta.dart';

/// A connection between two [Nodes].
abstract class NodeConnection {
  /// This connection's remote address.
  String get remoteAddress;

  /// This connection's remote port.
  int get remotePort;

  /// This connection's local address.
  String get localAddress;

  /// This connection's local port.
  int get localPort;

  /// Sends [message] over this connection.
  void add(String message);

  /// Registers [callback] to be called when this connection receives a message.
  void onMessage(Consumer<String> callback);
}

@immutable
class NodeConnectionConfig {
  final String localAddress;
  final int localPort;

  final String remoteAddress;
  final int remotePort;

  @literal
  const NodeConnectionConfig({
    @required this.localAddress,
    @required this.localPort,
    @required this.remoteAddress,
    @required this.remotePort,
  });
}
