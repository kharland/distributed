// GENERATED CODE - DO NOT MODIFY BY HAND

part of distributed.objects;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: library distributed.objects
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(BuiltHostMachine.serializer)
      ..add(BuiltMessage.serializer)
      ..add(BuiltPeer.serializer)
      ..add(Registration.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>()))
    .build();
Serializer<Registration> _$registrationSerializer =
    new _$RegistrationSerializer();
Serializer<BuiltMessage> _$builtMessageSerializer =
    new _$BuiltMessageSerializer();
Serializer<BuiltPeer> _$builtPeerSerializer = new _$BuiltPeerSerializer();
Serializer<BuiltHostMachine> _$builtHostMachineSerializer =
    new _$BuiltHostMachineSerializer();

class _$RegistrationSerializer implements StructuredSerializer<Registration> {
  @override
  final Iterable<Type> types = const [Registration, _$Registration];
  @override
  final String wireName = 'Registration';

  @override
  Iterable serialize(Serializers serializers, Registration object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'ports',
      serializers.serialize(object.ports,
          specifiedType:
              const FullType(BuiltList, const [const FullType(int)])),
      'error',
      serializers.serialize(object.error,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Registration deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new RegistrationBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ports':
          result.ports.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(int)]))
              as BuiltList<int>);
          break;
        case 'error':
          result.error = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
      'portDaemonPort',
      serializers.serialize(object.portDaemonPort,
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
        case 'portDaemonPort':
          result.portDaemonPort = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class Registration
// **************************************************************************

class _$Registration extends Registration {
  @override
  final BuiltList<int> ports;
  @override
  final String error;

  factory _$Registration([void updates(RegistrationBuilder b)]) =>
      (new RegistrationBuilder()..update(updates)).build();

  _$Registration._({this.ports, this.error}) : super._() {
    if (ports == null) throw new ArgumentError.notNull('ports');
    if (error == null) throw new ArgumentError.notNull('error');
  }

  @override
  Registration rebuild(void updates(RegistrationBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  RegistrationBuilder toBuilder() => new RegistrationBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! Registration) return false;
    return ports == other.ports && error == other.error;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, ports.hashCode), error.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Registration')
          ..add('ports', ports)
          ..add('error', error))
        .toString();
  }
}

class RegistrationBuilder
    implements Builder<Registration, RegistrationBuilder> {
  _$Registration _$v;

  ListBuilder<int> _ports;
  ListBuilder<int> get ports => _$this._ports ??= new ListBuilder<int>();
  set ports(ListBuilder<int> ports) => _$this._ports = ports;

  String _error;
  String get error => _$this._error;
  set error(String error) => _$this._error = error;

  RegistrationBuilder();

  RegistrationBuilder get _$this {
    if (_$v != null) {
      _ports = _$v.ports?.toBuilder();
      _error = _$v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Registration other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$Registration;
  }

  @override
  void update(void updates(RegistrationBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Registration build() {
    final result =
        _$v ?? new _$Registration._(ports: ports?.build(), error: error);
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
  final int portDaemonPort;

  factory _$BuiltHostMachine([void updates(BuiltHostMachineBuilder b)]) =>
      (new BuiltHostMachineBuilder()..update(updates)).build();

  _$BuiltHostMachine._({this.address, this.portDaemonPort}) : super._() {
    if (address == null) throw new ArgumentError.notNull('address');
    if (portDaemonPort == null)
      throw new ArgumentError.notNull('portDaemonPort');
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
    return address == other.address && portDaemonPort == other.portDaemonPort;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, address.hashCode), portDaemonPort.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('BuiltHostMachine')
          ..add('address', address)
          ..add('portDaemonPort', portDaemonPort))
        .toString();
  }
}

class BuiltHostMachineBuilder
    implements Builder<BuiltHostMachine, BuiltHostMachineBuilder> {
  _$BuiltHostMachine _$v;

  String _address;
  String get address => _$this._address;
  set address(String address) => _$this._address = address;

  int _portDaemonPort;
  int get portDaemonPort => _$this._portDaemonPort;
  set portDaemonPort(int portDaemonPort) =>
      _$this._portDaemonPort = portDaemonPort;

  BuiltHostMachineBuilder();

  BuiltHostMachineBuilder get _$this {
    if (_$v != null) {
      _address = _$v.address;
      _portDaemonPort = _$v.portDaemonPort;
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
        new _$BuiltHostMachine._(
            address: address, portDaemonPort: portDaemonPort);
    replace(result);
    return result;
  }
}
