import 'package:distributed.ipc/src/protocol.dart';
import 'package:meta/meta.dart';

/// Describes how a [Connection] should be created.
@immutable
class ConnectionConfig {
  final Protocol protocol;
  final String localAddress;
  final int localPort;
  final String remoteAddress;
  final int remotePort;

  @literal
  const ConnectionConfig({
    @required this.localAddress,
    @required this.localPort,
    @required this.remoteAddress,
    @required this.remotePort,
    this.protocol: Protocol.upd,
  });
}
