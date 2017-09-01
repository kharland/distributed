import 'package:distributed.ipc/src/node_connection.dart';
import 'package:distributed.ipc/src/protocol/data_builder.dart';
import 'package:distributed.ipc/src/protocol/datagram_socket.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_channel.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:distributed.ipc/src/event_source.dart';

/// A [NodeConnection] used a by a node running on the Dart vm.
abstract class VmNodeConnection implements NodeConnection, EventSource<String> {
  /// Creates a new [NodeConnection] that uses the UDP protocol.
  static NodeConnection openUdp(
    DatagramSocket socket,
    NodeConnectionConfig config,
  ) {
    PacketChannel channel;
    final connection = new _ControlledConnection(config);

    DataPacket createDataPacket(List<int> data, int position) =>
        new DataPacket(config.localAddress, config.localPort, data, position);

    Datagram createDatagram(List<int> data) =>
        new Datagram(data, config.localAddress, config.localPort);

    socket.onEvent((Datagram dg) {
      if (dg.type != DatagramType.GREET &&
          dg.address == config.remoteAddress &&
          dg.port == config.remotePort) {
        channel.receive(dg.data);
      }
    });

    channel = new PacketChannel.fromConfig(
      new PacketChannelConfig(config.remoteAddress, config.remotePort),
      writeData: (List<int> data) => socket.add(createDatagram(data)),
    );

    // Buffer incoming packets before emitting a received message.
    final dataBuilder = new StringDataBuilder(createDataPacket);
    final packetBuffer = <Packet>[];

    channel.onEvent((Packet packet) {
      if (packet.type == PacketType.END) {
        connection.receive(dataBuilder.construct(packetBuffer));
      } else {
        packetBuffer.add(packet);
      }
    });

    return connection;
  }
}

class _VmNodeConnectionImpl extends EventSource<String>
    implements VmNodeConnection {
  final NodeConnectionConfig _config;
  final _messageHandlers = <Consumer<String>>[];

  _VmNodeConnectionImpl(this._config);

  @override
  String get localAddress => _config.localAddress;

  @override
  int get localPort => _config.localPort;

  @override
  String get remoteAddress => _config.remoteAddress;

  @override
  int get remotePort => _config.remotePort;

  @override
  void add(String message) {}
}

/// A [VmNodeConnection] whose incoming messages are manually emitted.
class _ControlledConnection extends _VmNodeConnectionImpl {
  _ControlledConnection(NodeConnectionConfig config) : super(config);

  void receive(String message) {
    _messageHandlers.forEach((handler) {
      handler(message);
    });
  }
}