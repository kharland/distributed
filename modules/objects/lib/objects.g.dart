// GENERATED CODE - DO NOT MODIFY BY HAND

part of distributed.objects.src.peer;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: library distributed.objects.src.peer
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(PortAssignmentList.serializer)
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(int)]),
          () => new MapBuilder<String, int>())
      ..add(Registration.serializer)
      ..add(Message.serializer)
      ..add(Peer.serializer)
      ..add(HostMachine.serializer)
      ..add(SpawnRequest.serializer))
    .build();
Serializer<PortAssignmentList> _$portAssignmentListSerializer =
    new _$PortAssignmentListSerializer();
Serializer<Registration> _$registrationSerializer =
    new _$RegistrationSerializer();
Serializer<Message> _$messageSerializer = new _$MessageSerializer();
Serializer<Peer> _$peerSerializer = new _$PeerSerializer();
Serializer<HostMachine> _$hostMachineSerializer = new _$HostMachineSerializer();
Serializer<SpawnRequest> _$spawnRequestSerializer =
    new _$SpawnRequestSerializer();

class _$PortAssignmentListSerializer
    implements StructuredSerializer<PortAssignmentList> {
  @override
  final Iterable<Type> types = const [PortAssignmentList, _$PortAssignmentList];
  @override
  final String wireName = 'PortAssignmentList';

  @override
  Iterable serialize(Serializers serializers, PortAssignmentList object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = [
      'assignments',
      serializers.serialize(object.assignments,
          specifiedType: const FullType(
              BuiltMap, const [const FullType(String), const FullType(int)])),
    ];

    return result;
  }

  @override
  PortAssignmentList deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new PortAssignmentListBuilder();

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
          case 'assignments':
            result.assignments.replace(serializers.deserialize(value,
                specifiedType: const FullType(BuiltMap, const [
                  const FullType(String),
                  const FullType(int)
                ])) as dynamic);
            break;
        }
      }
    }

    return result.build();
  }
}

class _$RegistrationSerializer implements StructuredSerializer<Registration> {
  @override
  final Iterable<Type> types = const [Registration, _$Registration];
  @override
  final String wireName = 'Registration';

