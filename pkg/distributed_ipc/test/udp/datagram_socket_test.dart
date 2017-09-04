import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:distributed.ipc/src/udp/raw_udp_socket.dart';
import 'package:test/test.dart';

void main() {
  group(DatagramSocket, () {
    DatagramSocket localSocket;
    DatagramSocket foreignSocket;

    RawUdpSocket rawLocalSocket;
    RawUdpSocket rawForeignSocket;

    setUp(() async {
      rawLocalSocket = await RawUdpSocket.bind('127.0.0.1', 9090);
      rawForeignSocket = await RawUdpSocket.bind('127.0.0.1', 9091);

      localSocket = new DatagramSocket(rawLocalSocket);
      foreignSocket = new DatagramSocket(rawForeignSocket);
    });

    tearDown(() async {
      localSocket.close();
      foreignSocket.close();
    });

    test('should emit an event when a datagram is received', () {
      localSocket.onEvent(expectAsync1((Datagram datagram) {
        expect(datagram.type, DatagramType.ACK);
        expect(datagram.address, foreignSocket.address);
        expect(datagram.port, foreignSocket.port);
      }));

      foreignSocket.add(new Datagram(
        DatagramType.ACK,
        localSocket.address,
        localSocket.port,
      ));
    });
  });
}
