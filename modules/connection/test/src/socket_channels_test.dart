import 'dart:async';

import 'package:distributed.connection/src/socket/socket_channels.dart';
import 'package:distributed.connection/src/socket/socket_controller.dart';
import 'package:test/test.dart';

void main() {
  group('$SocketChannels', () {
    SocketChannels local;
    SocketChannels foreign;

    setUp(() async {
      var testConnection = new SocketController();
      await Future.wait([
        SocketChannels.outgoing(testConnection.foreign).then((channels) {
          foreign = channels;
        }),
        SocketChannels.incoming(testConnection.local).then((channels) {
          local = channels;
        })
      ]);
    });

    test('channels should only send and receive the appropriate messages',
        () async {
      local.user.sink.add('A');
      local.user.sink.add('B');
      local.system.sink.add('C');
      local.error.sink.add('D');

      var userMessages = await foreign.user.stream.take(2).toList();
      var systemMessage = await foreign.system.stream.first;
      var errorMessage = await foreign.error.stream.first;

      expect(userMessages, ['A', 'B']);
      expect(systemMessage, 'C');
      expect(errorMessage, 'D');
    });

    group('done', () {
      test('should complete when the local $SocketChannels close', () async {
        local.close();
        expect(local.done, completes);
      });
    });
  });
}
