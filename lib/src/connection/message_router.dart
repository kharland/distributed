import 'dart:async';

import 'package:async/async.dart';
import 'package:distributed.http/vm.dart';

class MessageRouter {
  static const _userChannelId = 1;
  static const _systemChannelId = 2;
  final Socket _socket;
  final _closeMemo = new AsyncMemoizer();

  Stream<String> _userStream;
  Stream<String> _systemStream;

  MessageRouter(this._socket) {
    _userStream = _filterStreamByChannel(_socket, _userChannelId);
    _systemStream = _filterStreamByChannel(_socket, _systemChannelId);
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
      stream.where((m) => m.startsWith('$channelId')).map(_decode);
}
