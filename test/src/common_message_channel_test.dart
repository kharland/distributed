import 'dart:async';

import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/system_payloads.dart';
import 'package:distributed/src/networking/message_channel.dart';
import 'package:echo_server/websocket.dart';
import 'package:test/test.dart';

void testChannel(
    {Future<MessageChannel> createChannel(WebSocketEchoServer echoServer)}) {
  group('', () {
    WebSocketEchoServer echoServer;
    MessageChannel channel;
    MessageChannel remoteChannel;

    setUpAll(() {
      echoServer = new WebSocketEchoServer('localhost', 8085)..start();
    });

    setUp(() async {
      channel = await createChannel(echoServer);
      remoteChannel = await createChannel(echoServer);
    });

    tearDownAll(() => echoServer.stop());

    tearDown(() async {
      echoServer.closeConnections();
      return Future.wait([channel.onClose, remoteChannel.onClose]);
    });

    test('onData should emit when data is recieved', () async {
      var message = new Message(new Peer('a', 'b'), '', 'A');

      remoteChannel.send(message);
      expect((await channel.onMessage.first).data, message.data);
    });

    test('send should send data', () async {
      var message = new Message(new Peer('a', 'b'), '', 'A');

      channel.send(message);
      expect((await remoteChannel.onMessage.first).data, message.data);
    });

    test('close should close the channel', () async {
      channel.close();
      expect(channel.onClose, completes);
    });
  });
}
