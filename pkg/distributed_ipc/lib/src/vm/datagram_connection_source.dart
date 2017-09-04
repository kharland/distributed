import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/connection_impl.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/transfer_type.dart';
import 'package:distributed.ipc/src/udp/data_builder.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_channel.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:distributed.ipc/src/vm/datagram_message_sink.dart';
import 'package:distributed.ipc/src/vm/datagram_message_source.dart';
import 'package:meta/meta.dart';

/// A [ConnectionSource] that initiates connections using [Datagram]s.
///
/// Creating a connection remotely:
/// --
/// When a [Datagram] with [DatagramType.GREET] is recieved, a [Connection] is
/// emitted locally and a confirmation is sent to the initiating peer.  It is
/// assumed that the peer recieved acknowledgement and is ready to recieve
/// messages.
///
/// Creating a connection locally.
/// When a connection is created at this source, a [Datagram] with
/// [DatagramType.GREET] is sent to the remote [DatagramConnectionSource]. If no
/// confirmation of the connection is recieved, no [Connection] object is
/// created.  Instead, a [ConnectionException] is raised.
class DatagramConnectionSource extends EventSource<Connection>
    implements ConnectionSource {
  final DatagramSocket _socket;

  DatagramConnectionSource(this._socket) {
    _socket.onEvent((datagram) {
      if (datagram.type == DatagramType.GREET) {
        _createConnectionFromGreeting(datagram);
      }
    });
  }

  @override
  void open(ConnectionConfig config) {
    _createConnection(config);
  }

  /// Creates a connection, using a configuration derived from [greeting].
  void _createConnectionFromGreeting(GreetDatagram greeting) {
    final config = new ConnectionConfig(
        remoteAddress: greeting.address,
        remotePort: greeting.port,
        protocolConfig: new UdpConfig(
          transferType: new TransferType.fromValue(greeting.transferType),
          encodingType: new EncodingType.fromValue(greeting.encodingType),
        ));
    _createConnection(config);
  }

  /// Creates a connection from [config].
  void _createConnection(ConnectionConfig config) {
    final channel = new DatagramChannel(config, _socket);
    final dataBuilder =
        new DataBuilder((List<int> data, int pos) => new DataDatagram(
              channel.remoteAddress,
              channel.remotePort,
              data,
              pos,
            ));

    final messageSink = new DatagramMessageSink(channel, dataBuilder);
    final messageSource = new DatagramMessageSource(channel, dataBuilder);

    final connection = new ConnectionImpl(
      messageSource,
      messageSink,
      localAddress: _socket.address,
      localPort: _socket.port,
      remoteAddress: config.remoteAddress,
      remotePort: config.remotePort,
    );

    emit(connection);
  }
}

@immutable
class ConnectionException implements Exception {
  final String message;

  @literal
  ConnectionException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}
