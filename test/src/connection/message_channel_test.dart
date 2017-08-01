import 'dart:async';

import 'package:distributed/src/connection/channel.dart';
import 'package:distributed/src/connection/message_router.dart';
import 'package:distributed.monitoring/signal_monitor.dart';
import 'package:distributed.objects/objects.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$MessageChannel', () {
    MessageChannel messageChannel;
    MockMessageRouter messageRouter;
    MockResourceMonitor connectionMonitor;

    Future commonSetup() async {
      messageRouter = new MockMessageRouter();
      connectionMonitor = new MockResourceMonitor();
      messageChannel = new MessageChannel(messageRouter, connectionMonitor);
    }

    tearDown(() async {
      messageChannel.close();
    });

    test('add should send a message', () async {
      await commonSetup();
      final message = new Message('a', 'b', Peer.Null);
      messageChannel.send(message);
      verify(messageRouter.sendToUser(message.serialize()));
    });

    test('should close if the remote closes.', () async {
      await commonSetup();
      connectionMonitor.goAway();
      expect(messageChannel.done, completes);
    });

    test('should close if close is called.', () async {
      await commonSetup();
      messageChannel.close();
      expect(messageChannel.done, completes);
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
