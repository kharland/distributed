import 'dart:async';

import 'package:distributed.connection/src/socket_channels.dart';
import 'package:distributed.connection/src/socket_controller.dart';
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
      local
        ..sendToUser('A')
        ..sendToUser('B')
        ..sendToSystem('C');

      expect(foreign.userStream, emitsInOrder(['A', 'B']));
      expect(foreign.systemStream, emitsInOrder(['C']));
    });
  });
}
