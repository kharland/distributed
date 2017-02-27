import 'dart:convert';

import 'package:distributed.port_daemon/src/ports.dart';
import 'package:meta/meta.dart';

abstract class Message {
  @literal
  const Message();

  static bool canParseAs(Type type, String string) =>
      string.startsWith(type.toString());

  static Map<String, Object> parseJson(derivedType, String s) {
    return JSON.decode(s.substring(derivedType.toString().length))
        as Map<String, Object>;
  }

  Map<String, Object> toJson();

  @override
  String toString() => "$runtimeType${JSON.encode(toJson())}";
}

class RegistrationResult extends Message {
  final String name;
  final int port;
  final bool _failed;

  @literal
  const RegistrationResult(this.name, this.port) : _failed = false;

  RegistrationResult.failure()
      : name = '',
        port = Ports.error,
        _failed = true;

  factory RegistrationResult.fromJson(Map<String, Object> json) =>
      json['failed']
          ? new RegistrationResult.failure()
          : new RegistrationResult(json['name'], json['port']);

  factory RegistrationResult.fromString(String string) =>
      new RegistrationResult.fromJson(
          Message.parseJson(RegistrationResult, string));

  bool get failed => _failed;

  @override
  Map<String, Object> toJson() =>
      {'name': name, 'port': port.toInt(), 'failed': _failed};
}

// TODO: Why is this implemented differently than RegisterationResult? fix.
class DeregistrationResult extends Message {
  final String name;
  final bool failed;

  @literal
  const DeregistrationResult(this.name, this.failed);

  factory DeregistrationResult.fromJson(Map<String, Object> json) =>
      new DeregistrationResult(json['name'], json['failed']);

  factory DeregistrationResult.fromString(String string) =>
      new DeregistrationResult.fromJson(
          Message.parseJson(DeregistrationResult, string));

  @override
  Map<String, Object> toJson() => {'name': name, 'failed': failed};
}

class PortAssignmentList extends Message {
  final Map<String, int> assignments;

  @literal
  const PortAssignmentList(this.assignments);

  factory PortAssignmentList.fromString(String s) {
    var assignmentsWithIntPorts = Message.parseJson(PortAssignmentList, s);
    return new PortAssignmentList(assignmentsWithIntPorts);
  }

  @override
  Map<String, int> toJson() => new Map.fromIterables(
      assignments.keys, assignments.values.map((i) => i.toInt()));
}
