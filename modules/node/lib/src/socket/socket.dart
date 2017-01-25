import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.node/src/socket/seltzer_socket.dart';

/// An abstract interface for a web socket.
abstract class Socket implements Stream<String>, StreamSink<String> {
  static Future<Socket> connect(
    String url, {
    Secret secret: Secret.acceptAny,
  }) async =>
      SeltzerSocket.connect(url, secret: secret);
}
