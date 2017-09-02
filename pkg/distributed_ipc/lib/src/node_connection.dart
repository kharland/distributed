import 'package:distributed.ipc/src/node_message.dart';
import 'package:distributed.ipc/src/pipe.dart';
import 'package:meta/meta.dart';

/// A connection between two [Nodes].
abstract class NodeConnection implements Pipe<NodeMessage> {
  /// This connection's local address.
  String get localAddress;

  /// This connection's local port.
  int get localPort;

  /// This connection's remote address.
  String get remoteAddress;

  /// This connection's remote port.
  int get remotePort;
}

/// Descibres how a [NodeConnection] should be created.
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
