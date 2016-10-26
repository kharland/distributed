import 'dart:async';

import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/json.dart';
import 'package:distributed/src/networking/formatted_message.dart';
import 'package:distributed/src/networking/message_decoders.dart';

class ConnectionEvent {
  final Peer peer;
  final Connection connection;

  const ConnectionEvent(this.peer, this.connection);
}

abstract class DataChannel<T> {
  Stream<T> get onData;

  Future<Null> get onClose;

  void send(T data);

  void close();
}

/// A direct connection between nodes.
class Connection {
  _ConnectionModel _model;
  bool _isClosing = false;

  Connection(DataChannel<String> dataChannel)
      : _model = new _OpenConnectionModel(dataChannel) {
    _model.onClose.then((_) {
      if (!_isClosing) {
        _isClosing = true;
        _model = new _ClosedConnectionModel();
      }
    });
  }

  /// Emits when a message is received.
  Stream<Message> get onMessage => _model.onMessage;

  /// Emits when the connection is closed
  Future<Null> get onClose => _model.onClose;

  /// Closes this connection.
  void close() {
    if (!_isClosing) {
      _isClosing = true;
      _model.close();
    }
  }

  /// Sends [message] to a remote peer.
  void send(Message message) {
    _model.send(message);
  }
}

abstract class _ConnectionModel {
  Stream<Message> get onMessage;

  Future<Null> get onClose;

  void close();

  void send(Message message);
}

class _ClosedConnectionModel implements _ConnectionModel {
  static final _error = new StateError('The connection is closed.');
  static final Future<Null> _closeFuture = new Future<Null>.value();

  @override
  Stream<Message> get onMessage => throw _error;

  @override
  Future<Null> get onClose => _closeFuture;

  @override
  void close() {
    throw _error;
  }

  @override
  void send(Message message) {
    throw _error;
  }
}

class _OpenConnectionModel implements _ConnectionModel {
  final Completer<Null> _onCloseCompleter = new Completer<Null>();
  final StreamController<Message> _onMessageController =
      new StreamController<Message>.broadcast();
  final DataChannel<String> _dataChannel;
  final MessageDecoder _messageDecoder = new MessageDecoder();

  bool _isOpen = true;
  StreamSubscription<String> _dataSubscription;

  _OpenConnectionModel(this._dataChannel) {
    _dataSubscription = _dataChannel.onData.listen((String data) {
      if (data is! String) {
        throw new FormatException(data);
      }
      var message = new FormattedMessage.fromJson(Json.decode(data));
      if (_messageDecoder.canDecode(message.format)) {
        _onMessageController
            .add(_messageDecoder.decode(message.format, message.message));
      }
    });
    _dataChannel.onClose.then((_) {
      _isOpen = false;
      _dataSubscription.cancel();
      _onMessageController.close();
      _onCloseCompleter.complete();
    });
  }

  @override
  Stream<Message> get onMessage => _onMessageController.stream;

  @override
  Future<Null> get onClose => _onCloseCompleter.future;

  @override
  void close() {
    if (_isOpen) {
      _isOpen = false;
      _dataChannel.close();
    }
  }

  @override
  void send(Message message) {
    var rawMessage = new FormattedMessage(
        message.runtimeType.toString(), message.serialize());
    _dataChannel.send(rawMessage.serialize());
  }
}
