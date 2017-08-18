import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/protocol/lazy_packet_stream.dart';
import 'package:distributed.ipc/src/protocol/message_receiver.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/protocol/socket_state.dart';
import 'package:distributed.ipc/src/socket.dart';

/// A [Socket] implementation backed by an [io.Socket].
class VmSocket extends GenericSocket<String> {
  static Future<VmSocket> connect(io.InternetAddress address, int port) async =>
      new VmSocket(await io.Socket.connect(address, port));

  VmSocket(io.Socket socket)
      : super(
            socket.map<String>(const Utf8Decoder().convert),
            new EncodedSocketSink<List<int>, String>(
                socket, const Utf8Encoder()));
}

/// A [Socket] implementation that communicates via datagrams.
abstract class VmDatagramSocket implements Socket<String> {
  static const _codec = const PacketCodec();

  /// Creates a new [VmDatagramSocket] from [config].
  static Future<VmDatagramSocket> connect(DatagramSocketConfig config) async {
    final rawSocket = await DatagramSocket.connect(config.address, config.port);
    final socket = Socket.convert<List<int>, Packet>(rawSocket, _codec);

    switch (config.transferMode) {
      case TransferMode.lockstep:
        return new LockStepDatagramSocket(socket);
      case TransferMode.fast:
        throw new UnimplementedError();
      default:
        throw new UnsupportedError('${config.transferMode}');
    }
  }
}

/// An [VmDatagramSocket] that sends message using the lock-step algorithm.
///
/// Each packet of a message is sent one at a time, and the next packet is not
/// sent until the remote responds with acknowledgement of the previous packet.
/// If a packet is dropped, the remote responds with a resend request to
/// guarantee delivery.
///
/// If a message is added to the socket while a previous message is still being
/// sent, the new message is added to a queue and sent when all previously
/// enqueued messages have been sent.
class LockStepDatagramSocket extends StreamView<String>
    implements VmDatagramSocket {
  final Socket<Packet> _socket;
  final StreamController<String> _receiverController;
  final LockStepReceiver _receiver = new LockStepReceiver();
  final Queue<String> _messageQueue = new Queue<String>();

  LazyMessageConverter _messageConverter;
  SocketState _state = SocketState.awaitingConn;

  factory LockStepDatagramSocket(Socket<Packet> socket) {
    return new LockStepDatagramSocket._(
      socket,
      new StreamController<String>(sync: true),
    );
  }

  LockStepDatagramSocket._(
    this._socket,
    StreamController<String> receiverController,
  )
      : _receiverController = receiverController,
        super(receiverController.stream) {
    _socket.forEach(_handlePacket);
  }

  /// Sends [message] to the remote socket.
  @override
  void add(String message) {
    _assertNotState(SocketState.closed);
    _messageQueue.add(message);

    if (_state != SocketState.awaitingAck && _state != SocketState.sending) {
      _sendNextMessage();
    }
  }

  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
    // Assume errorEvent is small enough to fit in single datagram.
    _assertNotState(SocketState.closed);
    _socket.addError(errorEvent, stackTrace);
  }

  @override
  void close() {
    _assertNotState(SocketState.closed);
    _socket.close();
    _receiverController.close();
    _messageQueue.clear();
    _messageConverter = null;
    _state = SocketState.closed;
  }

  void _handlePacket(Packet packet) {
    switch (packet.type) {
      case PacketType.MSG:
        _handleMSG(packet);
        break;
      case PacketType.END:
        _handleEND(packet);
        break;
      case PacketType.RES:
        _handleRES(packet);
        break;
      case PacketType.CONN:
        _handleCONN(packet);
        break;
      case PacketType.ACK:
        _handleACK(packet);
        break;
      case PacketType.DROP:
        _handleDROP(packet);
        break;
    }
  }

  void _handleMSG(MSGPacket packet) {
    _handleDataPacket(packet);
  }

  void _handleEND(ENDPacket packet) {
    _handleDataPacket(packet);
  }

  void _handleDataPacket(Packet packet) {
    _assertState([
      SocketState.receiving,
      SocketState.idle,
    ]);

    assert(packet is MSGPacket || packet is ENDPacket);

    final response = _receiver.receive(packet);
    if (response != null) {
      _socket.add(response);
    }

    if (_receiver.isDone) {
      _receiverController.add(_receiver.emit());
    }
  }

  void _handleACK(ACKPacket packet) {
    _assertState(SocketState.awaitingAck);

    if (_messageConverter.moveNext()) {
      _socket.add(const ENDPacket());
      if (_messageQueue.isEmpty) {
        _state = SocketState.idle;
      } else {
        _sendNextMessage();
      }
    } else {
      _socket.add(_messageConverter.current);
    }
  }

  void _handleRES(RESPacket packet) {
    _socket.add(_messageConverter.current);
  }

  void _handleCONN(CONNPacket packet) {
    _assertState(SocketState.awaitingConn);
  }

  void _handleDROP(DROPPacket packet) {
    close();
  }

  /// Asserts that [_state] is either contained in [expectation] if it is an
  /// [Iterable] or that [_state] equals [expectation] if it is a [SocketState].
  void _assertState(expectation) {
    if (expectation is Iterable && !expectation.contains(_state) ||
        expectation != _state) {
      _socket.addError(new StateError('' /* FIXME */));
    }
  }

  /// Asserts that [_state] is not contained in [expectation] if it is an
  /// [Iterable] or that [_state] is not [expectation] if it is a [SocketState].
  void _assertNotState(expectation) {
    if (expectation is Iterable && expectation.contains(_state) ||
        expectation == _state) {
      _socket.addError(new StateError('' /* FIXME */));
    }
  }

  /// Begins transferring the next message in [_messageQueue].
  void _sendNextMessage() {
    _messageConverter = new LazyMessageConverter(_messageQueue.removeFirst())
      ..moveNext();
    _socket.add(_messageConverter.current);
    _state = SocketState.awaitingAck;
  }
}

