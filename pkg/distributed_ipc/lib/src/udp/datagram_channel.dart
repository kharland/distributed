import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:distributed.ipc/src/transfer_type.dart';

/// An I/O channel for transferring [Datagrams] between processes.
///
/// A [DatagramChannel] consumes [Iterable]s of [Datagram]s from the local client
/// and sends them over the network.  It consumes encoded [Datagram] data from the
/// network and broadcasts the decoded [Datagram]s locally.
abstract class DatagramChannel
    implements EventSource<Datagram>, Sink<Datagram> {
  /// Creates a [DatagramChannel].
  ///
  /// [config] is the [ConnectionConfic] to create the channel from.
  /// [writeData] is a callback for writing datagram data to the remote peer.
  factory DatagramChannel(ConnectionConfig config, DatagramSocket socket) {
    final UdpConfig udpConfig = config.protocolConfig;
    switch (udpConfig.transferType) {
      case TransferType.FAST:
        return new FastDatagramChannel(config, socket);
      default:
        throw new ArgumentError(udpConfig.transferType);
    }
  }

  /// The address of this channel's remote peer.
  String get remoteAddress;

  /// The port of this channel's remote peer.
  int get remotePort;

  /// Sends [datagram] on this channel.
  void add(Datagram datagram);

  /// Sends [datagrams] on this channel.
  void addAll(Iterable<Datagram> datagrams);

  @override
  void close() {
    throw new UnsupportedError('$DatagramChannel does not need closing');
  }
}

/// A [DatagramChannel] that does not wait for acknowledgement of datagrams.
///
/// All datagrams are immediately sent on the channel and no attempt is made to
/// verify whether the remote received each datagram.  This channel is lossy and
/// best used for applications that prioritize speed over reliability, such as
/// game-servers or streaming applications.  The remote is not expected to send
/// end datagrams.  They are assumed after each [Datagram].
class FastDatagramChannel extends EventSource<Datagram>
    implements DatagramChannel {
  final DatagramSocket _socket;

  @override
  final String remoteAddress;

  @override
  final int remotePort;

  FastDatagramChannel(ConnectionConfig config, DatagramSocket socket)
      : this._(config.remoteAddress, config.remotePort, socket);

  FastDatagramChannel._(this.remoteAddress, this.remotePort, this._socket) {
    _socket.onEvent(emit);
  }

  @override
  void add(Datagram datagram) {
    _socket.add(datagram);
  }

  @override
  void addAll(Iterable<Datagram> datagrams) {
    datagrams.forEach(add);
  }

  @override
  void emit(Datagram datagram) {
    super.emit(datagram);
    super.emit(
      new Datagram(DatagramType.END, datagram.address, datagram.port),
    );
  }

  @override
  void close() {
    super.close();
  }
}
