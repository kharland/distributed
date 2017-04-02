import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:distributed/src/connection/socket.dart';

class HttpSocket extends StreamView<String> implements Socket {
  static const _wsProto = 'ws://';
  static const _httpProto = 'http://';
  final io.Socket _socket;

  HttpSocket._(io.Socket socket)
      : _socket = socket,
        super(socket.transform(new Utf8Decoder()).asBroadcastStream());

  static Future<HttpSocket> connect(String url) async {
    if (url.startsWith(_wsProto)) {
      url = url.substring(_wsProto.length);
    } else if (url.startsWith(_httpProto)) {
      url = url.substring(_httpProto.length);
    }

    final lastColon = url.lastIndexOf(':');
    assert(lastColon > 0);
    final address = url.substring(0, lastColon);
    final port = int.parse(url.substring(lastColon + 1));
    return new HttpSocket._(await io.Socket.connect(address, port));
  }

  static Future<HttpSocket> receive(io.Socket socket) async {
    return new HttpSocket._(socket);
  }

  @override
  void add(String data) {
    _socket.write(data);
  }

  @override
  void close() {
    _socket.close();
  }

  @override
  String get remoteHost => 'localhost'; //_socket.remoteAddress.host;
}
