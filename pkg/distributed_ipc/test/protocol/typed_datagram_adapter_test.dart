import 'dart:async';

import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram_adapter.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram_codec.dart';
import 'package:distributed.ipc/src/testing/test_udp_sink.dart';
import 'package:test/test.dart';

void main() {
  group(TypedDatagramAdapter, () {
    TestSink<List<int>> testUdpSink;
    Stream<List<int>> eventStream;
    const testAddress = '127.0.0.1';
    const testPort = 9090;

    List<TypedDatagram> recordedGreetDatagrams;
    List<TypedDatagram> recordedDatagrams;

    void commonSetUp([List<TypedDatagram> incomingDatagrams = const []]) {
      recordedGreetDatagrams = <TypedDatagram>[];
      recordedDatagrams = <TypedDatagram>[];

      testUdpSink = new TestSink<List<int>>();
      eventStream = new Stream<List<int>>.fromIterable(
              incomingDatagrams.map(const TypedDatagramCodec().encode))
          .asBroadcastStream();
      new TypedDatagramAdapter(
        testUdpSink,
        eventStream,
        onDatagram: recordedDatagrams.add,
        onGreet: recordedGreetDatagrams.add,
      );
    }

    test('should call the correct callback for the given datagram type', () {
      final greetDatagram = new TypedDatagram(
        [1, 2, 3],
        testAddress,
        testPort,
        DatagramType.GREET,
      );
      final datagram = new TypedDatagram(
        [1, 2, 3],
        testAddress,
        testPort,
        DatagramType.DEFAULT,
      );

      commonSetUp([greetDatagram, datagram]);

      eventStream.last.then(expectAsync1((_) {
        expect(recordedGreetDatagrams, [greetDatagram]);
        expect(recordedDatagrams, [datagram]);
      }));
    });

    test('should not call any callback if a datagram has an uncrecognized type',
        () {
      final datagram = new TypedDatagram(
        [1, 2, 3],
        testAddress,
        testPort,
        999,
      );

      commonSetUp([datagram]);

      eventStream.last.then(expectAsync1((_) {
        expect(recordedGreetDatagrams, isEmpty);
        expect(recordedDatagrams, isEmpty);
      }));
    });
  });
}
