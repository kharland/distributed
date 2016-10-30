import 'package:distributed/src/networking/message_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:echo_server/websocket.dart';
import 'package:test/test.dart';

import 'src/common_message_channel_test.dart';

void main() {
  group('io $MessageChannel', () {
    testChannel(
        createChannel: (WebSocketEchoServer echoServer) async =>
            new MessageChannel.from(
                new IOWebSocketChannel.connect(echoServer.url)));
  });
}
