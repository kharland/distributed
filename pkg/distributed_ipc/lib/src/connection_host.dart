import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_channel.dart';

typedef PacketChannelHandler = void Function(PacketChannel);

abstract class ConnectionHost {
  final PacketChannelHandler _onChannel;
  final Sink<GreetPacket> _greetSink;
  final String _address;
  final int _port;

  ConnectionHost(this._address, this._port, this._onChannel, this._greetSink);

  /// Creates a new [PacketChannel] from [config].
  void open(PacketChannelConfig config) {
    // Create packet channel at remote host by sending GREET packet with channel
    // information.
    _greetSink.add(new GreetPacket(
      config.address,
      config.port,
      encodingType: config.encodingType.value,
      transferType: config.transferType.value,
    ));

    _onChannel(new PacketChannel.fromConfig(config));
  }

  /// Opens a new [PacketChannel] configured from [greeting].
  ///
  /// Returns with the response [Packet] that should be sent to the remote.
  Packet receive(GreetPacket greeting) {
    try {
      final config = new PacketChannelConfig(
        greeting.address,
        greeting.port,
        transferType: new TransferType.fromValue(greeting.transferType),
        encodingType: new EncodingType.fromValue(greeting.encodingType),
      );

      _onChannel(new PacketChannel.fromConfig(config));
      return new Packet(PacketType.ACK, _address, _port);
    } catch (error) {
      return new ErrorPacket(_address, _port, '$error');
    }
  }
}
