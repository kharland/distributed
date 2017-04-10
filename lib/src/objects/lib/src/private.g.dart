// GENERATED CODE - DO NOT MODIFY BY HAND

part of distributed.objects;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: library distributed.objects
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(BuiltHostMachine.serializer)
      ..add(BuiltMessage.serializer)
      ..add(BuiltNodePorts.serializer)
      ..add(BuiltPeer.serializer)
      ..add(BuiltRegistration.serializer))
    .build();
Serializer<BuiltRegistration> _$builtRegistrationSerializer =
    new _$BuiltRegistrationSerializer();
Serializer<BuiltMessage> _$builtMessageSerializer =
    new _$BuiltMessageSerializer();
Serializer<BuiltPeer> _$builtPeerSerializer = new _$BuiltPeerSerializer();
Serializer<BuiltHostMachine> _$builtHostMachineSerializer =
    new _$BuiltHostMachineSerializer();
Serializer<BuiltNodePorts> _$builtNodePortsSerializer =
    new _$BuiltNodePortsSerializer();

class _$BuiltRegistrationSerializer
    implements StructuredSerializer<BuiltRegistration> {
  @override
  final Iterable<Type> types = const [BuiltRegistration, _$BuiltRegistration];
  @override
  final String wireName = 'BuiltRegistration';

  @override
  Iterable serialize(Serializers serializers, BuiltRegistration object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'nodeName',
      serializers.serialize(object.nodeName,
          specifiedType: const FullType(String)),
      'ports',
      serializers.serialize(object.ports,
          specifiedType: const FullType(NodePorts)),
    ];

    return result;
  }

  @override
  BuiltRegistration deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new BuiltRegistrationBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'nodeName':
          result.nodeName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'ports':
          result.ports = serializers.deserialize(value,
              specifiedType: const FullType(NodePorts)) as NodePorts;
          break;
      }
    }

    return result.build();
  }
}

class _$BuiltMessageSerializer implements StructuredSerializer<BuiltMessage> {
  @override
  final Iterable<Type> types = const [BuiltMessage, _$BuiltMessage];
  @override
  final String wireName = 'BuiltMessage';

  @override
  Iterable serialize(Serializers serializers, BuiltMessage object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'sender',
      serializers.serialize(object.sender,
          specifiedType: const FullType(BuiltPeer)),
      'category',
      serializers.serialize(object.category,
          specifiedType: const FullType(String)),
      'contents',
      serializers.serialize(object.contents,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  BuiltMessage deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new BuiltMessageBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'sender':
          result.sender.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltPeer)) as BuiltPeer);
          break;
        case 'category':
          result.category = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'contents':
          result.contents = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$BuiltPeerSerializer implements StructuredSerializer<BuiltPeer> {
  @override
  final Iterable<Type> types = const [BuiltPeer, _$BuiltPeer];
  @override
  final String wireName = 'BuiltPeer';

  @override
  Iterable serialize(Serializers serializers, BuiltPeer object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'hostMachine',
      serializers.serialize(object.hostMachine,
          specifiedType: const FullType(BuiltHostMachine)),
    ];

    return result;
  }

  @override
  BuiltPeer deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new BuiltPeerBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'hostMachine':
          result.hostMachine.replace(serializers.deserialize(value,
                  specifiedType: const FullType(BuiltHostMachine))
              as BuiltHostMachine);
          break;
      }
    }

    return result.build();
  }
}

