@TestOn('vm')
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/src/networking/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/message_handlers.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('$PeerInfoMessageHandler', () {
    MockNode mockNode;
    MockPeerInfoMessage mockMessage;

    group('execute', () {
      setUp(() {
        mockNode = new MockNode();
        mockMessage = new MockPeerInfoMessage();
      });

      test('should not connect to other peers if the node is hidden.', () {
        when(mockMessage.sender).thenReturn(new Peer('foo', 'localhost'));
        when(mockNode.isHidden).thenReturn(true);
        new PeerInfoMessageHandler(mockNode).execute(mockMessage);
        verifyNever(mockNode.createConnection(any));
      });

      test(
          'should transitively connect to new peers if the node is not hidden.',
          () async {
        when(mockMessage.sender).thenReturn(new Peer('foo', 'localhost'));
        when(mockMessage.connectedPeers).thenReturn([
          new Peer('bar', 'localhost'),
          new Peer('bang', 'localhost'),
        ]);
        when(mockNode.isHidden).thenReturn(false);
        when(mockNode.peers).thenReturn([]);
        when(mockNode.toPeer()).thenReturn(new Peer('baz', 'localhost'));
        await new PeerInfoMessageHandler(mockNode).execute(mockMessage);
        verify(mockNode.createConnection(any)).called(2);
      });
    });
  });
}

class MockNode extends Mock implements Node {}

class MockPeerInfoMessage extends Mock implements PeerInfoMessage {}
