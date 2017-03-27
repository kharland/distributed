import 'dart:async';

import 'package:distributed/src/connection/socket.dart';
import 'package:seltzer/platform/vm.dart' as seltzer;

class SeltzerSocket extends StreamView<String> implements Socket {
  static bool _isSeltzerInitialized = false;

  static void _initSeltzer() {
    if (_isSeltzerInitialized) return;
    seltzer.useSeltzerInVm();
    _isSeltzerInitialized = true;
  }

  static SeltzerSocket connect(String url) {
    _initSeltzer();
    return new SeltzerSocket._(seltzer.connect(url));
  }

  static SeltzerSocket receive(seltzer.SeltzerWebSocket socket) {
    _initSeltzer();
    return new SeltzerSocket._(socket);
  }

  final seltzer.SeltzerWebSocket _delegate;
  bool _isOpen = false;

  SeltzerSocket._(seltzer.SeltzerWebSocket delegate)
      : _delegate = delegate,
        // ignore: strong_mode_down_cast_composite
        super(delegate.onMessage
            .asyncMap((m) => m.readAsString())
            .asBroadcastStream()) {
    _delegate.onClose.then((_) {
      close();
    });
  }

  @override
  void add(String event) {
    _delegate.sendString(event);
  }

  @override
  void close() {
    if (_isOpen) {
      _delegate.close();
      _isOpen = false;
    }
  }
}
