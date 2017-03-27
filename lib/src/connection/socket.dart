import 'dart:async';

import 'seltzer_socket.dart';

/// A bidirectional communication channel.
abstract class Socket implements Stream<String>, Sink<String> {
  /// Initiates a [Socket] connection over [url].
  static Socket connect(String url) => SeltzerSocket.connect(url);
}
