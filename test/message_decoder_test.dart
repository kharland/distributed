@TestOn('vm')
import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/json.dart';
import 'package:distributed/src/networking/message_decoders.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  MessageDecoder decoder;

  setUp(() {
    decoder = new MessageDecoder();
  });

  group('decode', () {
    final peerInfoMessageJson = Json.encode(<String, Object>{
      "peer": {
        "name": "foo",
        "hostname": "host",
        "port": 9090,
        "isHidden": false
      },
      "connectedPeers": [
        {"name": "bar", "hostname": "host", "port": 9090, "isHidden": true}
      ]
    });

    test('should return a $PeerInfoMessage from a JSON string representation',
        () {
      expect(
          decoder.decode('PeerInfoMessage', peerInfoMessageJson),
          new PeerInfoMessage(
              new Peer('foo', 'host', port: 9090, isHidden: false),
              [new Peer('bar', 'host', port: 9090, isHidden: true)]));
    });
  });

  test('canDecode should return true iff the given format is registered', () {
    expect(decoder.canDecode('PeerInfoMessage'), isTrue);
    expect(decoder.canDecode('DisconnectMessage'), isTrue);
    expect(decoder.canDecode('UnregisteredFormat'), isFalse);

    decoder.addFormat('UnregisteredFormat', (String _) => null);
    expect(decoder.canDecode('UnregisteredFormat'), isTrue);
  });

  test('addFormat should enable the decoder to decode the new message format',
      () {
    var mockMessage = new MockMessage();
    var newFormat = 'NewFormat';

    expect(() => decoder.decode(newFormat, ''), throwsUnsupportedError);

    decoder.addFormat(newFormat, (String _) => mockMessage);
    expect(decoder.decode(newFormat, ''), mockMessage);
  });
}

class MockMessage extends Mock implements Message {}
