import 'dart:async';

import 'package:async/async.dart';
import 'package:distributed.connection/src/message_router.dart';
import 'package:distributed.monitoring/periodic_function.dart';
import 'package:distributed.monitoring/resource.dart';
import 'package:distributed.objects/objects.dart';

/// A channel for passing [BuiltMessage]s.
///
/// Unlike most dart sinks, if the remote end of the connection is closed, this
/// connection will also close, regardless of whether any data has been sent or
/// received.
class Connection implements Sink<BuiltMessage> {
  final MessageRouter _messageRouter;
  final _closeMemo = new AsyncMemoizer();
  final _doneCompleter = new Completer();

  PeriodicFunction _keepAliveSignal;
  ResourceMonitor<String> _connectionMonitor;

  Connection(this._messageRouter) {
    _keepAliveSignal = new PeriodicFunction(_pingRemote);
    _connectionMonitor = new ResourceMonitor('', _messageRouter.systemStream);
    _connectionMonitor.onGone.then((_) {
      close();
    });
  }

  /// Sends [message] over this connection.
  @override
  void add(BuiltMessage message) {
    _messageRouter.sendToUser(serialize(message));
  }

  /// The [Stream] of messages sent to this connection.
  Stream<BuiltMessage> get messages => _messageRouter.userStream
      .map((String m) => deserialize(m, BuiltMessage) as BuiltMessage)
      .asBroadcastStream();

  /// A future that completes when this connection is closed.
  ///
  /// If the remote closes the connection, this is guaranteed to complete.
  Future get done => _doneCompleter.future;

  @override
  void close() {
    _closeMemo.runOnce(() {
      _keepAliveSignal.stop();
      _connectionMonitor.stop();
      _messageRouter.close();
      _doneCompleter.complete();
    });
  }

  void _pingRemote() {
    _messageRouter.sendToSystem('');
  }
}
