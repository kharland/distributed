import 'dart:async';

import 'package:distributed/src/connection/message_channel.dart';
import 'package:distributed/src/connection/message_router.dart';
import 'package:distributed/src/monitoring/signal_monitor.dart';
import 'package:distributed.objects/public.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$MessageChannel', () {
    MessageChannel connection;
    MockMessageRouter messageRouter;
    MockResourceMonitor connectionMonitor;

    Future commonSetup() async {
      messageRouter = new MockMessageRouter();
      connectionMonitor = new MockResourceMonitor();
      connection = new MessageChannel(messageRouter, connectionMonitor);
    }

    tearDown(() async {
      connection.close();
    });

    test('add should send a message', () async {
      await commonSetup();
      final message = new Message('a', 'b', Peer.Null);
      connection.send(message);
      verify(messageRouter.sendToUser(Message.serialize(message)));
    });

    test('should close if the remote closes.', () async {
      await commonSetup();
      connectionMonitor.goAway();
      expect(connection.done, completes);
    });

    test('should close if close is called.', () async {
      await commonSetup();
      connection.close();
      expect(connection.done, completes);
    });
  });
}

class MockMessageRouter extends Mock implements MessageRouter {}

class MockResourceMonitor extends Mock implements SignalMonitor {
  final _onGoneCompleter = new Completer();

  @override
  Future get gone => _onGoneCompleter.future;

  void goAway() {
    _onGoneCompleter.complete('');
  }
}
