import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/internal/pipe.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_channel.dart';
import 'package:distributed.ipc/src/udp/transfer_type.dart';

class UdpChannelRequestSource extends EventSource<DatagramChannelConfig> {
  UdpChannelRequestSource(
      Pipe<Datagram> pipe, DatagramFactory datagramFactory) {
    pipe.onEvent((Datagram datagram) {
      if (datagram.type == DatagramType.GREET) {
        GreetDatagram greeting = datagram;
        Datagram response;

        try {
          emit(new DatagramChannelConfig(
            greeting.address,
            greeting.port,
            pipe,
            transferType: new TransferType.fromValue(greeting.transferType),
            encodingType: new EncodingType.fromValue(greeting.encodingType),
          ));
          response = datagramFactory.ack();
        } catch (error) {
          response = datagramFactory.error('$error');
        }

        pipe.add(response);
      }
    });
  }
}

/// A source of [DatagramChannel]s.
///
/// A [DatagramChannel] is created when [open] is invoked on this source locally
/// or when a [Datagram] with [DatagramType.GREET] is received by this source.
abstract class PDatagramChannelSource extends EventSource<DatagramChannel> {
  final Pipe<Datagram> _pipe;
  final String _address;
  final int _port;

  PDatagramChannelSource(this._address, this._port, this._pipe) {
    _pipe.onEvent((Datagram datagram) {
      if (datagram.type == DatagramType.GREET) {
        _pipe.add(_receive(datagram));
      }
    });
  }

  /// Creates a new [DatagramChannel] from [config].
  ///
  /// Each subscriber of this [EventSource] will be notified of the new channel.
  void open(DatagramChannelConfig config) {
    // Create datagram channel at remote host by sending GREET datagram with channel
    // information.
    _pipe.add(new GreetDatagram(
      config.address,
      config.port,
      encodingType: config.encodingType.value,
      transferType: config.transferType.value,
    ));

    emit(new DatagramChannel(config));
  }

  /// Opens a new [DatagramChannel] configured from [greeting].
  ///
  /// Returns with the response [Datagram] that should be sent to the remote.
  Datagram _receive(GreetDatagram greeting) {
    try {
      final config = new DatagramChannelConfig(
        greeting.address,
        greeting.port,
        _pipe,
        transferType: new TransferType.fromValue(greeting.transferType),
        encodingType: new EncodingType.fromValue(greeting.encodingType),
      );

      emit(new DatagramChannel(config));
      return new Datagram(DatagramType.ACK, _address, _port);
    } catch (error) {
      return new ErrorDatagram(_address, _port, '$error');
    }
  }
}