class _$BuiltHostMachineSerializer
    implements StructuredSerializer<BuiltHostMachine> {
  @override
  final Iterable<Type> types = const [BuiltHostMachine, _$BuiltHostMachine];
  @override
  final String wireName = 'BuiltHostMachine';

  @override
  Iterable serialize(Serializers serializers, BuiltHostMachine object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'address',
      serializers.serialize(object.address,
          specifiedType: const FullType(String)),
      'daemonPort',
      serializers.serialize(object.daemonPort,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  BuiltHostMachine deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new BuiltHostMachineBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'address':
          result.address = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'daemonPort':
          result.daemonPort = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$BuiltNodePortsSerializer
    implements StructuredSerializer<BuiltNodePorts> {
  @override
  final Iterable<Type> types = const [BuiltNodePorts, _$BuiltNodePorts];
  @override
  final String wireName = 'BuiltNodePorts';

  @override
  Iterable serialize(Serializers serializers, BuiltNodePorts object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'connectionPort',
      serializers.serialize(object.connectionPort,
          specifiedType: const FullType(int)),
      'controlPort',
      serializers.serialize(object.controlPort,
          specifiedType: const FullType(int)),
      'diagnosticPort',
      serializers.serialize(object.diagnosticPort,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  BuiltNodePorts deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new BuiltNodePortsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'connectionPort':
          result.connectionPort = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'controlPort':
          result.controlPort = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'diagnosticPort':
          result.diagnosticPort = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class BuiltRegistration
// **************************************************************************

class _$BuiltRegistration extends BuiltRegistration {
  @override
  final String nodeName;
  @override
  final NodePorts ports;

  factory _$BuiltRegistration([void updates(BuiltRegistrationBuilder b)]) =>
      (new BuiltRegistrationBuilder()..update(updates)).build();

  _$BuiltRegistration._({this.nodeName, this.ports}) : super._() {
    if (nodeName == null) throw new ArgumentError.notNull('nodeName');
    if (ports == null) throw new ArgumentError.notNull('ports');
  }

  @override
  BuiltRegistration rebuild(void updates(BuiltRegistrationBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltRegistrationBuilder toBuilder() =>
      new BuiltRegistrationBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! BuiltRegistration) return false;
    return nodeName == other.nodeName && ports == other.ports;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, nodeName.hashCode), ports.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('BuiltRegistration')
          ..add('nodeName', nodeName)
          ..add('ports', ports))
        .toString();
  }
}

class BuiltRegistrationBuilder
    implements Builder<BuiltRegistration, BuiltRegistrationBuilder> {
  _$BuiltRegistration _$v;

  String _nodeName;
  String get nodeName => _$this._nodeName;
  set nodeName(String nodeName) => _$this._nodeName = nodeName;

  NodePorts _ports;
  NodePorts get ports => _$this._ports;
  set ports(NodePorts ports) => _$this._ports = ports;

  BuiltRegistrationBuilder();

  BuiltRegistrationBuilder get _$this {
    if (_$v != null) {
      _nodeName = _$v.nodeName;
      _ports = _$v.ports;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltRegistration other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$BuiltRegistration;
  }

  @override
  void update(void updates(BuiltRegistrationBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$BuiltRegistration build() {
    final result =
        _$v ?? new _$BuiltRegistration._(nodeName: nodeName, ports: ports);
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class BuiltMessage
// **************************************************************************

class _$BuiltMessage extends BuiltMessage {
  @override
  final BuiltPeer sender;
  @override
  final String category;
  @override
  final String contents;

  factory _$BuiltMessage([void updates(BuiltMessageBuilder b)]) =>
      (new BuiltMessageBuilder()..update(updates)).build();

  _$BuiltMessage._({this.sender, this.category, this.contents}) : super._() {
    if (sender == null) throw new ArgumentError.notNull('sender');
    if (category == null) throw new ArgumentError.notNull('category');
    if (contents == null) throw new ArgumentError.notNull('contents');
  }

  @override
  BuiltMessage rebuild(void updates(BuiltMessageBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltMessageBuilder toBuilder() => new BuiltMessageBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! BuiltMessage) return false;
    return sender == other.sender &&
        category == other.category &&
        contents == other.contents;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc(0, sender.hashCode), category.hashCode), contents.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('BuiltMessage')
          ..add('sender', sender)
          ..add('category', category)
          ..add('contents', contents))
        .toString();
  }
}

class BuiltMessageBuilder
    implements Builder<BuiltMessage, BuiltMessageBuilder> {
  _$BuiltMessage _$v;

  BuiltPeerBuilder _sender;
  BuiltPeerBuilder get sender => _$this._sender ??= new BuiltPeerBuilder();
  set sender(BuiltPeerBuilder sender) => _$this._sender = sender;

  String _category;
  String get category => _$this._category;
  set category(String category) => _$this._category = category;

  String _contents;
  String get contents => _$this._contents;
  set contents(String contents) => _$this._contents = contents;

  BuiltMessageBuilder();

  BuiltMessageBuilder get _$this {
    if (_$v != null) {
      _sender = _$v.sender?.toBuilder();
      _category = _$v.category;
      _contents = _$v.contents;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltMessage other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$BuiltMessage;
  }

  @override
  void update(void updates(BuiltMessageBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$BuiltMessage build() {
    final result = _$v ??
        new _$BuiltMessage._(
            sender: sender?.build(), category: category, contents: contents);
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class BuiltPeer
// **************************************************************************

class _$BuiltPeer extends BuiltPeer {
  @override
  final String name;
  @override
  final BuiltHostMachine hostMachine;

  factory _$BuiltPeer([void updates(BuiltPeerBuilder b)]) =>
      (new BuiltPeerBuilder()..update(updates)).build();

  _$BuiltPeer._({this.name, this.hostMachine}) : super._() {
    if (name == null) throw new ArgumentError.notNull('name');
    if (hostMachine == null) throw new ArgumentError.notNull('hostMachine');
  }

  @override
  BuiltPeer rebuild(void updates(BuiltPeerBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltPeerBuilder toBuilder() => new BuiltPeerBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! BuiltPeer) return false;
    return name == other.name && hostMachine == other.hostMachine;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, name.hashCode), hostMachine.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('BuiltPeer')
          ..add('name', name)
          ..add('hostMachine', hostMachine))
        .toString();
  }
}

class BuiltPeerBuilder implements Builder<BuiltPeer, BuiltPeerBuilder> {
  _$BuiltPeer _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  BuiltHostMachineBuilder _hostMachine;
  BuiltHostMachineBuilder get hostMachine =>
      _$this._hostMachine ??= new BuiltHostMachineBuilder();
  set hostMachine(BuiltHostMachineBuilder hostMachine) =>
      _$this._hostMachine = hostMachine;

  BuiltPeerBuilder();

  BuiltPeerBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _hostMachine = _$v.hostMachine?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltPeer other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$BuiltPeer;
  }

  @override
  void update(void updates(BuiltPeerBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$BuiltPeer build() {
    final result =
        _$v ?? new _$BuiltPeer._(name: name, hostMachine: hostMachine?.build());
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class BuiltHostMachine
// **************************************************************************

class _$BuiltHostMachine extends BuiltHostMachine {
  @override
  final String address;
  @override
  final int daemonPort;

  factory _$BuiltHostMachine([void updates(BuiltHostMachineBuilder b)]) =>
      (new BuiltHostMachineBuilder()..update(updates)).build();

  _$BuiltHostMachine._({this.address, this.daemonPort}) : super._() {
    if (address == null) throw new ArgumentError.notNull('address');
    if (daemonPort == null) throw new ArgumentError.notNull('daemonPort');
  }

  @override
  BuiltHostMachine rebuild(void updates(BuiltHostMachineBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltHostMachineBuilder toBuilder() =>
      new BuiltHostMachineBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! BuiltHostMachine) return false;
    return address == other.address && daemonPort == other.daemonPort;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, address.hashCode), daemonPort.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('BuiltHostMachine')
          ..add('address', address)
          ..add('daemonPort', daemonPort))
        .toString();
  }
}

class BuiltHostMachineBuilder
    implements Builder<BuiltHostMachine, BuiltHostMachineBuilder> {
  _$BuiltHostMachine _$v;

  String _address;
  String get address => _$this._address;
  set address(String address) => _$this._address = address;

  int _daemonPort;
  int get daemonPort => _$this._daemonPort;
  set daemonPort(int daemonPort) => _$this._daemonPort = daemonPort;

  BuiltHostMachineBuilder();

  BuiltHostMachineBuilder get _$this {
    if (_$v != null) {
      _address = _$v.address;
      _daemonPort = _$v.daemonPort;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltHostMachine other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$BuiltHostMachine;
  }

  @override
  void update(void updates(BuiltHostMachineBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$BuiltHostMachine build() {
    final result = _$v ??
        new _$BuiltHostMachine._(address: address, daemonPort: daemonPort);
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class BuiltNodePorts
// **************************************************************************

class _$BuiltNodePorts extends BuiltNodePorts {
  @override
  final int connectionPort;
  @override
  final int controlPort;
  @override
  final int diagnosticPort;

  factory _$BuiltNodePorts([void updates(BuiltNodePortsBuilder b)]) =>
      (new BuiltNodePortsBuilder()..update(updates)).build();

  _$BuiltNodePorts._(
      {this.connectionPort, this.controlPort, this.diagnosticPort})
      : super._() {
    if (connectionPort == null)
      throw new ArgumentError.notNull('connectionPort');
    if (controlPort == null) throw new ArgumentError.notNull('controlPort');
    if (diagnosticPort == null)
      throw new ArgumentError.notNull('diagnosticPort');
  }

  @override
  BuiltNodePorts rebuild(void updates(BuiltNodePortsBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltNodePortsBuilder toBuilder() =>
      new BuiltNodePortsBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! BuiltNodePorts) return false;
    return connectionPort == other.connectionPort &&
        controlPort == other.controlPort &&
        diagnosticPort == other.diagnosticPort;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, connectionPort.hashCode), controlPort.hashCode),
        diagnosticPort.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('BuiltNodePorts')
          ..add('connectionPort', connectionPort)
          ..add('controlPort', controlPort)
          ..add('diagnosticPort', diagnosticPort))
        .toString();
  }
}

class BuiltNodePortsBuilder
    implements Builder<BuiltNodePorts, BuiltNodePortsBuilder> {
  _$BuiltNodePorts _$v;

  int _connectionPort;
  int get connectionPort => _$this._connectionPort;
  set connectionPort(int connectionPort) =>
      _$this._connectionPort = connectionPort;

  int _controlPort;
  int get controlPort => _$this._controlPort;
  set controlPort(int controlPort) => _$this._controlPort = controlPort;

  int _diagnosticPort;
  int get diagnosticPort => _$this._diagnosticPort;
  set diagnosticPort(int diagnosticPort) =>
      _$this._diagnosticPort = diagnosticPort;

  BuiltNodePortsBuilder();

  BuiltNodePortsBuilder get _$this {
    if (_$v != null) {
      _connectionPort = _$v.connectionPort;
      _controlPort = _$v.controlPort;
      _diagnosticPort = _$v.diagnosticPort;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltNodePorts other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$BuiltNodePorts;
  }

  @override
  void update(void updates(BuiltNodePortsBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$BuiltNodePorts build() {
    final result = _$v ??
        new _$BuiltNodePorts._(
            connectionPort: connectionPort,
            controlPort: controlPort,
            diagnosticPort: diagnosticPort);
    replace(result);
    return result;
  }
}
