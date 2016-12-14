import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:async/async.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/status.dart' as status;

enum RequestType { ping, register, deregister, connect, list }

class DaemonSocket {
  final StreamSplitter<String> _splitter;
  final WebSocket _socket;
  final Duration _idleTimeout;
  final Function _onTimeout;

  bool _isOpen = true;
  Timer _idleTimer;
  StreamSubscription<String> _idleSubscription;

  /// Creates a new socket that wraps [socket].
  ///
  /// If [idleTimeout] is non-zero, the socket will automatically close after no
  /// messages are sent or received on the socket for longer than [idleTimeout].
  DaemonSocket(WebSocket socket,
      {Duration idleTimeout: Duration.ZERO, void onTimeout()})
      : _idleTimeout = idleTimeout,
        _onTimeout = onTimeout,
        _socket = socket,
        _splitter = new StreamSplitter(socket as Stream<String>) {
    if (idleTimeout.compareTo(Duration.ZERO) > 0) {
      _idleSubscription = stream.listen((_) {
        _restartTimer();
      });
      _restartTimer();
    }
  }

  static Future<DaemonSocket> createFromUrl(String url,
          {Duration idleTimeout: Duration.ZERO, void onTimeout()}) async =>
      new DaemonSocket(await WebSocket.connect(url),
          idleTimeout: idleTimeout, onTimeout: onTimeout);

  Stream<String> get stream => _splitter.split();

  void send(String value) {
    _send(value);
  }

  void sendHandshakeSucceeded([String message = '']) {
    _send(new ExecutionResult(message).toString());
  }

  void sendHandshakeFailed([String message = '']) {
    _send(new ExecutionResult.error(message).toString());
  }

  void sendPing() {
    _send(const Ping().toString());
  }

  void sendRequestInitiation(RequestType type, String cookie) {
    _send(new RequestInitiation(type, cookie).toString());
  }

  void sendRegistrationRequest(String name) {
    _send(new RegistrationRequest(name).toString());
  }

  void sendRegistrationInfo(String name, int port) {
    _send(new RegistrationResult(name, port).toString());
  }

  void close([int closeCode]) {
    _idleTimer?.cancel();
    _idleSubscription?.cancel();
    _socket.close(closeCode);
    _isOpen = false;
  }

  void _send(String data) {
    if (!_isOpen) throw new StateError('Socket is closed');
    _restartTimer();
    _socket.add(data);
  }

  void _restartTimer() {
    _idleTimer?.cancel();
    _idleTimer = new Timer(_idleTimeout, () {
      close(status.normalClosure);
      if (_onTimeout != null) _onTimeout();
    });
  }
}

abstract class Entity {
  @literal
  const Entity();

  static bool canParseAs(Type type, String string) =>
      string.startsWith(type.toString());

  Map<String, Object> toJson();

  @override
  String toString() => "$runtimeType${JSON.encode(toJson())}";
}

class Ping extends Entity {
  @literal
  const Ping();

  @override
  Map<String, Object> toJson() => {};

  static Ping fromJson(_) => new Ping();

  static Ping fromString(_) => new Ping();
}

class ExecutionResult implements Entity {
  final bool isError;
  final String message;

  @literal
  const ExecutionResult(this.message) : isError = false;

  @literal
  const ExecutionResult.error(this.message) : isError = true;

  factory ExecutionResult.fromJson(Map<String, Object> json) => json['isError']
      ? new ExecutionResult.error(json['message'])
      : new ExecutionResult(json['message']);

  @override
  Map<String, Object> toJson() =>
      <String, Object>{'isError': isError, 'message': message};
}

class RequestInitiation extends Entity {
  final RequestType type;
  final String cookie;

  @literal
  const RequestInitiation(this.type, this.cookie);

  factory RequestInitiation.fromJson(Map<String, Object> json) =>
      new RequestInitiation(
          RequestType.values.firstWhere((value) => '$value' == json['type']),
          json['cookie']);

  factory RequestInitiation.fromString(String string) =>
      new RequestInitiation.fromJson(
          _decode(string.substring('$RequestInitiation'.length)));

  @override
  Map<String, Object> toJson() => {'type': '$type', 'cookie': cookie};
}

class RegistrationRequest extends Entity {
  final String nodeName;

  @literal
  const RegistrationRequest(this.nodeName);

  factory RegistrationRequest.fromJson(Map<String, Object> json) =>
      new RegistrationRequest(json['nodeName']);

  factory RegistrationRequest.fromString(String string) =>
      new RegistrationRequest.fromJson(
          _decode(string.substring('$RegistrationRequest'.length)));

  @override
  Map<String, Object> toJson() => {'nodeName': nodeName};
}

class RegistrationResult extends Entity {
  final String name;
  final int port;
  final bool _failed;

  @literal
  const RegistrationResult(this.name, this.port) : _failed = false;

  @literal
  const RegistrationResult.failure()
      : name = '',
        port = -1,
        _failed = true;

  @override
  factory RegistrationResult.fromJson(Map<String, Object> json) =>
      json['failed']
          ? new RegistrationResult.failure()
          : new RegistrationResult(json['name'], int.parse(json['port']));

  factory RegistrationResult.fromString(String string) =>
      new RegistrationResult.fromJson(
          _decode(string.substring('$RegistrationResult'.length)));

  bool get failed => _failed;

  @override
  Map<String, Object> toJson() =>
      {'name': name, 'port': port, 'failed': _failed};
}

Map<String, Object> _decode(String s) => JSON.decode(s) as Map<String, Object>;
