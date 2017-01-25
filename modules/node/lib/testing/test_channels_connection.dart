import 'dart:async';
import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:stream_channel/stream_channel.dart';
import 'test_socket_connection.dart';

class TestConnectionChannelsProvider
    implements ConnectionChannelsProvider<String> {
  final ConnectionChannels<String> local;
  final ConnectionChannels<String> foreign;

  factory TestConnectionChannelsProvider() {
    var userConnection = new TestSocketConnection();
    var systemConnection = new TestSocketConnection();
    var errorConnection = new TestSocketConnection();
    var local = new _TestConnectionChannels(
      new StreamChannel<String>(userConnection.local, userConnection.local),
      new StreamChannel<String>(systemConnection.local, systemConnection.local),
      new StreamChannel<String>(errorConnection.local, errorConnection.local),
    );
    var foreign = new _TestConnectionChannels(
      new StreamChannel<String>(userConnection.foreign, userConnection.foreign),
      new StreamChannel<String>(
          systemConnection.foreign, systemConnection.foreign),
      new StreamChannel<String>(
          errorConnection.foreign, errorConnection.foreign),
    );
    return new TestConnectionChannelsProvider._(local, foreign);
  }

  TestConnectionChannelsProvider._(this.local, this.foreign);

  @override
  Future<ConnectionChannels<String>> createFromUrl(String _) =>
      new Future.value(foreign);
}

class _TestConnectionChannels implements ConnectionChannels<String> {
  final StreamChannel<String> user;
  final StreamChannel<String> system;
  final StreamChannel<String> error;
  final Completer _doneCompleter = new Completer();

  _TestConnectionChannels(this.user, this.system, this.error) {
    bool isOpen = true;

    void closeOnDone(StreamSink sink) {
      sink.done.then((_) {
        if (isOpen) {
          isOpen = false;
          close();
        }
      });
    }

    [user.sink, system.sink, error.sink].forEach(closeOnDone);
  }

  @override
  Future close() => Future.wait([
        user.sink.close(),
        system.sink.close(),
        error.sink.close(),
      ]).then((_) {
        _doneCompleter.complete();
      });

  @override
  Future get done => _doneCompleter.future;
}
