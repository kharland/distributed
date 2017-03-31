// GENERATED CODE - DO NOT MODIFY BY HAND

part of distributed.objects;

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: library distributed.objects
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(int)]),
          () => new MapBuilder<String, int>())
      ..add(Registration.serializer)
      ..add(BuiltMessage.serializer)
      ..add(BuiltPeer.serializer)
      ..add(BuiltHostMachine.serializer)
      ..add(SpawnRequest.serializer))
    .build();
Serializer<Registration> _$registrationSerializer =
    new _$RegistrationSerializer();
Serializer<BuiltMessage> _$builtMessageSerializer =
    new _$BuiltMessageSerializer();
Serializer<BuiltPeer> _$builtPeerSerializer = new _$BuiltPeerSerializer();
Serializer<BuiltHostMachine> _$builtHostMachineSerializer =
    new _$BuiltHostMachineSerializer();
Serializer<SpawnRequest> _$spawnRequestSerializer =
    new _$SpawnRequestSerializer();

class _$RegistrationSerializer implements StructuredSerializer<Registration> {
  @override
  final Iterable<Type> types = const [Registration, _$Registration];
  @override
  final String wireName = 'Registration';

  @override
  Iterable serialize(Serializers serializers, Registration object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
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

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'port':
          result.port = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
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
          result.sender = serializers.deserialize(value,
              specifiedType: const FullType(BuiltPeer)) as BuiltPeer;
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
          result.hostMachine = serializers.deserialize(value,
                  specifiedType: const FullType(BuiltHostMachine))
              as BuiltHostMachine;
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

class _$SpawnRequestSerializer implements StructuredSerializer<SpawnRequest> {
  @override
  final Iterable<Type> types = const [SpawnRequest, _$SpawnRequest];
  @override
  final String wireName = 'SpawnRequest';

  @override
  Iterable serialize(Serializers serializers, SpawnRequest object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
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
        case 'uri':
          result.uri = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  final int port;
  @override
  final String error;

  factory _$Registration([void updates(RegistrationBuilder b)]) =>
      (new RegistrationBuilder()..update(updates)).build() as _$Registration;

  _$Registration._({this.port, this.error}) : super._() {
    if (port == null) throw new ArgumentError.notNull('port');
    if (error == null) throw new ArgumentError.notNull('error');
  }

  @override
  Registration rebuild(void updates(RegistrationBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$RegistrationBuilder toBuilder() =>
      new _$RegistrationBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
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
  _$Registration _$v;

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
    _$v = other as _$Registration;
  }

  @override
  void update(void updates(RegistrationBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Registration build() {
    final result = _$v ?? new _$Registration._(port: port, error: error);
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
      (new BuiltMessageBuilder()..update(updates)).build() as _$BuiltMessage;

  _$BuiltMessage._({this.sender, this.category, this.contents}) : super._() {
    if (sender == null) throw new ArgumentError.notNull('sender');
    if (category == null) throw new ArgumentError.notNull('category');
    if (contents == null) throw new ArgumentError.notNull('contents');
  }

  @override
  BuiltMessage rebuild(void updates(BuiltMessageBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$BuiltMessageBuilder toBuilder() =>
      new _$BuiltMessageBuilder()..replace(this);

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
    return 'BuiltMessage {'
        'sender=${sender.toString()},\n'
        'category=${category.toString()},\n'
        'contents=${contents.toString()},\n'
        '}';
  }
}

class _$BuiltMessageBuilder extends BuiltMessageBuilder {
  _$BuiltMessage _$v;

  @override
  BuiltPeer get sender {
    _$this;
    return super.sender;
  }

  @override
  set sender(BuiltPeer sender) {
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
  String get contents {
    _$this;
    return super.contents;
  }

  @override
  set contents(String contents) {
    _$this;
    super.contents = contents;
  }

  _$BuiltMessageBuilder() : super._();

  BuiltMessageBuilder get _$this {
    if (_$v != null) {
      super.sender = _$v.sender;
      super.category = _$v.category;
      super.contents = _$v.contents;
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
            sender: sender, category: category, contents: contents);
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
      (new BuiltPeerBuilder()..update(updates)).build() as _$BuiltPeer;

  _$BuiltPeer._({this.name, this.hostMachine}) : super._() {
    if (name == null) throw new ArgumentError.notNull('name');
    if (hostMachine == null) throw new ArgumentError.notNull('hostMachine');
  }

  @override
  BuiltPeer rebuild(void updates(BuiltPeerBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$BuiltPeerBuilder toBuilder() => new _$BuiltPeerBuilder()..replace(this);

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
    return 'BuiltPeer {'
        'name=${name.toString()},\n'
        'hostMachine=${hostMachine.toString()},\n'
        '}';
  }
}

class _$BuiltPeerBuilder extends BuiltPeerBuilder {
  _$BuiltPeer _$v;

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
  BuiltHostMachine get hostMachine {
    _$this;
    return super.hostMachine;
  }

  @override
  set hostMachine(BuiltHostMachine hostMachine) {
    _$this;
    super.hostMachine = hostMachine;
  }

  _$BuiltPeerBuilder() : super._();

  BuiltPeerBuilder get _$this {
    if (_$v != null) {
      super.name = _$v.name;
      super.hostMachine = _$v.hostMachine;
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
        _$v ?? new _$BuiltPeer._(name: name, hostMachine: hostMachine);
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
      (new BuiltHostMachineBuilder()..update(updates)).build()
          as _$BuiltHostMachine;

  _$BuiltHostMachine._({this.address, this.portDaemonPort}) : super._() {
    if (address == null) throw new ArgumentError.notNull('address');
    if (portDaemonPort == null)
      throw new ArgumentError.notNull('portDaemonPort');
  }

  @override
  BuiltHostMachine rebuild(void updates(BuiltHostMachineBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$BuiltHostMachineBuilder toBuilder() =>
      new _$BuiltHostMachineBuilder()..replace(this);

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
    return 'BuiltHostMachine {'
        'address=${address.toString()},\n'
        'portDaemonPort=${portDaemonPort.toString()},\n'
        '}';
  }
}

class _$BuiltHostMachineBuilder extends BuiltHostMachineBuilder {
  _$BuiltHostMachine _$v;

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
  int get portDaemonPort {
    _$this;
    return super.portDaemonPort;
  }

  @override
  set portDaemonPort(int portDaemonPort) {
    _$this;
    super.portDaemonPort = portDaemonPort;
  }

  _$BuiltHostMachineBuilder() : super._();

  BuiltHostMachineBuilder get _$this {
    if (_$v != null) {
      super.address = _$v.address;
      super.portDaemonPort = _$v.portDaemonPort;
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

// **************************************************************************
// Generator: BuiltValueGenerator
// Target: abstract class SpawnRequest
// **************************************************************************

class _$SpawnRequest extends SpawnRequest {
  @override
  final String nodeName;
  @override
  final String uri;

  factory _$SpawnRequest([void updates(SpawnRequestBuilder b)]) =>
      (new SpawnRequestBuilder()..update(updates)).build() as _$SpawnRequest;

  _$SpawnRequest._({this.nodeName, this.uri}) : super._() {
    if (nodeName == null) throw new ArgumentError.notNull('nodeName');
    if (uri == null) throw new ArgumentError.notNull('uri');
  }

  @override
  SpawnRequest rebuild(void updates(SpawnRequestBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  _$SpawnRequestBuilder toBuilder() =>
      new _$SpawnRequestBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
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
  _$SpawnRequest _$v;

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
    _$v = other as _$SpawnRequest;
  }

  @override
  void update(void updates(SpawnRequestBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$SpawnRequest build() {
    final result = _$v ?? new _$SpawnRequest._(nodeName: nodeName, uri: uri);
    replace(result);
    return result;
  }
}
