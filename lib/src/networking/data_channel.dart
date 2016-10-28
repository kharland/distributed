import 'dart:async';

import 'package:distributed/src/networking/message.dart';
import 'package:distributed/interfaces/peer.dart';

import 'package:seltzer/seltzer.dart';
import 'package:seltzer/src/interface.dart';

abstract class DataChannel<T> {
  /// Creates a [PlatformDataChannel] between [sender] and [recipient].
  static Future<DataChannel> connect(
          String cookie, Peer sender, Peer recipient) async =>
      new PlatformDataChannel(await SeltzerWebSocket.connect(recipient.url));

  Stream<T> get onData;

  Future<Null> get onClose;

  void send(T data);

  void close();
}

/// Default implementation of a platform-independent [DataChannel] between two peers.
class PlatformDataChannel implements DataChannel<String> {
  static final StreamTransformer<SeltzerMessage, String>
      _seltzerMessageDecoder =
      new StreamTransformer<SeltzerMessage, String>.fromHandlers(
          handleData: (SeltzerMessage message, EventSink<String> sink) {
    message.readAsString().then(sink.add);
  });

  final StreamController<Message> _onMessageController =
      new StreamController<Message>.broadcast();
  final Completer<Null> _onCloseCompleter = new Completer<Null>();
  final SeltzerWebSocket _webSocket;
  @override
  final Stream<String> onData;

  bool _isOpen = true;

  /// Default constructor to create a DataChannel from [webSocket].
  ///
  /// It is expected that [webSocket] is already connectied to a remote Peer.
  PlatformDataChannel(SeltzerWebSocket webSocket)
      : _webSocket = webSocket,
        onData = webSocket.onMessage
            .transform(_seltzerMessageDecoder)
            .asBroadcastStream() {
    _webSocket.onClose.then((_) async {
      _isOpen = false;
      _onMessageController.close();
      _onCloseCompleter.complete();
    });
  }

  @override
  Future<Null> get onClose => _onCloseCompleter.future;

  @override
  void send(String data) {
    _ensureIsOpen();
    _webSocket.sendString(data);
  }

  @override
  void close() {
    _ensureIsOpen();
    if (_isOpen) {
      _isOpen = false;
      _webSocket.close();
    }
  }

  void _ensureIsOpen() {
    if (!_isOpen) {
      throw new StateError('DataChannel is not open.');
    }
  }
}
