import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/socket.dart';

/// A [Socket] implementation backed by an [io.Socket].
class VmSocket extends PseudoSocket<String> {
  static Future<VmSocket> connect(io.InternetAddress address, int port) async =>
      new VmSocket(await io.Socket.connect(address, port));

  VmSocket(io.Socket socket)
      : super(socket.map<String>(utf8Decode),
            new EncodedSocketSink<List<int>, String>(socket, utf8Encoder));
}
