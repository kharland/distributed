import 'dart:async';
import 'dart:convert';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket/socket_splitter.dart';
import 'package:distributed.connection/src/timeout.dart';
import 'package:stream_channel/stream_channel.dart';

/// A [SocketChannels] that closes when its remote breaks the connection.
///
/// This class is only meant to be used for connecting to other
/// [SocketChannels].
class SocketChannels {
  static const _keyUsr = '0';
  static const _keySys = '1';

  static final _timeoutError = 'Remote $SocketChannels timed out';

  final StreamChannel<String> user;
  final StreamChannel<String> system;

  bool _isOpen = true;

  SocketChannels(this.user, this.system);

  static Future<SocketChannels> outgoing(Socket socket) async {
    var splitter = new SocketSplitter(socket);
    var userSplit = splitter.split();
    var systemSplit = splitter.split();

    splitter.primaryChannel.sink.add(JSON.encode({
      _keyUsr: userSplit.id,
      _keySys: systemSplit.id,
    }));

    var timeout = new Timeout(() {
      splitter.primaryChannel.sink.close();
      throw new TimeoutException(_timeoutError);
    });

    var message = JSON.decode(await splitter.primaryChannel.stream.first);
    timeout.cancel();
    if (message['ok']) {
      return new SocketChannels(userSplit.channel, systemSplit.channel);
    } else {
      throw new Exception('$SocketChannels: ${message['error']}');
    }
  }

  static Future<SocketChannels> incoming(Socket socket) async {
    var splitter = new SocketSplitter(socket);
    var timeout = new Timeout(() {
      splitter.primaryChannel.sink.close();
      throw new TimeoutException(_timeoutError);
    });

    var message = JSON.decode(await splitter.primaryChannel.stream.first);
    timeout.cancel();

    var channels = new SocketChannels(
      splitter.split(message[_keyUsr]).channel,
      splitter.split(message[_keySys]).channel,
    );
    splitter.primaryChannel.sink.add(JSON.encode({'ok': true}));
    return channels;
  }

  Future get done => Future.wait([
        user.sink.done,
        system.sink.done,
      ]);

  Future close() async {
    if (_isOpen) {
      _isOpen = false;
      user.sink.close();
      system.sink.close();
      return done;
    }
  }
}
