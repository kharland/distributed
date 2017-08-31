import 'package:distributed.ipc/src/protocol/packet_channel.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram.dart';

class TypedDatagramRouter {
  final List<PacketChannel> _channels;

  void addChannel(PacketChannel channel) {
    _channels.add(channel);
  }

  void receiveDatagram(TypedDatagram datagram) {
    _channels.forEach((channel) {
      if (datagram.address == channel.remoteAddress &&
          datagram.port == channel.remotePort) {
        channel.receive(datagram.data);
      }
    });
  }
}
