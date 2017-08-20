import 'dart:async';
import 'dart:collection';

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/message_buffer.dart';
import 'package:distributed.ipc/src/protocol/lazy_message_converter.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/protocol/socket_state.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

/// A [RawUdpSocket] that sends messages using a lock-step algorithm.
///
/// Messages sent on the socket are split into chunks called [Packet]s.  Each
/// packet is sent one at a time, and the next packet is not sent until the
/// remote peer responds with acknowledgement of the previous packet.  If a
/// packet is dropped, the remote times out and responds with a resend request.
/// Delivery is guaranteed in this way.
///
/// If a message is added to the socket while a previous message is still being
/// sent, the new message is added to a queue and sent when all previously
/// enqueued messages have been sent.
///
/// If a connection is dropped in the middle of sending a message, that message
/// and all other messages queued for sending to that remote peer are dropped
/// from the socket.
class VmLockStepSocket extends StreamView<String> implements UdpSocket {
  static const _codec = const PacketCodec();

  final Socket<Packet> _socket;
  final StreamController<String> _output;
  final MessageBuffer _buffer = new MessageBuffer();
  final Queue<String> _messageQueue = new Queue<String>();

  LazyMessageConverter _messageConverter;
  SocketState _state = SocketState.idle;
  Packet _mostRecentPacket;

  factory VmLockStepSocket.wrap(RawUdpSocket socket) {
    final packetSocket = Socket.convert<List<int>, Packet>(socket, _codec);
    return new VmLockStepSocket._(
      packetSocket,
      new StreamController<String>(sync: true),
    );
  }

  VmLockStepSocket._(this._socket, this._output) : super(_output.stream) {
    _socket.forEach(_handlePacket);
  }

  /// Sends [message] to the remote socket.
  @override
  void add(String message) {
    _assertNotState([SocketState.closed]);
    _messageQueue.add(message);

    if (_state != SocketState.sending) {
      _sendNextMessage();
    }
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    // Assume errorEvent is small enough to fit in single datagram.
    _assertNotState([SocketState.closed]);
    _socket.addError(error, stackTrace);
  }

  @override
  void close() {
    _assertNotState([SocketState.closed]);
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
    _assertState([SocketState.receiving, SocketState.idle]);
    _buffer.add(packet);
    _send(const ACKPacket());
  }

  void _handleEND(ENDPacket packet) {
    _assertState([SocketState.receiving, SocketState.idle]);
    _output.add(_buffer.toString());
    _send(const ACKPacket());
    _buffer.clear();
  }

  void _handleACK(ACKPacket packet) {
    _assertState([SocketState.sending, SocketState.pending]);

    if (_messageConverter.moveNext()) {
      _send(_messageConverter.current);
    } else if (_state == SocketState.sending) {
      _send(const ENDPacket());
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
    _assertState([SocketState.sending, SocketState.pending]);
    _send(_mostRecentPacket);
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
  void _assertNotState(List<SocketState> expectation) {
    if (expectation.contains(_state)) {
      _socket.addError(new StateError('' /* FIXME */));
    }
  }

  /// Begins transferring the next message in [_messageQueue].
  void _sendNextMessage() {
    _messageConverter = new LazyMessageConverter(_messageQueue.removeFirst())
      ..moveNext();
    _send(_messageConverter.current);
    _state = SocketState.sending;
  }

  void _send(Packet packet) {
    _socket.add(packet);
    _mostRecentPacket = packet;
  }
}
