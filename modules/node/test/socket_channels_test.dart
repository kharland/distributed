import 'dart:async';

import 'package:distributed.node/src/socket/socket_channels.dart';
import 'package:distributed.node/testing/test_socket_connection.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

void main() {
  useSeltzerInVm();

  group('$SocketChannels', () {
    SocketChannels local;
    SocketChannels foreign;

    setUp(() async {
      var testConnection = new TestSocketConnection();
      await Future.wait([
        SocketChannels.outgoing(testConnection.foreign).then((demux) {
          foreign = demux;
        }),
        SocketChannels.incoming(testConnection.local).then((demux) {
          local = demux;
        })
      ]);
    });

    test('channels should only send and recieve the appropriate messages',
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
      test('should complete when the local $SocketChannels closes', () async {
        local.close();
        expect(local.done, completes);
        expect(foreign.done, completes);
      });

      test('should complete when the foreign $SocketChannels closes', () async {
        foreign.close();
        expect(local.done, completes);
        expect(foreign.done, completes);
      });
    });
  });
}
