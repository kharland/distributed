import 'dart:async';
import 'dart:convert';

import 'package:distributed.net/timeout.dart';
import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/socket/socket.dart';
import 'package:distributed.node/src/socket/socket_splitter.dart';
import 'package:stream_channel/stream_channel.dart';

class SocketChannels implements ConnectionChannels<String> {
  static const _KEY_USR = '0';
  static const _KEY_SYS = '1';
  static const _KEY_ERR = '2';

  @override
  final StreamChannel<String> user;
  @override
  final StreamChannel<String> system;
  @override
  final StreamChannel<String> error;

  final Socket _socket;

  bool _isOpen = true;

  static Future<SocketChannels> outgoing(Socket socket) async {
    var splitter = new SocketSplitter(socket);
    var userPair = splitter.split();
    var systemPair = splitter.split();
    var errorPair = splitter.split();

    splitter.primaryChannel.sink.add(JSON.encode({
      _KEY_USR: userPair.first,
      _KEY_SYS: systemPair.first,
      _KEY_ERR: errorPair.first,
    }));

    var timeout = new Timeout(() {
      throw new TimeoutException('Remote SocketDemultiplexer timeod out');
    });

    var message = JSON.decode(await splitter.primaryChannel.stream.first);
    timeout.cancel();
    if (message['ok']) {
      return new SocketChannels._(
        userPair.last,
        systemPair.last,
        errorPair.last,
        socket,
      );
    } else {
      throw new Exception('SocketDemultiplexer: ${message['error']}');
    }
  }

  static Future<SocketChannels> incoming(Socket socket) async {
    var splitter = new SocketSplitter(socket);
    var timeout = new Timeout(() {
      splitter.primaryChannel.sink.close();
      throw new TimeoutException('Remote SocketDemultiplexer timeod out');
    });

    var message = JSON.decode(await splitter.primaryChannel.stream.first);
    timeout.cancel();
    var demux = new SocketChannels._(
      splitter.split(message[_KEY_USR]).last,
      splitter.split(message[_KEY_SYS]).last,
      splitter.split(message[_KEY_ERR]).last,
      socket,
    );
    splitter.primaryChannel.sink.add(JSON.encode({'ok': true}));
    return demux;
  }

  SocketChannels._(
    this.user,
    this.system,
    this.error,
    this._socket,
  );

  @override
  Future get done => _socket.done;

  @override
  Future close() async {
    if (_isOpen) {
      _isOpen = false;
      await Future.wait([
        user.sink.close(),
        system.sink.close(),
        error.sink.close(),
        _socket.close(),
      ]).then((_) {});
    }
  }
}