  @override
  Iterable serialize(Serializers serializers, Registration object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = [
      'port',
      serializers.serialize(object.port, specifiedType: const FullType(int)),
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
          case 'port':
            result.port = serializers.deserialize(value,
                specifiedType: const FullType(int)) as dynamic;
            break;
          case 'error':
            result.error = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
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
      'sender',
      serializers.serialize(object.sender, specifiedType: const FullType(Peer)),
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
          case 'sender':
            result.sender = serializers.deserialize(value,
                specifiedType: const FullType(Peer)) as dynamic;
            break;
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

class _$SpawnRequestSerializer implements StructuredSerializer<SpawnRequest> {
  @override
  final Iterable<Type> types = const [SpawnRequest, _$SpawnRequest];
  @override
  final String wireName = 'SpawnRequest';

  @override
  Iterable serialize(Serializers serializers, SpawnRequest object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = [
      'nodeName',
      serializers.serialize(object.nodeName,
          specifiedType: const FullType(String)),
      'uri',
      serializers.serialize(object.uri, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  SpawnRequest deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new SpawnRequestBuilder();

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
          case 'nodeName':
            result.nodeName = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
            break;
          case 'uri':
            result.uri = serializers.deserialize(value,
                specifiedType: const FullType(String)) as dynamic;
            break;
        }
      }
    }

    return result.build();
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class PortAssignmentList
// **************************************************************************

class _$PortAssignmentList extends PortAssignmentList {
  @override
  final BuiltMap<String, int> assignments;

  factory _$PortAssignmentList([updates(PortAssignmentListBuilder b)]) =>
      (new PortAssignmentListBuilder()..update(updates)).build();

  _$PortAssignmentList._({this.assignments}) : super._() {
    if (assignments == null) throw new ArgumentError.notNull('assignments');
  }

  @override
  PortAssignmentList rebuild(updates(PortAssignmentListBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$PortAssignmentListBuilder toBuilder() =>
      new _$PortAssignmentListBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (other is! PortAssignmentList) return false;
    return assignments == other.assignments;
  }

  @override
  int get hashCode {
    return $jf($jc(0, assignments.hashCode));
  }

  @override
  String toString() {
    return 'PortAssignmentList {'
        'assignments=${assignments.toString()},\n'
        '}';
  }
}

class _$PortAssignmentListBuilder extends PortAssignmentListBuilder {
  PortAssignmentList _$v;

  @override
  MapBuilder<String, int> get assignments {
    _$this;
    return super.assignments ??= new MapBuilder<String, int>();
  }

  @override
  set assignments(MapBuilder<String, int> assignments) {
    _$this;
    super.assignments = assignments;
  }

  _$PortAssignmentListBuilder() : super._();

  PortAssignmentListBuilder get _$this {
    if (_$v != null) {
      super.assignments = _$v.assignments?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PortAssignmentList other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other;
  }

  @override
  void update(updates(PortAssignmentListBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  PortAssignmentList build() {
    final result =
        _$v ?? new _$PortAssignmentList._(assignments: assignments?.build());
    replace(result);
    return result;
  }
}

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class Registration
// **************************************************************************

class _$Registration extends Registration {
  @override
  final int port;
  @override
  final String error;

  factory _$Registration([updates(RegistrationBuilder b)]) =>
      (new RegistrationBuilder()..update(updates)).build();

  _$Registration._({this.port, this.error}) : super._() {
    if (port == null) throw new ArgumentError.notNull('port');
    if (error == null) throw new ArgumentError.notNull('error');
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
    return port == other.port && error == other.error;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, port.hashCode), error.hashCode));
  }

  @override
  String toString() {
    return 'Registration {'
        'port=${port.toString()},\n'
        'error=${error.toString()},\n'
        '}';
  }
}

class _$RegistrationBuilder extends RegistrationBuilder {
  Registration _$v;

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

  @override
  String get error {
    _$this;
    return super.error;
  }

  @override
  set error(String error) {
    _$this;
    super.error = error;
  }

  _$RegistrationBuilder() : super._();

  RegistrationBuilder get _$this {
    if (_$v != null) {
      super.port = _$v.port;
      super.error = _$v.error;
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
    final result = _$v ?? new _$Registration._(port: port, error: error);
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
  final Peer sender;
  @override
  final String category;
  @override
  final String payload;

  factory _$Message([updates(MessageBuilder b)]) =>
      (new MessageBuilder()..update(updates)).build();

  _$Message._({this.sender, this.category, this.payload}) : super._() {
    if (sender == null) throw new ArgumentError.notNull('sender');
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
    return sender == other.sender &&
        category == other.category &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, sender.hashCode), category.hashCode), payload.hashCode));
  }

  @override
  String toString() {
    return 'Message {'
        'sender=${sender.toString()},\n'
        'category=${category.toString()},\n'
        'payload=${payload.toString()},\n'
        '}';
  }
}

class _$MessageBuilder extends MessageBuilder {
  Message _$v;

  @override
  Peer get sender {
    _$this;
    return super.sender;
  }

  @override
  set sender(Peer sender) {
    _$this;
    super.sender = sender;
  }

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
      super.sender = _$v.sender;
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
    final result = _$v ??
        new _$Message._(sender: sender, category: category, payload: payload);
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

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class SpawnRequest
// **************************************************************************

class _$SpawnRequest extends SpawnRequest {
  @override
  final String nodeName;
  @override
  final String uri;

  factory _$SpawnRequest([updates(SpawnRequestBuilder b)]) =>
      (new SpawnRequestBuilder()..update(updates)).build();

  _$SpawnRequest._({this.nodeName, this.uri}) : super._() {
    if (nodeName == null) throw new ArgumentError.notNull('nodeName');
    if (uri == null) throw new ArgumentError.notNull('uri');
  }

  @override
  SpawnRequest rebuild(updates(SpawnRequestBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$SpawnRequestBuilder toBuilder() =>
      new _$SpawnRequestBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (other is! SpawnRequest) return false;
    return nodeName == other.nodeName && uri == other.uri;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, nodeName.hashCode), uri.hashCode));
  }

  @override
  String toString() {
    return 'SpawnRequest {'
        'nodeName=${nodeName.toString()},\n'
        'uri=${uri.toString()},\n'
        '}';
  }
}

class _$SpawnRequestBuilder extends SpawnRequestBuilder {
  SpawnRequest _$v;

  @override
  String get nodeName {
    _$this;
    return super.nodeName;
  }

  @override
  set nodeName(String nodeName) {
    _$this;
    super.nodeName = nodeName;
  }

  @override
  String get uri {
    _$this;
    return super.uri;
  }

  @override
  set uri(String uri) {
    _$this;
    super.uri = uri;
  }

  _$SpawnRequestBuilder() : super._();

  SpawnRequestBuilder get _$this {
    if (_$v != null) {
      super.nodeName = _$v.nodeName;
      super.uri = _$v.uri;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SpawnRequest other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other;
  }

  @override
  void update(updates(SpawnRequestBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  SpawnRequest build() {
    final result = _$v ?? new _$SpawnRequest._(nodeName: nodeName, uri: uri);
    replace(result);
    return result;
  }
}