/// A [Socket] implementation that communicates using datagrams.
class DatagramSocket extends GenericSocket<List<int>> {
  static Future<DatagramSocket> connect(
    io.InternetAddress address,
    int port,
  ) async {
    final udpSocket = await io.RawDatagramSocket.bind(
      io.InternetAddress.ANY_IP_V4,
      0,
    );
    return new DatagramSocket(
      new _DatagramSocketReader(udpSocket),
      new _DatagramSocketWriter(udpSocket, address, port),
    );
  }

  DatagramSocket(_DatagramSocketReader reader, _DatagramSocketWriter writer)
      : super(reader.stream, writer);
}

/// An [EventSink] that writes data to a [RawDatagramSocket].
///
/// The writer can only write to a single address and port.
class _DatagramSocketWriter extends EventSink<List<int>> {
  final io.RawDatagramSocket _socket;
  final io.InternetAddress _address;
  final int _port;

  _DatagramSocketWriter(this._socket, this._address, this._port);

  @override
  void add(List<int> event) {
    _socket.send(event, _address, _port);
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
  final io.RawDatagramSocket _socket;
  final _streamController = new StreamController<List<int>>();

  _DatagramSocketReader(this._socket) {
    _socket
      ..writeEventsEnabled = false
      ..forEach(_handleEvent);
  }

  Stream<List<int>> get stream => _streamController.stream;

  void _handleEvent(io.RawSocketEvent event) {
    switch (event) {
      case io.RawSocketEvent.CLOSED:
        _socket.close();
        break;
      case io.RawSocketEvent.READ:
        final datagram = _socket.receive();
        _streamController.add(datagram.data);
        break;
      default:
        throw new UnsupportedError('$event');
    }
    // RawSocketEvent.READ_CLOSED will never be received; The remote peer cannot
    // close the socket.
  }
}
