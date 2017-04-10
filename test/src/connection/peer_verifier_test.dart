import 'package:distributed/src/connection/peer_verifier.dart';
import 'package:distributed/src/connection/socket_controller.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/objects.dart';
import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';

void main() {
  final remotePeer = new Peer('remote', HostMachine.Null);
  final localPeer = new Peer('local', HostMachine.Null);
  final logger = new Logger.disabled();

  group('verifyRemotePeer', () {
    SocketController controller;

    setUp(() async {
      controller = new SocketController();
    });

    tearDown(() async {
      controller.close();
    });

    test('should verify the peer on the other end of a connection', () async {
      verifyRemotePeer(controller.local, remotePeer, logger, incoming: true)
          .then((expectAsync1((VerificationResult verificationResult) {
        expect(verificationResult.error, isEmpty);
        expect(verificationResult.peer, remotePeer);
      })));
      controller.foreign.add(createIdMessage(remotePeer).serialize());
    });

    group('should return Peer.Null if', () {
      test('Invalid identification is recevied.', () {
        verifyRemotePeer(controller.local, remotePeer, logger, incoming: true)
            .then((expectAsync1((VerificationResult verificationResult) {
          expect(verificationResult.error, VerificationError.INVALID_RESPONSE);
          expect(verificationResult.peer, Peer.Null);
        })));
        controller.foreign.add(createIdMessage(Peer.Null).serialize());
      });

      test('An object that is not a $Message is received', () {
        [
          new Peer('foo', HostMachine.Null).serialize(),
          'null',
          'void main() { print("Hello"); }',
        ].forEach((invalidData) {
          verifyRemotePeer(controller.local, remotePeer, logger, incoming: true)
              .then((expectAsync1((VerificationResult verificationResult) {
            expect(verificationResult.error, VerificationError.INVALID_RESPONSE,
                reason: invalidData);
            expect(verificationResult.peer, Peer.Null, reason: invalidData);
          })));
          controller.foreign.add(invalidData);
        });
      });

      test('socket does not have an open connection.', () {
        var closedController = new SocketController()..close();
        verifyRemotePeer(closedController.local, remotePeer, logger,
                incoming: true)
            .then((expectAsync1((VerificationResult verificationResult) {
          expect(verificationResult.error, VerificationError.CONNECTION_CLOSED);
          expect(verificationResult.peer, Peer.Null);
        })));
      });

      test('the remote takes too long to respond.', () {
        new FakeAsync().run((fakeAsync) {
          verifyRemotePeer(controller.local, remotePeer, logger, incoming: true)
              .then((expectAsync1((VerificationResult verificationResult) {
            expect(verificationResult.error, VerificationError.TIMEOUT);
            expect(verificationResult.peer, Peer.Null);
          })));
          fakeAsync.elapse(timeoutDuration * 2);
        });
      });
    });
  });

  group('verifyRemotePeer', () {
    SocketController controller;

    setUp(() async {
      controller = new SocketController();
    });

    tearDown(() async {
      controller.close();
    });

    test('should verify the peer on the other end of a connection', () async {
      verifyRemotePeer(controller.local, localPeer, logger, incoming: false)
          .then((expectAsync1((VerificationResult verificationResult) {
        expect(verificationResult.error, isEmpty);
        expect(verificationResult.peer, remotePeer);
      })));

      controller.foreign.add(createIdMessage(remotePeer).serialize());
    });

    group('should return Peer.Null if', () {
      test('Invalid identification is recevied.', () {
        verifyRemotePeer(controller.local, localPeer, logger, incoming: false)
            .then((expectAsync1((VerificationResult verificationResult) {
          expect(verificationResult.error, VerificationError.INVALID_RESPONSE);
          expect(verificationResult.peer, Peer.Null);
        })));
        controller.foreign.add(createIdMessage(Peer.Null).serialize());
      });

      test('An object that is not a $Message is received', () {
        [
          new Peer('foo', HostMachine.Null).serialize(),
          'null',
          'void main() { print("Hello"); }',
        ].forEach((invalidData) {
          verifyRemotePeer(controller.local, localPeer, logger, incoming: false)
              .then((expectAsync1((VerificationResult verificationResult) {
            expect(verificationResult.error, VerificationError.INVALID_RESPONSE,
                reason: invalidData);
            expect(verificationResult.peer, Peer.Null, reason: invalidData);
          })));
          controller.foreign.add(invalidData);
        });
      });

      test('socket does not have an open connection.', () {
        var closedController = new SocketController()..close();
        verifyRemotePeer(closedController.local, localPeer, logger,
                incoming: false)
            .then((expectAsync1((VerificationResult verificationResult) {
          expect(verificationResult.error, VerificationError.CONNECTION_CLOSED);
          expect(verificationResult.peer, Peer.Null);
        })));
      });

      test('the remote closes the connection before verification completes',
          () {
        verifyRemotePeer(controller.local, localPeer, logger, incoming: false)
            .then((expectAsync1((VerificationResult verificationResult) {
          expect(verificationResult.error, VerificationError.CONNECTION_CLOSED);
          expect(verificationResult.peer, Peer.Null);
        })));
        controller.foreign.close();
      });

      test('the remote takes too long to respond.', () {
        new FakeAsync().run((fakeAsync) {
          verifyRemotePeer(controller.local, localPeer, logger, incoming: false)
              .then((expectAsync1((VerificationResult verificationResult) {
            expect(verificationResult.error, VerificationError.TIMEOUT);
            expect(verificationResult.peer, Peer.Null);
          })));
          fakeAsync.elapse(timeoutDuration * 2);
        });
      });
    });
  });
}
