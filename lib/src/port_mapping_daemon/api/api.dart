import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:async/async.dart';
import 'package:meta/meta.dart';

enum RequestType {
  ping,
  register,
  deregister,
  connect,
  list,
}

class DaemonSocket {
  final StreamSplitter<String> _splitter;
  final WebSocket _socket;

  DaemonSocket(WebSocket socket)
      : _socket = socket,
        _splitter = new StreamSplitter(socket as Stream<String>);

  static Future<DaemonSocket> createFromUrl(String url) async =>
      new DaemonSocket(await WebSocket.connect(url));
  
  Stream<String> get stream => _splitter.split();

  void send(String value) {
    _socket.add(value);  
  }
  
  void sendPing() {
    _socket.add(const Ping().toString());
  }

  void sendRequestInitiation(RequestType type, String cookie) {
    _socket.add(new RequestInitiation(type, cookie).toString());
  }

  void sendRegistrationRequest(String name) {
    _socket.add(new RegistrationRequest(name).toString());
  }

  void sendRegistrationInfo(String name, int port) {
    _socket.add(new RegistrationResult(name, port).toString());
  }

  void close([int closeCode]) {
    _socket.close(closeCode);
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

// TODO: change to registration response.
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
