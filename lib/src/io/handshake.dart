import 'dart:async';
import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/message_channel.dart';
import 'package:distributed/src/networking/handshake_action.dart' as handshake;
import 'package:distributed/src/networking/system_payloads.dart';

enum _State {
  finished,
  awaitConnection,
  awaitConnectionConfirmation,
  awaitPeerExchange1,
  awaitPeerExchange2,
}

class HandshakeResult {
  final bool isError;
  final Peer remote;
  final MessageChannel channel;

  HandshakeResult(this.remote, this.channel) : isError = false;
  HandshakeResult.error(this.remote, this.channel) : isError = true;
}

class Handshake {
  final Completer<HandshakeResult> _onFinished =
      new Completer<HandshakeResult>();
  final MessageChannel _channel;
  final Node _sender;
  _State _state;
  StreamSubscription<Message> _messageSubscription;

  Handshake(this._sender, this._channel, {bool initiate: false}) {
    _state = _State.awaitConnection;
    if (initiate) {
      _channel.send(new Message(_sender, handshake.requestConnection,
          new ConnectionRequest(_sender.cookie).toJsonString()));
      _state = _State.awaitConnectionConfirmation;
    }

    _messageSubscription =
        _channel.onMessage.listen(_handleMessage, onDone: () {
      _messageSubscription.cancel();
    }, cancelOnError: true);
  }

  Future<HandshakeResult> get finished => _onFinished.future;

  void _fail(Peer peer) {
    _channel.send(new Message(_sender, handshake.failed, ''));
    _messageSubscription.cancel();
    _onFinished.complete(new HandshakeResult.error(peer, _channel));
  }

  void _handleMessage(Message message) {
    _State nextState;
    var action = message.action;

    if (action == handshake.failed) {
      _fail(message.sender);
      return;
    }

    switch (_state) {
      case _State.awaitConnection:
        if (action != handshake.requestConnection) {
          _fail(message.sender);
          break;
        }

        var request = ConnectionRequest.fromJsonString(message.data);
        if (request.cookie != _sender.cookie) {
          _fail(message.sender);
          break;
        }
        _channel.send(new Message(_sender, handshake.acceptConnection,
            new ConnectionRequest(_sender.cookie).toJsonString()));
        nextState = _State.awaitPeerExchange1;
        break;
      case _State.awaitConnectionConfirmation:
        if (action != handshake.acceptConnection) {
          _fail(message.sender);
          break;
        }

        var request = ConnectionRequest.fromJsonString(message.data);
        if (request.cookie != _sender.cookie) {
          _fail(message.sender);
          break;
        }

        Iterable<Peer> sharedPeers = <Peer>[];
        if (!_sender.isHidden) {
          sharedPeers = _sender.peers.where((Peer peer) => !peer.isHidden);
        }
        _channel.send(new Message(_sender, handshake.peerExchange1,
            new NetworkInfo(sharedPeers).toJsonString()));
        nextState = _State.awaitPeerExchange2;
        break;
      case _State.awaitPeerExchange1:
        if (action != handshake.peerExchange1) {
          _fail(message.sender);
          break;
        }

        Iterable<Peer> sharedPeers = <Peer>[];
        var info = NetworkInfo.fromJsonString(message.data);
        if (!_sender.isHidden) {
          info.connectedPeers
              .where((p) => !_sender.peers.contains(p))
              .forEach(_sender.connect);
          sharedPeers = _sender.peers.where((Peer peer) => !peer.isHidden);
        }
        _channel.send(new Message(_sender, handshake.peerExchange2,
            new NetworkInfo(sharedPeers).toJsonString()));
        nextState = _State.finished;
        break;
      case _State.awaitPeerExchange2:
        if (action != handshake.peerExchange2) {
          _fail(message.sender);
          break;
        }

        var info = NetworkInfo.fromJsonString(message.data);
        if (!_sender.isHidden) {
          info.connectedPeers
              .where((p) => !_sender.peers.contains(p))
              .forEach(_sender.connect);
        }
        nextState = _State.finished;
        break;
      case _State.finished:
        // Should never hit this, but `switch` requires a case for all enum
        // values.
        throw new StateError('Handshake ended');
    }

    assert(_state != nextState);
    if (nextState == _State.finished) {
      _messageSubscription.cancel();
      _onFinished.complete(new HandshakeResult(message.sender, _channel));
    } else {
      _state = nextState;
    }
  }
}
