import 'dart:async';

import 'package:async/async.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:meta/meta.dart';

/// The amount of time to wait for a socket message before timing out.
@visibleForTesting
const timeoutDuration = const Duration(seconds: 2);

@visibleForTesting
Message createIdMessage(Peer sender) => new Message('id', '', sender);

/// Verifies socket connections on behalf of some specified [Peer].
class PeerVerifier {
  final Peer _localPeer;
  final Logger _logger;

  PeerVerifier(this._localPeer, this._logger);

  /// See [verifyRemotePeer]
  Future<VerificationResult> verifyOutgoing(Socket socket) =>
      verifyRemotePeer(socket, _localPeer, _logger, incoming: false);

  /// See [verifyRemotePeer]
  Future<VerificationResult> verifyIncoming(Socket socket) =>
      verifyRemotePeer(socket, _localPeer, _logger, incoming: true);
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
Future<VerificationResult> verifyRemotePeer(
        Socket socket, Peer localPeer, Logger logger, {bool incoming: false}) =>
    incoming
        ? _verifyIncomingConnection(socket, localPeer, logger)
        : _verifyOutgoingConnection(socket, localPeer, logger);

/// Authenticates an incoming connection over [socket] received by [receiver].
///
/// See [verifyRemotePeer] for details on the return value.
Future<VerificationResult> _verifyIncomingConnection(
    Socket socket, Peer receiver, logger) async {
  logger.pushPrefix('verify-incoming');
  logger.log('waiting for verification');
  var result = await _waitForPeerIdentification(socket);
  logger.log('${receiver.name} received verification $result');
  if (result.error != null) {
    if (result.error is TimeoutException) {
      logger.popPrefix();
      return new VerificationResult._error(VerificationError.TIMEOUT);
    } else if (result.error is StateError) {
      logger.popPrefix();
      return new VerificationResult._error(VerificationError.CONNECTION_CLOSED);
    } else if (result.error is FormatException ||
        result.error is ArgumentError) {
      logger.popPrefix();
      return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
    }
  }

  var idMessage = result.message;
  if (idMessage == Message.Null) {
    logger.popPrefix();
    return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
  }

  var sender = idMessage.sender;
  assert(sender != null);
  if (sender == Peer.Null) {
    logger.popPrefix();
    return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
  } else {
    socket.add(serialize(createIdMessage(receiver)));
    logger.popPrefix();
    return new VerificationResult._('', sender);
  }
}

/// Authenticates an outgoing connection over [socket] sent by [sender].
///
/// See [verifyRemotePeer] for details on the return value.
Future<VerificationResult> _verifyOutgoingConnection(
    Socket socket, Peer sender, Logger logger) async {
  logger.pushPrefix('verify-outgoing');

  try {
    socket.add(serialize(createIdMessage(sender)));
  } on StateError catch (e, s) {
    logger..error(e.toString())..error(s.toString());
    return new VerificationResult._error(VerificationError.CONNECTION_CLOSED);
  }

  logger.log('${sender.name} sent verification');
  var result = await _waitForPeerIdentification(socket);
  logger.log('${sender.name} received verification $result');

  if (result.error != null) {
    if (result.error is TimeoutException) {
      logger.popPrefix();
      return new VerificationResult._error(VerificationError.TIMEOUT);
    } else if (result.error is StateError) {
      logger.popPrefix();
      return new VerificationResult._error(VerificationError.CONNECTION_CLOSED);
    } else if (result.error is FormatException ||
        result.error is ArgumentError) {
      logger.popPrefix();
      return new VerificationResult._error(VerificationError.INVALID_RESPONSE);
    }
  }

  var response = result.message;
  if (response != Message.Null &&
      response.sender != Peer.Null &&
      response.category == 'id' &&
      response.contents == '') {
    logger.popPrefix();
    return new VerificationResult._('', response.sender);
  } else {
    logger.popPrefix();
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
    print(e);
    print(s);
    responseFuture.cancel();
    resultCompleter.complete(new _IdResult._error(e));
  });

  // Zone to handle invalid data, closed socket, etc.
  runZoned(() async {
    responseFuture = new CancelableOperation.fromFuture(socket.first);
    var response =
        await responseFuture.valueOrCancellation(serialize(Message.Null));
    timeout.cancel();
    // resultCompleter might have already completed with a timeout error.
    if (resultCompleter.isCompleted) return;
    var message = Message.deserialize(response);
    resultCompleter.complete(new _IdResult(null, message));
  }, onError: (e, s) {
    print(e);
    print(s);
    timeout.cancel();
    if (resultCompleter.isCompleted) return;
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

  @override
  String toString() => '_IdResult($message, $error)';
}
