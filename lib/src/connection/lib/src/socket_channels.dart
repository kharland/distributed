import 'dart:async';

import 'package:async/async.dart';
import 'package:distributed.connection/socket.dart';

class SocketChannels {
  static const _ready = 'READY';
  static const _userChannelId = 1;
  static const _systemChannelId = 2;
  final Socket _socket;
  final _closeMemo = new AsyncMemoizer();

  Stream<String> _userStream;
  Stream<String> _systemStream;

  SocketChannels(this._socket) {
    _userStream = _filterStreamByChannel(_socket, _userChannelId);
    _systemStream = _filterStreamByChannel(_socket, _systemChannelId);
  }

  static Future<SocketChannels> outgoing(Socket socket) async {
    socket.add(_ready);
    var message = await socket.first;
    if (message != _ready) {
      throw new Exception(message);
    }
    return new SocketChannels(socket);
  }

  static Future<SocketChannels> incoming(Socket socket) async {
    var message = await socket.first;
    if (message != _ready) {
      throw new Exception(message);
    }
    socket.add(_ready);
    return new SocketChannels(socket);
  }

  Stream<String> get userStream => _userStream;

  Stream<String> get systemStream => _systemStream;

  void sendToUser(String message) {
    _socket.add(_encode(_userChannelId, message));
  }

  void sendToSystem(String message) {
    _socket.add(_encode(_systemChannelId, message));
  }

  void close() {
    _closeMemo.runOnce(() {
      _socket.close();
    });
  }

  String _encode(int channelId, String message) => '$channelId:$message';

  String _decode(String message) => message.substring(message.indexOf(':') + 1);

  Stream<String> _filterStreamByChannel(Stream<String> stream, int channelId) =>
      stream
          .where((String message) => message.startsWith('$channelId'))
          .map(_decode);
}
