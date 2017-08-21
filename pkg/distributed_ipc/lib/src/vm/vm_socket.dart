import 'dart:async';
import 'dart:io' as io;

import 'package:binary/binary.dart';
import 'package:collection/collection.dart';
import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/socket.dart';
import 'package:distributed.ipc/src/utf8.dart';
import 'package:distributed.ipc/src/vm/vm_lockstep_socket.dart';
import 'package:meta/meta.dart';

/// A [Socket] implementation backed by an [io.Socket].
class VmSocket extends PseudoSocket<String> {
  static Future<VmSocket> connect(io.InternetAddress address, int port) async =>
      new VmSocket(await io.Socket.connect(address, port));

  VmSocket(io.Socket socket)
      : super(socket.map<String>(utf8Decode),
            new EncodedSocketSink<List<int>, String>(socket, utf8Encoder));
}

/// A [Socket] implementation that communicates using datagrams.
///
/// Messages sent on the socket are split into chunks called [Packet]s.  The
/// size of the packet can be specified in the given [UdpSocketConfig].  This
/// splitting is done to support sending message that are usually considered too
/// large to fit within a datagram.
///
/// If a message is added to the socket while a previous message is still
/// in-flight, the new message is added to a queue and sent after all previously
/// enqueued messages.
abstract class UdpSocket implements Socket<String> {
  /// Creates a new [UdpSocket] from [config].
  static Future<UdpSocket> connect(UdpSocketConfig config) async {
    final rawSocket = await RawUdpSocket.connect(config.address, config.port);

    switch (config.transferMode) {
      case TransferType.lockstep:
        return new VmLockStepSocket.wrap(rawSocket);
      case TransferType.fast:
        throw new UnimplementedError();
      default:
        throw new UnsupportedError('${config.transferMode}');
    }
  }
}

/// Emits a [Stream] of [UdpSocket].
class UdpSocketServer extends StreamView<UdpSocket>
    implements Stream<UdpSocket> {
  /// Binds a new [UdpSocketServer] to [address] and [port].
  static Future<UdpSocketServer> bind(
    io.InternetAddress address,
    int port,
  ) {
    return null;
  }

  UdpSocketServer(Stream<UdpSocket> stream) : super(stream);
}

/// A [Socket] implementation that communicates using datagrams.
@visibleForTesting
class RawUdpSocket extends PseudoSocket<List<int>> {
  /// The local address of this [RawUdpSocket].
  final String localAddress;

  /// The local port of this [RawUdpSocket].
  final int localPort;

  final _UdpSocketWriter _writer;

  /// Creates a [RawUdpSocket] connected to [address] and [port].
  static Future<RawUdpSocket> connect(
    io.InternetAddress address,
    int port,
  ) async {
    final udpSocket = new _BroadcastUdpSocket(await io.RawDatagramSocket.bind(
      io.InternetAddress.ANY_IP_V4,
      0,
    ));
    return new RawUdpSocket(
      udpSocket.localAddress,
      udpSocket.localPort,
      new _UdpSocketWriter(udpSocket, address, port),
      new _UdpSocketReader(udpSocket).stream,
    ).._connect();
  }

  RawUdpSocket(
    this.localAddress,
    this.localPort,
    this._writer,
    Stream<List<int>> byteStream,
  )
      : super(byteStream, _writer);

  /// The address of the remote peer connected to this socket.
  String get remoteAddress => _writer.address.address;

  /// The port of the remote peer connected to this socket.
  int get remotePort => _writer.port;

  void _connect() {
    add(new GreetingDatagram(localAddress, localPort).toBytes());
  }
}

/// Emits a [Stream] of [RawUdpSocket].
class DatagramServerSocket extends StreamView<RawUdpSocket>
    implements Stream<RawUdpSocket> {
  final _BroadcastUdpSocket _socket;

  /// Binds a new [DatagramServerSocket] to [address] and [port].
  static Future<DatagramServerSocket> bind(
    io.InternetAddress address,
    int port,
  ) async {
    final udpSocket = new _BroadcastUdpSocket(await io.RawDatagramSocket.bind(
      io.InternetAddress.ANY_IP_V4,
      port,
    ));
    return new DatagramServerSocket(udpSocket);
  }

  /// Returns a stream of [RawUdpSocket] connections initiated on [serverSocket].
  static Stream<RawUdpSocket> _socketStream(
      _BroadcastUdpSocket serverSocket) async* {
    final serverSocketReader = new _UdpSocketReader(serverSocket);
    yield* serverSocketReader.stream
        .where(GreetingDatagram.isGreeting)
        .map((bytes) {
      final request = new GreetingDatagram.fromBytes(bytes);
      final reader = new _UdpSocketReader(serverSocket, closeOnClosed: false);
      final writer = new _UdpSocketWriter(
        serverSocket,
        new io.InternetAddress(request.senderAddress),
        request.senderPort,
      );

      return new RawUdpSocket(
        serverSocket.localAddress,
        serverSocket.localPort,
        writer,
        reader.stream,
      );
    });
  }

  DatagramServerSocket(this._socket) : super(_socketStream(_socket));

  /// Permanently closes this socket.
  void close() {
    _socket.close();
  }
}

