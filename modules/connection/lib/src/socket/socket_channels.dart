import 'dart:async';
import 'dart:convert';

import 'package:distributed.connection/src/data_channels.dart';
import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket/socket_splitter.dart';
import 'package:distributed.connection/src/timeout.dart';
import 'package:stream_channel/stream_channel.dart';

class SocketChannels implements DataChannels<String> {
  static const _keyUsr = '0';
  static const _keySys = '1';
  static const _keyErr = '2';
  static final _timeoutError = 'Remote $SocketChannels timed out';

  @override
  final StreamChannel<String> user;
  @override
  final StreamChannel<String> system;
  @override
  final StreamChannel<String> error;

  bool _isOpen = true;

  SocketChannels(
    this.user,
    this.system,
    this.error,
  );

  static Future<SocketChannels> outgoing(Socket socket) async {
    var splitter = new SocketSplitter(socket);
    var userPair = splitter.split();
    var systemPair = splitter.split();
    var errorPair = splitter.split();

    splitter.primaryChannel.sink.add(JSON.encode({
      _keyUsr: userPair.first,
      _keySys: systemPair.first,
      _keyErr: errorPair.first,
    }));

    var timeout = new Timeout(() {
      splitter.primaryChannel.sink.close();
      throw new TimeoutException(_timeoutError);
    });

    var message = JSON.decode(await splitter.primaryChannel.stream.first);
    timeout.cancel();
    if (message['ok']) {
      return new SocketChannels(
        userPair.last,
        systemPair.last,
        errorPair.last,
      );
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
      splitter.split(message[_keyUsr]).last,
      splitter.split(message[_keySys]).last,
      splitter.split(message[_keyErr]).last,
    );
    splitter.primaryChannel.sink.add(JSON.encode({'ok': true}));
    return channels;
  }

  @override
  Future get done =>
      Future.wait([user.sink.done, system.sink.done, error.sink.done]);

  @override
  Future close() async {
    if (_isOpen) {
      _isOpen = false;
      user.sink.close();
      system.sink.close();
      error.sink.close();
      return done;
    }
  }
}
