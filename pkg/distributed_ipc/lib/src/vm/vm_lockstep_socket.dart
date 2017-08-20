import 'dart:async';
import 'dart:collection';

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/message_buffer.dart';
import 'package:distributed.ipc/src/protocol/lazy_message_converter.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/protocol/socket_state.dart';
import 'package:distributed.ipc/src/utf8.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

/// A [VmDatagramSocket] that sends message using the lock-step algorithm.
///
/// Each packet of a message is sent one at a time, and the next packet is not
/// sent until the remote responds with acknowledgement of the previous packet.
/// If a packet is dropped, the remote responds with a resend request to
/// guarantee delivery.
///
/// If a message is added to the socket while a previous message is still being
/// sent, the new message is added to a queue and sent when all previously
/// enqueued messages have been sent.
class VmLockStepSocket extends StreamView<String> implements VmDatagramSocket {
  static const _codec = const PacketCodec();

  final Socket<Packet> _socket;
  final StreamController<String> _output;
  final MessageBuffer _buffer = new MessageBuffer();
  final Queue<String> _messageQueue = new Queue<String>();

  LazyMessageConverter _messageConverter;
  SocketState _state = SocketState.idle;

  factory VmLockStepSocket.wrap(DatagramSocket socket) {
    final packetSocket = Socket.convert<List<int>, Packet>(socket, _codec);
    return new VmLockStepSocket._(
      packetSocket,
      new StreamController<String>(sync: true),
    );
  }

  VmLockStepSocket._(
    this._socket,
    StreamController<String> receiverController,
  )
      : _output = receiverController,
        super(receiverController.stream) {
    _socket.forEach(_handlePacket);
  }

  /// Sends [message] to the remote socket.
  @override
  void add(String message) {
    _assertNotState(SocketState.closed);
    _messageQueue.add(message);

    if (_state != SocketState.sending) {
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
    _output.close();
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
      case PacketType.ACK:
        _handleACK(packet);
        break;
      case PacketType.DIS:
        _handleDROP(packet);
        break;
    }
  }

  void _handleMSG(MSGPacket packet) {
    _assertState([
      SocketState.receiving,
      SocketState.idle,
    ]);

    _buffer.add(packet);
    _socket.add(const ACKPacket());
  }

  void _handleEND(ENDPacket packet) {
    _assertState([
      SocketState.receiving,
      SocketState.idle,
    ]);

    _output.add(_buffer.toString());
    _socket.add(const ACKPacket());
    _buffer.clear();
  }

  void _handleACK(ACKPacket packet) {
    _assertState([SocketState.sending, SocketState.pending]);

    if (_messageConverter.moveNext()) {
      _socket.add(_messageConverter.current);
    } else if (_state == SocketState.sending) {
      _socket.add(const ENDPacket());
      _state = SocketState.pending;
    } else if (_state == SocketState.pending) {
      if (_messageQueue.isNotEmpty) {
        _sendNextMessage();
      } else {
        _state = SocketState.idle;
      }
    }
  }

  void _handleRES(RESPacket packet) {
    _assertState([SocketState.sending]);
    _socket.add(_messageConverter.current);
  }

  void _handleDROP(DROPPacket packet) {
    close();
  }

  /// Asserts that [_state] is contained in [expectation].
  void _assertState(List<SocketState> expectation) {
    if (!expectation.contains(_state)) {
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
    _state = SocketState.sending;
  }

  void _debug(String msg) {
    print('$hashCode: $msg');
  }
}
