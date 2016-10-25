import 'dart:async';
import 'dart:io' as io;
import 'package:distributed/interfaces/connection.dart';
import 'package:distributed/src/io/data_channel.dart';
import 'package:distributed/src/networking/platform_data_channel.dart';
import 'package:mockito/mockito.dart';
import 'package:seltzer/seltzer.dart';
import 'package:seltzer/src/interface.dart';
import 'package:test/test.dart';

void main() {
  final List<String> streamEvents = ['A', 'B', 'C'];

  group('$PlatformDataChannel', () {
    MockSeltzerWebSocket mockWebSocket;
    PlatformDataChannel dataChannel;

    setUp(() {
      mockWebSocket = new MockSeltzerWebSocket();
      when(mockWebSocket.onMessage).thenReturn(new Stream.fromIterable(
          streamEvents.map((e) => new MockSeltzerMessage(e))));
      dataChannel = new PlatformDataChannel(mockWebSocket);
    });

    group('onData', () {
      test('should emit when data is recieved', () async {
        expect(dataChannel.onData.toList(), completion(streamEvents));
      });

      test('should throw if the channel is closed', () async {
        await testOnDataThrowsIfClosed(dataChannel);
      });
    });

    test('send should send data', () async {
      dataChannel.send('A');
      verify(mockWebSocket.sendString('A')).called(1);
    });

    test('close should close the channel', () async {
      dataChannel.close();
      await dataChannel.onClose;
      expect(() => dataChannel.send('A'), throwsStateError);
    });

    test('should close if the underlying connection closes', () async {
      await mockWebSocket.close();
      await dataChannel.onClose;
      expect(() => dataChannel.send('A'), throwsStateError);
    });
  });

  group('$IODataChannel', () {
    IODataChannel<String> dataChannel;
    MockWebSocket mockWebSocket;

    setUp(() {
      mockWebSocket = new MockWebSocket();
      dataChannel = new IODataChannel<String>(mockWebSocket);
    });

    group('onData', () {
      test('should emit when data is recieved', () async {
        // Here to avoid strong mode warnings in expectAsync.
        // ignore: strong_mode_down_cast_composite
        dataChannel.onData.listen(expectAsync((data) {
          expect(streamEvents.removeAt(0), data);
        }, count: streamEvents.length));
        streamEvents.forEach(mockWebSocket.add);
      });

      test('should throw if the channel is closed', () async {
        await testOnDataThrowsIfClosed(dataChannel);
      });
    });

    test('send should send data', () async {
      // ignore: strong_mode_down_cast_composite
      dataChannel.onData.listen(expectAsync((data) {
        expect(data, 'A');
      }, count: 1));
      dataChannel.send('A');
    });

    test('close should close the channel', () async {
      dataChannel.close();
      await expectChannelIsClosed(dataChannel);
    });

    test('should close if the underlying connection closes', () async {
      await mockWebSocket.close();
      await dataChannel.onClose;
      expect(() => dataChannel.send('A'), throwsStateError);
    });
  });
}

Future testOnDataThrowsIfClosed(DataChannel dataChannel) async {
  dataChannel.close();
  expectChannelIsClosed(dataChannel);
}

Future expectChannelIsClosed(DataChannel dataChannel) async {
  try {
    dataChannel.close();
    fail('DataChannel was not closed.');
  } catch (e) {
    expect(e, isStateError);
  }
}

class MockWebSocket extends Mock implements io.WebSocket {
  final Completer<Null> _onCloseCompleter = new Completer<Null>();
  Function listener;

  @override
  void add(data) {
    if (listener != null) {
      listener(data);
    }
  }

  @override
  StreamSubscription listen(void onData(dynamic),
      {Function onError, void onDone(), bool cancelOnError}) {
    listener = onData;
    return new MockStreamSubscription();
  }

  @override
  Future<Null> get done => _onCloseCompleter.future;

  @override
  Future<Null> close([int code, String reason]) async {
    _onCloseCompleter.complete();
  }
}

class MockStreamSubscription extends Mock implements StreamSubscription {}

class MockSeltzerWebSocket extends Mock implements SeltzerWebSocket {
  final Completer<Null> onCloseCompleter = new Completer<Null>();

  @override
  Future<Null> close({int code, String reason}) async {
    onCloseCompleter.complete();
  }

  @override
  Future<Null> get onClose => onCloseCompleter.future;
}

class MockSeltzerMessage extends Mock implements SeltzerMessage {
  final String _value;

  MockSeltzerMessage(this._value);

  @override
  Future<String> readAsString() => new Future.value(_value);
}