/// An object used by a [RawUdpSocket] to exchange information with a remote peer.
class GreetingDatagram {
  static final _listEq = const ListEquality().equals;

  /// The leading sequence of bytes that identifies a [GreetingDatagram].
  static const HEADER = const [0x0, 0x7, 0x7, 0x3, 0x4];

  /// The address of the peer that sent this request.
  final String senderAddress;

  /// The port of the peer that sent this request.
  final int senderPort;

  /// Returns true iff [bytes] has the signature of a [GreetingDatagram].
  static bool isGreeting(List<int> bytes) => _listEq(GreetingDatagram.HEADER,
      bytes.take(GreetingDatagram.HEADER.length).toList());

  /// Decodes a [GreetingDatagram] from [bytes].
  factory GreetingDatagram.fromBytes(List<int> bytes) {
    final bytesNoHeader = bytes.skip(HEADER.length);
    final addressLength = bytesNoHeader.first;
    final port = pack(bytesNoHeader.skip(1).take(2).toList());
    final address = utf8Decode(bytesNoHeader.skip(3).take(addressLength));
    return new GreetingDatagram(address, port);
  }

  GreetingDatagram(this.senderAddress, this.senderPort);

  /// Converts this request into a list of bytes.
  ///
  /// The encoding is:
  ///
  /// bytes: | 5      | 1            | 2          | address_len    |
  /// data:  | HEADER | address_len | sender_port | sender_address |
  ///
  /// This assumes [senderAddress] is a valid IPv4 address string.
  List<int> toBytes() {
    final List<int> address = utf8Encode(senderAddress);
    return new List.unmodifiable([]
      ..addAll(HEADER)
      ..add(address.length)
      ..add((senderPort >> 8) & 0xFF)
      ..add(senderPort & 0xFF)
      ..addAll(address));
  }
}

/// Wraps an [io.RawDatagramSocket] as a broadcast stream.
class _BroadcastUdpSocket extends StreamView<io.RawSocketEvent>
    implements Stream<io.RawSocketEvent> {
  final io.RawDatagramSocket _socket;
  io.Datagram _latestDatagram;

  _BroadcastUdpSocket._(this._socket, Stream<io.RawSocketEvent> broadcastStream)
      : super(broadcastStream);

  factory _BroadcastUdpSocket(io.RawDatagramSocket socket) {
    final _output =
        new StreamController<io.RawSocketEvent>.broadcast(sync: true);
    socket.forEach(_output.add);
    return new _BroadcastUdpSocket._(socket, _output.stream);
  }

  bool get writeEventsEnabled => _socket.writeEventsEnabled;

  set writeEventsEnabled(bool value) {
    _socket.writeEventsEnabled = value;
  }

  /// The local address of this socket.
  String get localAddress => _socket.address.address;

  /// The local port of this socket.
  int get localPort => _socket.port;

  /// Returns the most recent [io.Datagram] received by this socket.
  ///
  /// Unlike a normal [io.RawDatagramSocket], calling [receive] multiple times
  /// will always return the most recent datagram.  Null is returned iff no
  /// datagram has been received by this socket.
  io.Datagram receive() {
    _latestDatagram = _socket.receive() ?? _latestDatagram;
    return _latestDatagram;
  }

  void close() {
    _socket.close();
  }

  void send(List<int> event, io.InternetAddress address, int port) {
    _socket.send(event, address, port);
  }
}

/// An [EventSink] that writes data to a [RawDatagramSocket].
///
/// The writer can only write to a single address and port.
class _UdpSocketWriter extends EventSink<List<int>> {
  final _BroadcastUdpSocket _socket;
  final io.InternetAddress address;
  final int port;

  _UdpSocketWriter(this._socket, this.address, this.port);

  @override
  void add(List<int> event) {
    _socket.send(event, address, port);
  }

  @override
  void addError(_, [StackTrace __]) {
    throw new UnsupportedError('addError');
  }

  @override
  void close() {
    _socket.close();
  }
}

/// Reads from a [RawDatagramSocket].
///
/// Translated data are emitted as [String]s on [stream].
class _UdpSocketReader {
  final _BroadcastUdpSocket _socket;
  final _output = new StreamController<List<int>>();

  /// Whether this reader should close [_socket] when a CLOSED event is
  /// received.  Set this to false to prevent many readers from attempting to
  /// close the same socket.
  final bool closeOnClosed;

  _UdpSocketReader(this._socket, {this.closeOnClosed = true}) {
    _socket
      ..writeEventsEnabled = false
      ..forEach(_handleEvent);
  }

  Stream<List<int>> get stream => _output.stream;

  void _handleEvent(io.RawSocketEvent event) {
    switch (event) {
      case io.RawSocketEvent.CLOSED:
        if (closeOnClosed) {
          _socket.close();
        }
        break;
      case io.RawSocketEvent.READ:
        final datagram = _socket.receive();
        _output.add(datagram.data);
        break;
      default:
        throw new UnsupportedError('$event');
    }
    // RawSocketEvent.READ_CLOSED will never be received; The remote peer cannot
    // close the socket.
  }
}
