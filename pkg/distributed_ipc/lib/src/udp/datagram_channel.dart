import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/internal/pipe.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/transfer_type.dart';

/// Specifies the settings necessary to create a [DatagramChannel].
class DatagramChannelConfig {
  final TransferType transferType;
  final EncodingType encodingType;
  final String address;
  final int port;
  final Pipe<Datagram> pipe;

  DatagramChannelConfig(
    this.address,
    this.port,
    this.pipe, {
    this.transferType: TransferType.FAST,
    this.encodingType: EncodingType.UTF8,
  });
}

/// An I/O channel for transferring [Datagrams] between processes.
///
/// A [DatagramChannel] consumes [Iterable]s of [Datagram]s from the local client
/// and sends them over the network.  It consumes encoded [Datagram] data from the
/// network and broadcasts the decoded [Datagram]s locally.
abstract class DatagramChannel implements EventSource<Datagram> {
  /// Creates a [DatagramChannel].
  ///
  /// [config] is the [DatagramChannelConfig] to create the channel from.
  /// [writeData] is a callback for writing datagram data to the remote peer.
  factory DatagramChannel(DatagramChannelConfig config) {
    switch (config.transferType) {
      case TransferType.FAST:
        return new FastDatagramChannel(config);
      default:
        throw new ArgumentError(config.transferType);
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

  /// Receives a [datagram] sent from [remoteAddress] and [remotePort].
  void receive(Datagram datagram);
}

/// A [DatagramChannel] that does not wait for acknowledgement of datagrams.
///
/// All datagrams are immediately sent on the channel and no attempt is made to
/// verify whether the remote received each datagram.  This channel is lossy and
/// best used for applications that prioritize speed over reliability, such as
/// game-servers or streaming applications.
///
/// The remote is not expected to send end datagrams.  They are assumed after each
/// [Datagram].
class FastDatagramChannel extends EventSource<Datagram>
    implements DatagramChannel {
  final Pipe<Datagram> _pipe;

  @override
  final String remoteAddress;

  @override
  final int remotePort;

  FastDatagramChannel(DatagramChannelConfig config)
      : this._(config.address, config.port, config.pipe);

  FastDatagramChannel._(
    this.remoteAddress,
    this.remotePort,
    this._pipe,
  ) {
    _pipe.onEvent(receive);
  }

  @override
  void add(Datagram datagram) {
    _pipe.add(datagram);
  }

  @override
  void addAll(Iterable<Datagram> datagrams) {
    datagrams.forEach(add);
  }

  @override
  void receive(Datagram datagram) {
    emitAll([
      datagram,
      new Datagram(DatagramType.END, datagram.address, datagram.port),
    ]);
  }
}
