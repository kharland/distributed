import 'dart:async';

import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/command.dart';
import 'package:distributed/src/networking/message.dart';
import 'package:distributed/src/networking/data_channel.dart';
import 'package:distributed/src/networking/json.dart';

/// A direct connection between two [Node]s.
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

  bool _isOpen = true;
  StreamSubscription<String> _dataSubscription;

  _OpenConnectionModel(this._dataChannel) {
    _dataSubscription = _dataChannel.onData.listen((String data) {
      if (data is! String) {
        throw new FormatException(data);
      }
      _Payload payload = _PayloadSerializer.deserialize(data);
      Message message;
      if (payload.format == 'PeerInfoMessage') {
        message = new PeerInfoMessage.fromJson(Json.decode(payload.data));
      } else if (payload.format == 'CommandMessage') {
        message = new CommandMessage.fromJson(Json.decode(payload.data));
      } else if (payload.format == 'ConnectMessage') {
        message = new ConnectMessage.fromJson(Json.decode(payload.data));
      }
      _onMessageController.add(message);
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
    _dataChannel.send(_PayloadSerializer.serialize(
        new _Payload(message.runtimeType.toString(), message.serialize())));
  }
}

/// A wrapper to simplify [Message] (de)serialization.
class _Payload {
  /// A value that denotes how [data] should be parsed.
  final String format;

  /// The data contained in this message.
  final String data;

  _Payload(this.format, this.data);
}

typedef Message DecodeCallback(String message);

abstract class _PayloadSerializer {
  static String serialize(_Payload payload) => Json
      .encode(<String, Object>{'format': payload.format, 'data': payload.data});

  static _Payload deserialize(String payloadString) {
    Map<String, Object> json = Json.decode(payloadString);
    _Payload payload = new _Payload(json['format'], json['data']);
    return payload;
  }
}
