import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/transfer_type.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';

// TODO: Accept address and port instead of config.

/// An I/O channel for transferring [Datagrams] between processes.
///
/// A [DataChannel] consumes [Iterable]s of [Datagram]s from the local client
/// and sends them over the network.  It consumes encoded [Datagram] data from the
/// network and broadcasts the decoded [Datagram]s locally.
abstract class DataChannel implements EventSource<Datagram>, Sink<List<int>> {
  /// Creates a [DataChannel].
  ///
  /// [config] is the [ConnectionConfic] to create the channel from.
  /// [writeData] is a callback for writing datagram data to the remote peer.
  factory DataChannel(ConnectionConfig config, DatagramSocket socket) {
    final UdpConfig udpConfig = config.protocolConfig;
    switch (udpConfig.transferType) {
      case TransferType.FAST:
        return new FastChannel(config, socket);
      default:
        throw new ArgumentError(udpConfig.transferType);
    }
  }

  /// The address of this channel's remote peer.
  String get remoteAddress;

  /// The port of this channel's remote peer.
  int get remotePort;

  @override
  void close() {
    throw new UnsupportedError('$DataChannel does not need closing');
  }
}

/// A [DataChannel] that does not wait for acknowledgement of datagrams.
///
/// All datagrams are immediately sent on the channel and no attempt is made to
/// verify whether the remote received each datagram.  This channel is lossy and
/// best used for applications that prioritize speed over reliability, such as
/// game-servers or streaming applications.
class FastChannel extends EventSource<Datagram> implements DataChannel {
  final DatagramSocket _socket;

  @override
  final String remoteAddress;

  @override
  final int remotePort;

  FastChannel(ConnectionConfig config, DatagramSocket socket)
      : this._(config.remoteAddress, config.remotePort, socket);

  FastChannel._(this.remoteAddress, this.remotePort, this._socket) {
    _socket.onEvent(emit);
  }

  @override
  void add(List<int> data) {
    _socket.add(new DataDatagram(remoteAddress, remotePort, data, 1));
  }

  @override
  void emit(Datagram datagram) {
    super.emit(datagram);
  }

  @override
  void close() {
    super.close();
  }
}
