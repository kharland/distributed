import 'dart:async';

import 'package:distributed.net/timeout.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/message/message_categories.dart';
import 'package:logging/logging.dart';

abstract class PeerIdentificationStrategy {
  Future<String> identifyRemote(
    StreamSink<Message> sink,
    Stream<Message> stream,
  );
}

class NameExchange implements PeerIdentificationStrategy {
  final String _localPeerName;
  final Logger _logger = new Logger("$NameExchange");

  NameExchange(this._localPeerName);

  @override
  Future<String> identifyRemote(
    StreamSink<Message> sink,
    Stream<Message> stream,
  ) async {
    String remotePeerName;
    var completer = new Completer<String>();

    void fail(String reason) {
      sink.add(new Message.error(reason));
      _logger.severe(reason);
      completer.complete('');
    }

    sink.add(new Message.id(_localPeerName));
    var timeout = new Timeout(() {
      fail('Timeout during peer introduction');
    });

    var message = await stream.take(1).first;
    timeout.cancel();
    if (message.category == MessageCategories.identify) {
      remotePeerName = message.payload;
      sink.add(new Message.statusOk());
    } else {
      fail('Invalid message category: ${message.category}');
    }

    timeout = new Timeout(() {
      fail('Timeout during peer introduction');
    });

    // Confirm that the introduction is complete.
    message = await stream.take(1).first;
    timeout.cancel();
    if (message.category == MessageCategories.error) {
      _logger.severe(message.payload);
    } else if (message.category == MessageCategories.statusOk) {
      completer.complete(remotePeerName);
    } else {
      fail('Invalid message category: ${message.category}');
    }

    return completer.future;
  }
}
