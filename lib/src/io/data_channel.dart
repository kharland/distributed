import 'dart:async';
import 'dart:io';

import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/data_channel.dart';

/// A [DataChannel] created when a [Peer] connects to a node running on the Dart
/// VM.
///
/// The host node has already accepted a connection to the remote peer by the
/// time this change is created.
class IODataChannel<T> implements DataChannel<T> {
  final WebSocket _webSocket;
  final StreamController<T> _onMessageController = new StreamController<T>();
  final Completer<Null> _onCloseCompleter = new Completer<Null>();

  StreamSubscription _webSocketSubscription;
  bool _socketIsOpen = true;

  /// Creates an [IODataChannel] over the given WebSocket.
  ///
  /// If the peer on the other end of the connection provides an invalid
  ///
  IODataChannel(this._webSocket) {
    _webSocketSubscription = _webSocket.listen((payload) {
      _onMessageController.add(payload as T);
    });
    _webSocket.done.then((_) {
      _socketIsOpen = false;
      _webSocketSubscription.cancel();
      _onCloseCompleter.complete();
    });
  }

  @override
  Stream<T> get onData {
    _ensureIsOpen();
    return _onMessageController.stream;
  }

  @override
  Future<Null> get onClose {
    _ensureIsOpen();
    return _onCloseCompleter.future;
  }

  @override
  void send(T data) {
    _ensureIsOpen();
    _webSocket.add(data);
  }

  @override
  void close() {
    _ensureIsOpen();
    if (_socketIsOpen) {
      _socketIsOpen = false;
      _webSocket.close();
    }
  }

  void _ensureIsOpen() {
    if (!_socketIsOpen) {
      throw new StateError('DataChannel is not open.');
    }
  }
}
