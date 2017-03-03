// GENERATED CODE - DO NOT MODIFY BY HAND

part of distributed.objects.src.peer;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: library distributed.objects.src.peer
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(Registration.serializer)
      ..add(Message.serializer)
      ..add(Peer.serializer)
      ..add(HostMachine.serializer))
    .build();
Serializer<Registration> _$registrationSerializer =
    new _$RegistrationSerializer();
Serializer<Message> _$messageSerializer = new _$MessageSerializer();
Serializer<Peer> _$peerSerializer = new _$PeerSerializer();
Serializer<HostMachine> _$hostMachineSerializer = new _$HostMachineSerializer();

class _$RegistrationSerializer implements StructuredSerializer<Registration> {
  @override
  final Iterable<Type> types = const [Registration, _$Registration];
  @override
  final String wireName = 'Registration';

  @override
  Iterable serialize(Serializers serializers, Registration object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = [
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'port',
      serializers.serialize(object.port, specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  Registration deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new RegistrationBuilder();

    var key;
    var value;
    var expectingKey = true;
    for (final item in serialized) {
      if (expectingKey) {
        key = item;
        expectingKey = false;
      } else {
        value = item;
        expectingKey = true;

        switch (key as String) {
          case 'name':
            result.name = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
            break;
          case 'port':
            result.port = serializers.deserialize(value,
                specifiedType: const FullType(int)) as dynamic;
            break;
        }
      }
    }

    return result.build();
  }
}

class _$MessageSerializer implements StructuredSerializer<Message> {
  @override
  final Iterable<Type> types = const [Message, _$Message];
  @override
  final String wireName = 'Message';

  @override
  Iterable serialize(Serializers serializers, Message object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = [
      'category',
      serializers.serialize(object.category,
          specifiedType: const FullType(String)),
      'payload',
      serializers.serialize(object.payload,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Message deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new MessageBuilder();

    var key;
    var value;
    var expectingKey = true;
    for (final item in serialized) {
      if (expectingKey) {
        key = item;
        expectingKey = false;
      } else {
        value = item;
        expectingKey = true;

        switch (key as String) {
          case 'category':
            result.category = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
            break;
          case 'payload':
            result.payload = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
            break;
        }
      }
    }

    return result.build();
  }
}

class _$PeerSerializer implements StructuredSerializer<Peer> {
  @override
  final Iterable<Type> types = const [Peer, _$Peer];
  @override
  final String wireName = 'Peer';

  @override
  Iterable serialize(Serializers serializers, Peer object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = [
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'hostMachine',
      serializers.serialize(object.hostMachine,
          specifiedType: const FullType(HostMachine)),
    ];

    return result;
  }

  @override
  Peer deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new PeerBuilder();

    var key;
    var value;
    var expectingKey = true;
    for (final item in serialized) {
      if (expectingKey) {
        key = item;
        expectingKey = false;
      } else {
        value = item;
        expectingKey = true;

        switch (key as String) {
          case 'name':
            result.name = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
            break;
          case 'hostMachine':
            result.hostMachine = serializers.deserialize(value,
                specifiedType: const FullType(HostMachine)) as dynamic;
            break;
        }
      }
    }

    return result.build();
  }
}

class _$HostMachineSerializer implements StructuredSerializer<HostMachine> {
  @override
  final Iterable<Type> types = const [HostMachine, _$HostMachine];
  @override
  final String wireName = 'HostMachine';

  @override
  Iterable serialize(Serializers serializers, HostMachine object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = [
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
  HostMachine deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new HostMachineBuilder();

    var key;
    var value;
    var expectingKey = true;
    for (final item in serialized) {
      if (expectingKey) {
        key = item;
        expectingKey = false;
      } else {
        value = item;
        expectingKey = true;

        switch (key as String) {
          case 'address':
            result.address = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
            break;
          case 'daemonPort':
            result.daemonPort = serializers.deserialize(value,
                specifiedType: const FullType(int)) as dynamic;
            break;
        }
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
  final String name;
  @override
  final int port;

  factory _$Registration([updates(RegistrationBuilder b)]) =>
      (new RegistrationBuilder()..update(updates)).build();

  _$Registration._({this.name, this.port}) : super._() {
    if (name == null) throw new ArgumentError.notNull('name');
    if (port == null) throw new ArgumentError.notNull('port');
  }

  @override
  Registration rebuild(updates(RegistrationBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$RegistrationBuilder toBuilder() =>
      new _$RegistrationBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (other is! Registration) return false;
    return name == other.name && port == other.port;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, name.hashCode), port.hashCode));
  }

  @override
  String toString() {
    return 'Registration {'
        'name=${name.toString()},\n'
        'port=${port.toString()},\n'
        '}';
  }
}

class _$RegistrationBuilder extends RegistrationBuilder {
  Registration _$v;

  @override
  String get name {
    _$this;
    return super.name;
  }

  @override
  set name(String name) {
    _$this;
    super.name = name;
  }

  @override
  int get port {
    _$this;
    return super.port;
  }

  @override
  set port(int port) {
    _$this;
    super.port = port;
  }

  _$RegistrationBuilder() : super._();

  RegistrationBuilder get _$this {
    if (_$v != null) {
      super.name = _$v.name;
      super.port = _$v.port;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Registration other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other;
  }

  @override
  void update(updates(RegistrationBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  Registration build() {
    final result = _$v ?? new _$Registration._(name: name, port: port);
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class Message
// **************************************************************************

class _$Message extends Message {
  @override
  final String category;
  @override
  final String payload;

  factory _$Message([updates(MessageBuilder b)]) =>
      (new MessageBuilder()..update(updates)).build();

  _$Message._({this.category, this.payload}) : super._() {
    if (category == null) throw new ArgumentError.notNull('category');
    if (payload == null) throw new ArgumentError.notNull('payload');
  }

  @override
  Message rebuild(updates(MessageBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$MessageBuilder toBuilder() => new _$MessageBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (other is! Message) return false;
    return category == other.category && payload == other.payload;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, category.hashCode), payload.hashCode));
  }

  @override
  String toString() {
    return 'Message {'
        'category=${category.toString()},\n'
        'payload=${payload.toString()},\n'
        '}';
  }
}

class _$MessageBuilder extends MessageBuilder {
  Message _$v;

  @override
  String get category {
    _$this;
    return super.category;
  }

  @override
  set category(String category) {
    _$this;
    super.category = category;
  }

  @override
  String get payload {
    _$this;
    return super.payload;
  }

  @override
  set payload(String payload) {
    _$this;
    super.payload = payload;
  }

  _$MessageBuilder() : super._();

  MessageBuilder get _$this {
    if (_$v != null) {
      super.category = _$v.category;
      super.payload = _$v.payload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Message other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other;
  }

  @override
  void update(updates(MessageBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  Message build() {
    final result = _$v ?? new _$Message._(category: category, payload: payload);
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class Peer
// **************************************************************************

class _$Peer extends Peer {
  @override
  final String name;
  @override
  final HostMachine hostMachine;

  factory _$Peer([updates(PeerBuilder b)]) =>
      (new PeerBuilder()..update(updates)).build();

  _$Peer._({this.name, this.hostMachine}) : super._() {
    if (name == null) throw new ArgumentError.notNull('name');
    if (hostMachine == null) throw new ArgumentError.notNull('hostMachine');
  }

  @override
  Peer rebuild(updates(PeerBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$PeerBuilder toBuilder() => new _$PeerBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (other is! Peer) return false;
    return name == other.name && hostMachine == other.hostMachine;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, name.hashCode), hostMachine.hashCode));
  }

  @override
  String toString() {
    return 'Peer {'
        'name=${name.toString()},\n'
        'hostMachine=${hostMachine.toString()},\n'
        '}';
  }
}

class _$PeerBuilder extends PeerBuilder {
  Peer _$v;

  @override
  String get name {
    _$this;
    return super.name;
  }

  @override
  set name(String name) {
    _$this;
    super.name = name;
  }

  @override
  HostMachine get hostMachine {
    _$this;
    return super.hostMachine;
  }

  @override
  set hostMachine(HostMachine hostMachine) {
    _$this;
    super.hostMachine = hostMachine;
  }

  _$PeerBuilder() : super._();

  PeerBuilder get _$this {
    if (_$v != null) {
      super.name = _$v.name;
      super.hostMachine = _$v.hostMachine;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Peer other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other;
  }

  @override
  void update(updates(PeerBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  Peer build() {
    final result = _$v ?? new _$Peer._(name: name, hostMachine: hostMachine);
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class HostMachine
// **************************************************************************

class _$HostMachine extends HostMachine {
  @override
  final String address;
  @override
  final int daemonPort;

  factory _$HostMachine([updates(HostMachineBuilder b)]) =>
      (new HostMachineBuilder()..update(updates)).build();

  _$HostMachine._({this.address, this.daemonPort}) : super._() {
    if (address == null) throw new ArgumentError.notNull('address');
    if (daemonPort == null) throw new ArgumentError.notNull('daemonPort');
  }

  @override
  HostMachine rebuild(updates(HostMachineBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$HostMachineBuilder toBuilder() => new _$HostMachineBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (other is! HostMachine) return false;
    return address == other.address && daemonPort == other.daemonPort;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, address.hashCode), daemonPort.hashCode));
  }

  @override
  String toString() {
    return 'HostMachine {'
        'address=${address.toString()},\n'
        'daemonPort=${daemonPort.toString()},\n'
        '}';
  }
}

class _$HostMachineBuilder extends HostMachineBuilder {
  HostMachine _$v;

  @override
  String get address {
    _$this;
    return super.address;
  }

  @override
  set address(String address) {
    _$this;
    super.address = address;
  }

  @override
  int get daemonPort {
    _$this;
    return super.daemonPort;
  }

  @override
  set daemonPort(int daemonPort) {
    _$this;
    super.daemonPort = daemonPort;
  }

  _$HostMachineBuilder() : super._();

  HostMachineBuilder get _$this {
    if (_$v != null) {
      super.address = _$v.address;
      super.daemonPort = _$v.daemonPort;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HostMachine other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other;
  }

  @override
  void update(updates(HostMachineBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  HostMachine build() {
    final result =
        _$v ?? new _$HostMachine._(address: address, daemonPort: daemonPort);
    replace(result);
    return result;
  }
}
