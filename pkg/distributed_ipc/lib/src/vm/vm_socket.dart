import 'dart:async';
import 'dart:io' as io;

import 'package:binary/binary.dart';
import 'package:collection/collection.dart';
import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/socket.dart';
import 'package:distributed.ipc/src/utf8.dart';
import 'package:distributed.ipc/src/vm/vm_lockstep_socket.dart';
import 'package:meta/meta.dart';

/// A [Socket] implementation backed by an [io.Socket].
class VmSocket extends GenericSocket<String> {
  static Future<VmSocket> connect(io.InternetAddress address, int port) async =>
      new VmSocket(await io.Socket.connect(address, port));

  VmSocket(io.Socket socket)
      : super(socket.map<String>(utf8Decode),
            new EncodedSocketSink<List<int>, String>(socket, utf8Encoder));
}

/// A [Socket] implementation that communicates via datagrams.
abstract class VmDatagramSocket implements Socket<String> {
  /// Creates a new [VmDatagramSocket] from [config].
  static Future<VmDatagramSocket> connect(DatagramSocketConfig config) async {
    final rawSocket = await DatagramSocket.connect(config.address, config.port);

    switch (config.transferMode) {
      case TransferMode.lockstep:
        return new VmLockStepSocket.wrap(rawSocket);
      case TransferMode.fast:
        throw new UnimplementedError();
      default:
        throw new UnsupportedError('${config.transferMode}');
    }
  }
}

/// Emits a [Stream] of [VmDatagramSocket].
class VmDatagramSocketServer extends StreamView<VmDatagramSocket>
    implements Stream<VmDatagramSocket> {
  /// Binds a new [VmDatagramSocketServer] to [address] and [port].
  static Future<VmDatagramSocketServer> bind(
    io.InternetAddress address,
    int port,
  ) {
    return null;
  }

  VmDatagramSocketServer(Stream<VmDatagramSocket> stream) : super(stream);
}

/// A [Socket] implementation that communicates using datagrams.
@visibleForTesting
class DatagramSocket extends GenericSocket<List<int>> {
  /// The local address of this [DatagramSocket].
  final String localAddress;

  /// The local port of this [DatagramSocket].
  final int localPort;

  final _DatagramSocketWriter _writer;

  static Future<DatagramSocket> connect(
    io.InternetAddress address,
    int port,
  ) async {
    final udpSocket =
        new _BroadcastDatagramSocket(await io.RawDatagramSocket.bind(
      io.InternetAddress.ANY_IP_V4,
      0,
    ));
    return new DatagramSocket(
      udpSocket.localAddress,
      udpSocket.localPort,
      new _DatagramSocketWriter(udpSocket, address, port),
      new _DatagramSocketReader(udpSocket),
    ).._connect();
  }

  String get remoteAddress => _writer.address.address;

  int get remotePort => _writer.port;

  void _connect() {
    add(new DatagramConnectRequest(localAddress, localPort).toBytes());
  }

  DatagramSocket(
    this.localAddress,
    this.localPort,
    this._writer,
    _DatagramSocketReader reader,
  )
      : super(reader.stream, _writer);
}

/// Emits a [Stream] of [DatagramSocket].
class DatagramServerSocket extends StreamView<DatagramSocket>
    implements Stream<DatagramSocket> {
  static final _listEq = const ListEquality().equals;

  final _BroadcastDatagramSocket _socket;

  /// Binds a new [DatagramServerSocket] to [address] and [port].
  static Future<DatagramServerSocket> bind(
    io.InternetAddress address,
    int port,
  ) async {
    final udpSocket =
        new _BroadcastDatagramSocket(await io.RawDatagramSocket.bind(
      io.InternetAddress.ANY_IP_V4,
      port,
    ));
    return new DatagramServerSocket(udpSocket);
  }

  static bool _isConnectRequest(List<int> bytes) => _listEq(
      DatagramConnectRequest.HEADER,
      bytes.take(DatagramConnectRequest.HEADER.length).toList());

  static Stream<DatagramSocket> _socketStream(
      _BroadcastDatagramSocket serverSocket) async* {
    final serverSocketReader = new _DatagramSocketReader(serverSocket);
    yield* serverSocketReader.stream.where(_isConnectRequest).map((bytes) {
      var request = new DatagramConnectRequest.fromBytes(bytes);
      return new DatagramSocket(
        serverSocket.localAddress,
        serverSocket.localPort,
        new _DatagramSocketWriter(
          serverSocket,
          new io.InternetAddress(request.senderAddress),
          request.senderPort,
        ),
        new _DatagramSocketReader(serverSocket, closeOnClosed: false),
      );
    });
  }

  DatagramServerSocket(this._socket) : super(_socketStream(_socket));

  void close() {
    _socket.close();
  }
}

/// Used to initiate a request with a [DatagramSocket].
class DatagramConnectRequest {
  /// The leading sequence of bytes that identifies a [DatagramConnectRequest].
  static const HEADER = const [0x0, 0x7, 0x7, 0x3, 0x4];

  /// The address of the peer that sent this request.
  final String senderAddress;

  /// The port of the peer that sent this request.
  final int senderPort;

  factory DatagramConnectRequest.fromBytes(List<int> bytes) {
    final bytesNoHeader = bytes.skip(HEADER.length);
    final addressLength = bytesNoHeader.first;
    final port = pack(bytesNoHeader.skip(1).take(2).toList());
    final address = utf8Decode(bytesNoHeader.skip(3).take(addressLength));
    return new DatagramConnectRequest(address, port);
  }

  DatagramConnectRequest(this.senderAddress, this.senderPort);

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
class _BroadcastDatagramSocket extends StreamView<io.RawSocketEvent>
    implements Stream<io.RawSocketEvent> {
  final io.RawDatagramSocket _socket;

  _BroadcastDatagramSocket._(
      this._socket, Stream<io.RawSocketEvent> broadcastStream)
      : super(broadcastStream);

  factory _BroadcastDatagramSocket(io.RawDatagramSocket socket) {
    final _broadcaster =
        new StreamController<io.RawSocketEvent>.broadcast(sync: true);
    socket.forEach(_broadcaster.add);
    return new _BroadcastDatagramSocket._(socket, _broadcaster.stream);
  }

  bool get writeEventsEnabled => _socket.writeEventsEnabled;
  set writeEventsEnabled(bool value) {
    _socket.writeEventsEnabled = value;
  }

  String get localAddress => _socket.address.address;

  int get localPort => _socket.port;

  io.Datagram _currentDatagram;
  io.Datagram receive() {
    final dg = _socket.receive();
    _currentDatagram = dg == null ? _currentDatagram : dg;
    return _currentDatagram;
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
class _DatagramSocketWriter extends EventSink<List<int>> {
  final _BroadcastDatagramSocket _socket;
  final io.InternetAddress address;
  final int port;

  _DatagramSocketWriter(this._socket, this.address, this.port);

  @override
  void add(List<int> event) {
    _socket.send(event, address, port);
  }

  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
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
class _DatagramSocketReader {
  final _BroadcastDatagramSocket _socket;
  final _output = new StreamController<List<int>>();

  /// Whether this reader should close [_socket] when a CLOSED event is
  /// received.  Set this to false to prevent many readers from attempting to
  /// close the same socket.
  final bool closeOnClosed;

  _DatagramSocketReader(this._socket, {this.closeOnClosed = true}) {
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
