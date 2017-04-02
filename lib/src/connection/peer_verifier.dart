import 'dart:async';

import 'package:async/async.dart';
import 'package:distributed/src/connection/socket.dart';
import 'package:distributed.objects/public.dart';
import 'package:meta/meta.dart';

/// The amount of time to wait for a socket message before timing out.
@visibleForTesting
const timeoutDuration = const Duration(seconds: 2);

@visibleForTesting
Message createIdMessage(Peer sender) => new Message('id', '', sender);

/// Verifies socket connections on behalf of some specified [Peer].
class PeerVerifier {
  final Peer _localPeer;

  PeerVerifier(this._localPeer);

  /// See [verifyRemotePeer].
  Future<VerificationResult> verifyOutgoing(Socket socket) =>
      verifyRemotePeer(socket, _localPeer, incoming: false);

  /// See [verifyRemotePeer].
  Future<VerificationResult> verifyIncoming(Socket socket) =>
      verifyRemotePeer(socket, _localPeer, incoming: true);
}

/// Error messages for explaining socket verification failures.
abstract class VerificationError {
  static const TIMEOUT = 'Response timed out';
  static const INVALID_RESPONSE = 'Received invalid response from remote';
  static const CONNECTION_CLOSED = 'Socket is not open';
}

/// The result returned from the verifyX methods in this library.
class VerificationResult {
  /// The reason verification failed, or the empty string.
  final String error;

  /// The verified peer.
  final Peer peer;

  VerificationResult._(this.error, this.peer);

  VerificationResult._error(this.error) : this.peer = Peer.Null;
}

/// Verifies the remote [Peer] on the other end of [socket].
///
/// Returns a [VerificationResult] containing the remote [Peer] on [socket]. If
/// verification fails, the returned result will contain `Peer.Null` and an
/// error message describing the failure.
Future<VerificationResult> verifyRemotePeer(Socket socket, Peer localPeer,
        {bool incoming: false}) =>
    incoming
        ? _verifyIncomingConnection(socket, localPeer)
        : _verifyOutgoingConnection(socket, localPeer);

/// Authenticates an incoming connection over [socket] received by [receiver].
///
/// See [verifyRemotePeer] for details on the return value.
Future<VerificationResult> _verifyIncomingConnection(
    Socket socket, Peer receiver) async {
  var result = await _waitForPeerIdentification(socket);
  if (result.error != null) {
    if (result.error is TimeoutException) {
      return new VerificationResult._error(VerificationError.TIMEOUT);
    } else if (result.error is StateError) {
      return new VerificationResult._error(VerificationError.CONNECTION_CLOSED);
    } else if (result.error is FormatException ||
        result.error is ArgumentError) {
      return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
    }
  }

  var idMessage = result.message;
  if (idMessage == Message.Null) {
    return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
  }

  var sender = idMessage.sender;
  assert(sender != null);
  if (sender == Peer.Null) {
    return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
  } else {
    // Use the socket's external ip instead of the original, internal ip sent by
    // the peer.
    var correctedSender = new Peer(
        sender.name,
        // TODO: use socket.remoteHost.
        new HostMachine(
            sender.hostMachine.address, sender.hostMachine.portDaemonPort));
    socket.add(Message.serialize(createIdMessage(receiver)));
    return new VerificationResult._('', correctedSender);
  }
}

/// Authenticates an outgoing connection over [socket] sent by [sender].
///
/// See [verifyRemotePeer] for details on the return value.
Future<VerificationResult> _verifyOutgoingConnection(
    Socket socket, Peer sender) async {
  try {
    socket.add(Message.serialize(createIdMessage(sender)));
  } on StateError catch (_) {
    return new VerificationResult._error(VerificationError.CONNECTION_CLOSED);
  }

  var result = await _waitForPeerIdentification(socket);
  if (result.error != null) {
    if (result.error is TimeoutException) {
      return new VerificationResult._error(VerificationError.TIMEOUT);
    } else if (result.error is StateError) {
      return new VerificationResult._error(VerificationError.CONNECTION_CLOSED);
    } else if (result.error is FormatException ||
        result.error is ArgumentError) {
      return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
    }
  }

  var response = result.message;
  if (response != Message.Null &&
      response.sender != Peer.Null &&
      response.category == 'id' &&
      response.contents == '') {
    return new VerificationResult._('', response.sender);
  } else {
    return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
  }
}

/// Waits for the remote's id as the next message sent on [socket].
///
/// If an error occurs, returned [_IdResult] will contain the error and
/// `Peer.Null`.  Otherwise the result will contain the remote [Peer] and no
/// error.
Future<_IdResult> _waitForPeerIdentification(Socket socket) async {
  var resultCompleter = new Completer<_IdResult>();
  Timer timeout;
  CancelableOperation<String> responseFuture;

  // Zone to handle the timeout exception.  The exception is thrown in an async
  // closure and can't be handled in the next zone, below.
  runZoned(() {
    timeout = new Timer(timeoutDuration, () {
      throw new TimeoutException(VerificationError.TIMEOUT);
    });
  }, onError: (e, s) {
    responseFuture.cancel();
    resultCompleter.complete(new _IdResult._error(e));
  });

  // Zone to handle invalid data, closed socket, etc.
  runZoned(() async {
    responseFuture = new CancelableOperation.fromFuture(socket.take(1).first);
    var response = await responseFuture
        .valueOrCancellation(Message.serialize(Message.Null));
    timeout.cancel();
    // resultCompleter might have already completed with a timeout error.
    if (resultCompleter.isCompleted) return;
    var message = Message.deserialize(response);
    resultCompleter.complete(new _IdResult(null, message));
  }, onError: (e, s) {
    timeout.cancel();
    resultCompleter.complete(new _IdResult._error(e));
  });

  return resultCompleter.future;
}

class _IdResult {
  final Object error;
  final Message message;

  _IdResult(this.error, this.message);
  factory _IdResult._error(error) {
    assert(error is Exception || error is Error, 'Invalid error type: $error');
    return new _IdResult(error, Message.Null);
  }
}
