import 'dart:async';

import 'package:distributed.node/interfaces/message.dart';
import 'package:distributed.node/interfaces/peer.dart';
import 'package:distributed.node/src/networking/message_channel.dart';
import 'package:echo_server/websocket.dart';
import 'package:test/test.dart';

void testChannel(
    {Future<MessageChannel> createChannel(WebSocketEchoServer echoServer)}) {
  group('', () {
    WebSocketEchoServer echoServer;
    MessageChannel channel;
    MessageChannel testChannel;

    setUpAll(() {
      echoServer = new WebSocketEchoServer('localhost', 8085)..start();
    });

    setUp(() async {
      channel = await createChannel(echoServer);
      testChannel = await createChannel(echoServer);
    });

    tearDownAll(() => echoServer.stop());

    tearDown(() async {
      echoServer.closeConnections();
      return Future.wait([channel.onClose, testChannel.onClose]);
    });

    test('onData should emit when data is recieved', () async {
      var message = new Message(new Peer('a', 'b'), '', 'A');

      testChannel.send(message);
      expect((await channel.onMessage.first).data, message.data);
    });

    test('send should send data', () async {
      var message = new Message(new Peer('a', 'b'), '', 'A');

      channel.send(message);
      expect((await testChannel.onMessage.first).data, message.data);
    });

    test('close should close the channel', () async {
      channel.close();
      expect(channel.onClose, completes);
    });

    test('should close when the remote closes the connection', () async {
      // TODO(kharland): find a better way to ensure closeConnection() is called
      // after the message channel is connected.
      channel.send(new Message(new Peer('a', 'b'), '', 'A'));
      await testChannel.onMessage.first;
      echoServer.closeConnections();
      expect(channel.onClose, completes);
    });
  });
}
