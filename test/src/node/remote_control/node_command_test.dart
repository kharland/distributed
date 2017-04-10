import 'package:distributed/distributed.dart';
import 'package:distributed/src/node/remote_control/node_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('${NodeCommand}s', () {
    final testPeer = new Peer('test', HostMachine.localHost);
    MockNode mockNode;

    setUp(() {
      mockNode = new MockNode();
    });

    test('$ConnectCommand should call `Node.connect`', () async {
      await new ConnectCommand(testPeer).execute(mockNode);
      verify(mockNode.connect(testPeer));
    });

    test('$DisconnectCommand should call `Node.disconnect`', () async {
      await new DisconnectCommand(testPeer).execute(mockNode);
      verify(mockNode.disconnect(testPeer));
    });
  });
}

class MockNode extends Mock implements Node {}
