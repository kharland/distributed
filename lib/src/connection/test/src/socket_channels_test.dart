import 'dart:async';

import 'package:distributed.connection/src/message_router.dart';
import 'package:distributed.connection/src/socket_controller.dart';
import 'package:test/test.dart';

void main() {
  group('$MessageRouter', () {
    MessageRouter local;
    MessageRouter foreign;

    setUp(() async {
      var testConnection = new SocketController();
      await Future.wait([
        new MessageRouter(testConnection.foreign).then((channels) {
          foreign = channels;
        }),
        new MessageRouter(testConnection.local).then((channels) {
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
